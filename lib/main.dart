// TejaBeats - High-performance desktop and mobile music player.
// Modified from Bloomee: Copyright (C) 2024-2026 Hemant Kumar & Bloomee Contributors.
// Modifications Copyright (C) 2026 Teja.
// Licensed under the GNU General Public License Version 2.0 (GPL-2.0).

import 'dart:async';
import 'dart:io' as io;
import 'package:Bloomee/services/license_service.dart';
import 'package:Bloomee/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:Bloomee/blocs/global_events/global_events_cubit.dart';
import 'package:Bloomee/blocs/internet_connectivity/cubit/connectivity_cubit.dart';
import 'package:Bloomee/blocs/lastdotfm/lastdotfm_cubit.dart';
import 'package:Bloomee/blocs/local_music/cubit/local_music_cubit.dart';
import 'package:Bloomee/blocs/lyrics/lyrics_cubit.dart';
import 'package:Bloomee/blocs/mini_player/mini_player_cubit.dart';
import 'package:Bloomee/blocs/notification/notification_cubit.dart';
import 'package:Bloomee/blocs/history/cubit/history_cubit.dart';
import 'package:Bloomee/blocs/explore/cubit/recently_cubit.dart';
import 'package:Bloomee/blocs/player_overlay/player_overlay_cubit.dart';
import 'package:Bloomee/blocs/search_suggestions/search_suggestion_bloc.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_event.dart';
import 'package:Bloomee/repository/bloomee/download_repository.dart';
import 'package:Bloomee/repository/bloomee/settings_repository.dart';
import 'package:Bloomee/services/db/dao/cache_dao.dart';
import 'package:Bloomee/services/db/dao/download_dao.dart';
import 'package:Bloomee/services/db/dao/history_dao.dart';
import 'package:Bloomee/services/db/dao/lyrics_dao.dart';
import 'package:Bloomee/services/db/dao/notification_dao.dart';
import 'package:Bloomee/services/db/dao/library_dao.dart';
import 'package:Bloomee/services/db/dao/playlist_dao.dart';
import 'package:Bloomee/services/db/dao/search_history_dao.dart';
import 'package:Bloomee/core/di/service_locator.dart';
import 'package:Bloomee/services/db/dao/track_dao.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/blocs/timer/timer_bloc.dart';
import 'package:Bloomee/screens/widgets/global_event_listener.dart';
import 'package:Bloomee/screens/widgets/shortcut_indicator_overlay.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/bootstrap.dart';
import 'package:Bloomee/services/audio_service_initializer.dart';
import 'package:Bloomee/services/keyboard_shortcuts_service.dart';
import 'package:Bloomee/services/shortcut_indicator_service.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/services/import_export_service.dart';
import 'package:Bloomee/utils/ticker.dart';
import 'package:Bloomee/utils/url_checker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/blocs/add_to_playlist/cubit/add_to_playlist_cubit.dart';
import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/plugins/blocs/import/content_import_cubit.dart';
import 'package:Bloomee/routes/app_router.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/current_playlist_cubit.dart';
import 'package:media_kit/media_kit.dart';
import 'package:share_handler/share_handler.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'blocs/media_player/bloomee_player_cubit.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:Bloomee/services/discord_service.dart';
import 'package:Bloomee/services/db/legacy/legacy_migration_service.dart'
    as legacy_migration;
import 'package:Bloomee/screens/widgets/legacy_migration_overlay.dart';
import 'package:Bloomee/screens/widgets/onboarding_overlay.dart';
import 'package:Bloomee/screens/widgets/plugin_bootstrap_overlay.dart';
import 'package:Bloomee/services/onboarding_service.dart';
import 'package:Bloomee/services/plugin_bootstrap_service.dart';
import 'package:Bloomee/plugins/services/plugin_repository_service.dart';
import 'package:Bloomee/services/shared_url_resolver_service.dart';

