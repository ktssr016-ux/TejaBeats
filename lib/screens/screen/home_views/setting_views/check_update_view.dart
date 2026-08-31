import 'package:Bloomee/services/bloomee_updater_tools.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/utils/url_launcher.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:icons_plus/icons_plus.dart';

class CheckUpdateView extends StatelessWidget {
  const CheckUpdateView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          l10n.updateCheckTitle,
          style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)
              .merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: Center(
        child: FutureBuilder(
          future: getLatestVersion(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (!snapshot.data?["results"]) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    const SizedBox(height: 10),
                    Text(
                      'TejaBeats (v${snapshot.data?["currVer"] ?? "3.0.4"}) is up to date!',
                      style: const TextStyle(
                        color: AppTheme.accentPink,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'TejaOS Engine is running the latest stable build.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        'Version ${snapshot.data?["currVer"] ?? "3.0.4"}+${snapshot.data?["currBuild"] ?? "202"}',
                        style: TextStyle(
                          color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Text(
                      l10n.updateNewVersionAvailable,
                      style: const TextStyle(
                              color: Default_Theme.accentColor2, fontSize: 20)
                          .merge(Default_Theme.tertiaryTextStyle),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        l10n.updateVersion(snapshot.data?["newVer"] ?? '',
                            snapshot.data?["newBuild"] ?? ''),
                        style: TextStyle(
                                color: Default_Theme.primaryColor1
                                    .withValues(alpha: 0.8),
                                fontSize: 16)
                            .merge(Default_Theme.tertiaryTextStyle),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentPink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 6,
                        shadowColor: AppTheme.accentPink.withValues(alpha: 0.5),
                      ),
                      icon: const Icon(MingCute.download_3_fill, size: 20),
                      label: const Text(
                        'Download Latest Update',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        final url = snapshot.data?["download_url"] as String?;
                        if (url != null && url.isNotEmpty) {
                          launch_Url(Uri.parse(url));
                        }
                      },
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        l10n.updateCurrentVersion(
                            snapshot.data?["currVer"] ?? '',
                            snapshot.data?["currBuild"] ?? ''),
                        style: TextStyle(
                                color: Default_Theme.primaryColor2
                                    .withValues(alpha: 0.5),
                                fontSize: 12)
                            .merge(Default_Theme.tertiaryTextStyle),
                      ),
                    ),
                  ],
                );
              }
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: SizedBox(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(
                          color: Default_Theme.accentColor2,
                        )),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        width: constraints.maxWidth * 0.6,
                        child: Text(l10n.updateChecking,
                            style: const TextStyle(
                                    color: Default_Theme.accentColor2,
                                    fontSize: 20)
                                .merge(Default_Theme.tertiaryTextStyle),
                            textAlign: TextAlign.center),
                      );
                    },
                  )
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