void processIncomingIntent(SharedMedia sharedMedia) {
  if (sharedMedia.content != null && isUrl(sharedMedia.content!)) {
    final urlType = getUrlType(sharedMedia.content!);
    switch (urlType) {
      case UrlType.youtubeVideo:
        _handleYoutubeVideoIntent(sharedMedia.content!);
        break;
      case UrlType.youtubePlaylist:
      case UrlType.spotifyTrack:
      case UrlType.spotifyPlaylist:
      case UrlType.spotifyAlbum:
      case UrlType.other:
        SnackbarService.showMessage(
            'Open the Import screen in Library to import from this URL.');
        break;
    }
  } else if (sharedMedia.attachments != null &&
      sharedMedia.attachments!.isNotEmpty) {
    final attachment = sharedMedia.attachments!.first;
    if (attachment != null) {
      SnackbarService.showMessage('Processing File...');
      importItems(attachment.path);
    }
  }
}

Future<void> _handleYoutubeVideoIntent(String url) async {
  if (extractVideoId(url) == null) {
    SnackbarService.showMessage('Invalid YouTube URL');
    return;
  }
  SnackbarService.showMessage('Getting YouTube Audio...');

  final result = await SharedUrlResolverService.resolveYoutubeVideo(url);
  if (result.status == SharedUrlResolveStatus.invalidUrl) {
    SnackbarService.showMessage('Invalid YouTube URL');
    return;
  }

  if (result.status == SharedUrlResolveStatus.noResolver) {
    SnackbarService.showMessage(
        'No loaded content resolver can handle this URL.');
    return;
  }

  final track = result.track;
  if (result.status == SharedUrlResolveStatus.success && track != null) {
    final player = await PlayerInitializer().getBloomeeMusicPlayer();
    await player.updateQueueTracks([track], doPlay: true);
    SnackbarService.showMessage('Playing: ${track.title}');
    return;
  }

  if (result.status == SharedUrlResolveStatus.failed) {
    SnackbarService.showMessage('Failed to get YouTube audio.');
  }
}

Future<void> importItems(String path) async {
  final context = GlobalRoutes.globalRouterKey.currentContext;
  if (context == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      importItems(path);
    });
    return;
  }

  await ImportExportService.handleImportOrRestore(context, path);
}

Future<void> setHighRefreshRate() async {
  if (io.Platform.isAndroid) {
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (e) {
      debugPrint('Could not set high refresh rate: $e');
    }
  }
}

BloomeePlayerCubit? _bloomeePlayerCubit;
BloomeePlayerCubit get bloomeePlayerCubit => _bloomeePlayerCubit!;

Future<void> setupPlayerCubit() async {
  await setupAudioSession();
  final player = await PlayerInitializer().getBloomeeMusicPlayer();
  _bloomeePlayerCubit = BloomeePlayerCubit(player);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GestureBinding.instance.resamplingEnabled = true;
  MediaKit.ensureInitialized();
  LicenseService.registerCustomLicenses();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // Initialize the player
  // This widget is the root of your application.
  StreamSubscription<SharedMedia>? _intentSub;
  SharedMedia? sharedMedia;

  bool _isInitialized = false;

  // TODO: remove this after one or two releases.
  // Legacy migration — set to true when a default.isar file is found.
  // Remove this field (and the overlay block in build) once no users
  // need legacy migration.
  bool _migrationPending = false;
  bool _onboardingPending = false;
  bool _pluginBootstrapPending = false;
  // ------------------

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await bootstrapApp();
    } catch (e, st) {
      debugPrint('bootstrapApp error: $e\n$st');
    }

    try {
      await setHighRefreshRate();
    } catch (e, st) {
      debugPrint('setHighRefreshRate error: $e\n$st');
    }

    try {
      await setupPlayerCubit();
    } catch (e, st) {
      debugPrint('setupPlayerCubit error: $e\n$st');
    }

    try {
      DiscordService.initialize();
    } catch (e, st) {
      debugPrint('DiscordService.initialize error: $e\n$st');
    }

    // Check once at startup; DBProvider.appSuppDir is set by bootstrapApp().
    try {
      _migrationPending = legacy_migration.needsMigration(
        DBProvider.appSuppDir,
        DBProvider.appDocDir,
      );
      _onboardingPending = !OnboardingService.onboardingDone;
      _pluginBootstrapPending = !PluginBootstrapService.bootstrapDone;
    } catch (e, st) {
      debugPrint('Bootstrap flags check error: $e\n$st');
    }

    if (io.Platform.isAndroid) {
      unawaited(initPlatformState());
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_ensurePlayerHealthyOnResume());
      // Check for plugin updates when app resumes (30-min cooldown enforced).
      unawaited(_checkPluginUpdatesOnResume());
    }
  }

  Future<void> _ensurePlayerHealthyOnResume() async {
    try {
      final player = await PlayerInitializer().getBloomeeMusicPlayer();
      if (!player.isPlayerHealthy) {
        await player.revive();
      }
      player.syncPublicState();
    } catch (error, stackTrace) {
      debugPrint('Player health check on resume failed: $error\n$stackTrace');
    }
  }

  Future<void> _checkPluginUpdatesOnResume() async {
    try {
      final settingsDao = SettingsDAO(DBProvider.db);
      final repositoryService =
          PluginRepositoryService(settingsDao: settingsDao);
      await PluginBootstrapService.syncOnAppOpenIfDue(
        pluginService: ServiceLocator.pluginService,
        repositoryService: repositoryService,
        settingsDao: settingsDao,
      );
    } catch (error, stackTrace) {
      debugPrint('Plugin update check on resume failed: $error\n$stackTrace');
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    try {
      final handler = ShareHandlerPlatform.instance;
      sharedMedia = await handler.getInitialSharedMedia();

      _intentSub = handler.sharedMediaStream.listen((SharedMedia media) {
        if (!mounted) return;
        setState(() {
          sharedMedia = media;
        });
        if (sharedMedia != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            processIncomingIntent(sharedMedia!);
          });
        }
      });
      if (!mounted) return;

      setState(() {
        // If there's initial shared media, process it
        if (sharedMedia != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            processIncomingIntent(sharedMedia!);
          });
        }
      });
    } catch (error, stackTrace) {
      debugPrint('Failed to initialize share handler: $error\n$stackTrace');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _intentSub?.cancel();
    if (_bloomeePlayerCubit != null) {
      _bloomeePlayerCubit!.close();
    }
    if (io.Platform.isWindows || io.Platform.isLinux || io.Platform.isMacOS) {
      DiscordService.clearPresence();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Default_Theme().defaultThemeData,
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: Default_Theme.accentColor2,
              ),
            ),
          ),
        ),
      );
    }
    // ── Legacy migration guard ────────────────────────────────────────────
    // If a default.isar (legacy DB) exists, show the non-dismissible
    // migration overlay before starting the normal app. Once migration
    // finishes successfully the overlay removes itself.
    //
    // To remove this feature in future: delete the `if` block below AND the
    // import at the top of this file AND lib/services/db/legacy/.
    if (_migrationPending) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Default_Theme().defaultThemeData,
        home: LegacyMigrationOverlay(
          appSuppDir: DBProvider.appSuppDir,
          appDocDir: DBProvider.appDocDir,
          onComplete: (result) {
            if (!result.success) return;
            setState(() => _migrationPending = false);
          },
        ),
      );
    }

    if (_onboardingPending) {
      return OnboardingOverlay(
        onComplete: () {
          if (!mounted) return;
          setState(() {
            _onboardingPending = false;
            _pluginBootstrapPending = !PluginBootstrapService.bootstrapDone;
          });
        },
      );
    }

    if (_pluginBootstrapPending) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Default_Theme().defaultThemeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale != null) {
            for (final supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }
          }
          return const Locale('en');
        },
        home: PluginBootstrapOverlay(
          onComplete: () {
            if (!mounted) return;
            setState(() => _pluginBootstrapPending = false);
          },
        ),
      );
    }
    // ─────────────────────────────────────────────────────────────────────

    final trackDao = TrackDAO(DBProvider.db);
    final playlistDao = PlaylistDAO(DBProvider.db, trackDao);
    final historyDao = HistoryDAO(DBProvider.db, trackDao);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PluginBloc(
            pluginService: ServiceLocator.pluginService,
            eventBus: ServiceLocator.pluginEventBus,
            repositoryService: ServiceLocator.pluginRepositoryService,
            settingsDao: SettingsDAO(DBProvider.db),
          )..add(const InitializePluginSystem()),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => bloomeePlayerCubit,
          lazy: false,
        ),
        BlocProvider(
            create: (context) =>
                MiniPlayerCubit(playerCubit: bloomeePlayerCubit),
            lazy: true),
        BlocProvider(
          create: (context) => SettingsCubit(
            SettingsRepository(SettingsDAO(DBProvider.db)),
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => NotificationCubit(
            notificationDao: NotificationDAO(DBProvider.db),
          ),
          lazy: false,
        ),
        BlocProvider(
            create: (context) => TimerBloc(
                ticker: const Ticker(), bloomeePlayer: bloomeePlayerCubit)),
        BlocProvider(
          create: (context) => ConnectivityCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => CurrentPlaylistCubit(playlistDao: playlistDao),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => RecentlyCubit(historyDao),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => HistoryCubit(historyDao: historyDao),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => LibraryItemsCubit(
            playlistDao: playlistDao,
            libraryDao: LibraryDAO(DBProvider.db),
          ),
        ),
        BlocProvider(
          create: (context) => ContentImportCubit(),
          lazy: true,
        ),
        BlocProvider(
          create: (context) => AddToPlaylistCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => SearchSuggestionBloc(
            searchHistoryDao: SearchHistoryDAO(DBProvider.db),
            pluginService: ServiceLocator.pluginService,
            settingsDao: SettingsDAO(DBProvider.db),
          ),
        ),
        BlocProvider(
          create: (context) => LyricsCubit(
            bloomeePlayerCubit,
            lyricsDao: LyricsDAO(DBProvider.db),
            settingsDao: SettingsDAO(DBProvider.db),
            pluginService: ServiceLocator.pluginService,
          ),
        ),
        BlocProvider(
          create: (context) => LastdotfmCubit(
            playerCubit: bloomeePlayerCubit,
            cacheDao: CacheDAO(DBProvider.db),
            settingsDao: SettingsDAO(DBProvider.db),
            pluginService: ServiceLocator.pluginService,
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => DownloaderCubit(
            connectivityCubit: context.read<ConnectivityCubit>(),
            libraryItemsCubit: context.read<LibraryItemsCubit>(),
            downloadRepo: DownloadRepository(
              DownloadDAO(DBProvider.db, trackDao, playlistDao),
            ),
            settingsDao: SettingsDAO(DBProvider.db),
            pluginService: ServiceLocator.pluginService,
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => GlobalEventsCubit(
            settingsDao: SettingsDAO(DBProvider.db),
          ),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => PlayerOverlayCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => ShortcutIndicatorCubit(),
          lazy: false,
        ),
        BlocProvider(
          create: (context) => LocalMusicCubit(),
          lazy: true,
        ),
      ],
      child: BlocBuilder<BloomeePlayerCubit, BloomeePlayerState>(
        builder: (context, state) {
          if (state is BloomeePlayerInitial) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: Default_Theme().defaultThemeData,
              home: const Scaffold(
                backgroundColor: Default_Theme.themeColor,
                body: Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      color: Default_Theme.accentColor2,
                    ),
                  ),
                ),
              ),
            );
          } else {
            return BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
                final locale = settingsState.languageCode.isEmpty
                    ? null
                    : Locale(settingsState.languageCode);

                return KeyboardShortcutsHandler(
                  child: ShortcutIndicatorOverlay(
                    child: MaterialApp.router(
                      localizationsDelegates:
                          AppLocalizations.localizationsDelegates,
                      supportedLocales: AppLocalizations.supportedLocales,
                      locale: locale,
                      localeResolutionCallback: (locale, supportedLocales) {
                        if (locale != null) {
                          for (final supportedLocale in supportedLocales) {
                            if (supportedLocale.languageCode ==
                                locale.languageCode) {
                              return supportedLocale;
                            }
                          }
                        }
                        return const Locale('en');
                      },
                      builder: (context, child) =>
                          ResponsiveBreakpoints.builder(
                        breakpoints: [
                          const Breakpoint(start: 0, end: 450, name: MOBILE),
                          const Breakpoint(start: 451, end: 800, name: TABLET),
                          const Breakpoint(
                              start: 801, end: 1920, name: DESKTOP),
                          const Breakpoint(
                              start: 1921, end: double.infinity, name: '4K'),
                        ],
                        child: GlobalEventListener(
                          navigatorKey: GlobalRoutes.globalRouterKey,
                          child: child!,
                        ),
                      ),
                      scaffoldMessengerKey: SnackbarService.messengerKey,
                      routerConfig: GlobalRoutes.globalRouter,
                      theme: Default_Theme().defaultThemeData,
                      scrollBehavior: CustomScrollBehavior(),
                      debugShowCheckedModeBanner: false,
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
      };
}
