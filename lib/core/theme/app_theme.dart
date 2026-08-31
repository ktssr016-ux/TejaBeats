import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// TEJABEATS DESIGN SYSTEM
/// "YOUR MUSIC. YOUR BEATS."
///
/// Comprehensive design system for the TejaBeats music player.
/// Use [AppTheme] in new code. The [Default_Theme] typedef at the bottom
/// provides backward-compatible access for existing callers.
/// ═══════════════════════════════════════════════════════════════════════════
class AppTheme {
  // ─────────────────────────────────────────────────────────────────────────
  // COLORS — TejaBeats Palette
  // ─────────────────────────────────────────────────────────────────────────

  // Backgrounds
  static const background = Color(0xFF0A0A0F);
  static const surface = Color(0xFF141418);
  static const surfaceLight = Color(0xFF1E1E24);
  static const surfaceBorder = Color(0xFF2A2A32);

  // Text
  static const textPrimary = Color(0xFFF5F5F7);
  static const textSecondary = Color(0xFF9CA3AF);
  static const textTertiary = Color(0xFF6B7280);
  static const textDisabled = Color(0xFF4B5563);

  // Accent — Pink → Red → Orange
  static const accentPink = Color(0xFFFF2D78);
  static const accentRed = Color(0xFFE53E3E);
  static const accentOrange = Color(0xFFFF6B35);
  static const accentPurple = Color(0xFF8B5CF6);
  static const accentPurpleLight = Color(0xFFA78BFA);

  // Status
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);
  static const error = Color(0xFFEF4444);

  // Translucent surfaces
  static const overlayDark = Color(0xCC0A0A0F); // 80% opacity
  static const overlayMedium = Color(0x990A0A0F); // 60% opacity
  static const overlayLight = Color(0x4D0A0A0F); // 30% opacity

  // ── Backward-compatible color aliases ─────────────────────────────────
  static const themeColor = background;
  static const primaryColor1 = textPrimary;
  static const primaryColor2 = Color(0xFFE8E0E6);
  static const accentColor1 = Color(0xFF0EA5E0);
  static const accentColor1light = Color(0xFF18C9ED);
  static const accentColor2 = accentPink;
  static const successColor = success;

  // ─────────────────────────────────────────────────────────────────────────
  // GRADIENTS
  // ─────────────────────────────────────────────────────────────────────────

  static const accentGradient = LinearGradient(
    colors: [accentPink, accentRed, accentOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accentGradientHorizontal = LinearGradient(
    colors: [accentPink, accentOrange],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const accentGradientSubtle = LinearGradient(
    colors: [
      Color(0x33FF2D78), // accentPink 20%
      Color(0x33FF6B35), // accentOrange 20%
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const surfaceGradient = LinearGradient(
    colors: [surface, background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // TYPOGRAPHY
  // ─────────────────────────────────────────────────────────────────────────

  // Heading styles — Unageo (modern geometric sans)
  static const headingLarge = TextStyle(
    fontFamily: 'Unageo',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const headingMedium = TextStyle(
    fontFamily: 'Unageo',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.25,
    letterSpacing: -0.3,
  );

  static const headingSmall = TextStyle(
    fontFamily: 'Unageo',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
    letterSpacing: -0.2,
  );

  // Body styles — Gilroy (clean readable body)
  static const bodyLarge = TextStyle(
    fontFamily: 'Gilroy',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontFamily: 'Gilroy',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.45,
  );

  static const bodySmall = TextStyle(
    fontFamily: 'Gilroy',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.4,
  );

  // Label styles — Gilroy Medium (buttons, chips, nav)
  static const labelLarge = TextStyle(
    fontFamily: 'Gilroy',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.3,
    letterSpacing: 0.2,
  );

  static const labelMedium = TextStyle(
    fontFamily: 'Gilroy',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.3,
    letterSpacing: 0.1,
  );

  static const labelSmall = TextStyle(
    fontFamily: 'Gilroy',
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: textSecondary,
    height: 1.3,
    letterSpacing: 0.3,
  );

  // Caption — small muted text
  static const caption = TextStyle(
    fontFamily: 'Gilroy',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    height: 1.3,
  );

  // ── Backward-compatible text style aliases ────────────────────────────
  static const primaryTextStyle = TextStyle(fontFamily: "Fjalla");
  static const secondoryTextStyle = TextStyle(fontFamily: "Gilroy");
  static const secondoryTextStyleMedium =
      TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w700);
  static const tertiaryTextStyle = TextStyle(fontFamily: "CodePro");
  static const fontAwesomeRegularFont =
      TextStyle(fontFamily: "FontAwesome-Regular");
  static const fontAwesomeSolidFont =
      TextStyle(fontFamily: "FontAwesome-Solids");

  // ─────────────────────────────────────────────────────────────────────────
  // SPACING
  // ─────────────────────────────────────────────────────────────────────────

  static const double spacingXS = 4;
  static const double spacingSM = 8;
  static const double spacingMD = 12;
  static const double spacingLG = 16;
  static const double spacingXL = 24;
  static const double spacingXXL = 32;
  static const double spacingXXXL = 48;

  // ─────────────────────────────────────────────────────────────────────────
  // CORNER RADIUS
  // ─────────────────────────────────────────────────────────────────────────

  static const double radiusSM = 8;
  static const double radiusMD = 12;
  static const double radiusLG = 16;
  static const double radiusXL = 20;
  static const double radiusXXL = 28;
  static const double radiusFull = 100;

  static final borderRadiusSM = BorderRadius.circular(radiusSM);
  static final borderRadiusMD = BorderRadius.circular(radiusMD);
  static final borderRadiusLG = BorderRadius.circular(radiusLG);
  static final borderRadiusXL = BorderRadius.circular(radiusXL);
  static final borderRadiusXXL = BorderRadius.circular(radiusXXL);
  static final borderRadiusFull = BorderRadius.circular(radiusFull);

  // ─────────────────────────────────────────────────────────────────────────
  // ICON STYLING
  // ─────────────────────────────────────────────────────────────────────────

  static const double iconSizeSM = 18;
  static const double iconSizeMD = 22;
  static const double iconSizeLG = 26;
  static const double iconSizeXL = 32;
  static const double iconSizeXXL = 48;

  // ─────────────────────────────────────────────────────────────────────────
  // ANIMATION DURATIONS
  // ─────────────────────────────────────────────────────────────────────────

  static const Duration durationMicro = Duration(milliseconds: 120);
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 450);
  static const Duration durationArtwork = Duration(milliseconds: 500);

  // Default curves
  static const Curve curveDefault = Curves.easeOutCubic;
  static const Curve curveDecelerate = Curves.decelerate;
  static const Curve curveSharp = Curves.easeInOutCubic;

  // ─────────────────────────────────────────────────────────────────────────
  // CARD DECORATIONS
  // ─────────────────────────────────────────────────────────────────────────

  /// Standard card decoration — dark surface, subtle border, rounded.
  static BoxDecoration cardDecoration({
    Color? color,
    double radius = radiusMD,
    bool showBorder = true,
  }) {
    return BoxDecoration(
      color: color ?? surface,
      borderRadius: BorderRadius.circular(radius),
      border: showBorder
          ? Border.all(color: surfaceBorder.withValues(alpha: 0.5), width: 0.5)
          : null,
    );
  }

  /// Elevated card with subtle shadow.
  static BoxDecoration cardDecorationElevated({
    Color? color,
    double radius = radiusLG,
  }) {
    return BoxDecoration(
      color: color ?? surfaceLight,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: surfaceBorder.withValues(alpha: 0.4), width: 0.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Translucent glass-like card (for mini player, overlays).
  static BoxDecoration cardDecorationGlass({
    double radius = radiusLG,
    double opacity = 0.85,
  }) {
    return BoxDecoration(
      color: surface.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: surfaceBorder.withValues(alpha: 0.3),
        width: 0.5,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUTTON STYLES
  // ─────────────────────────────────────────────────────────────────────────

  /// Primary button — accent colored, rounded.
  static ButtonStyle primaryButtonStyle({
    double radius = radiusFull,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: accentPink,
      foregroundColor: Colors.white,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      elevation: 0,
      textStyle: labelLarge.copyWith(color: Colors.white),
    );
  }

  /// Secondary button — transparent with subtle border.
  static ButtonStyle secondaryButtonStyle({
    double radius = radiusFull,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  }) {
    return OutlinedButton.styleFrom(
      foregroundColor: textPrimary,
      padding: padding,
      side: BorderSide(color: surfaceBorder, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      textStyle: labelMedium,
    );
  }

  /// Ghost button — no border, subtle hover.
  static ButtonStyle ghostButtonStyle({
    double radius = radiusSM,
  }) {
    return TextButton.styleFrom(
      foregroundColor: textSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      textStyle: labelMedium.copyWith(color: textSecondary),
    );
  }

  /// Icon button style — circular, subtle background.
  static ButtonStyle iconButtonCircular({
    double size = 40,
    Color? backgroundColor,
  }) {
    return IconButton.styleFrom(
      backgroundColor: backgroundColor ?? surfaceLight,
      foregroundColor: textPrimary,
      fixedSize: Size(size, size),
      shape: const CircleBorder(),
      padding: EdgeInsets.zero,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PLAYER CONTROL DECORATIONS
  // ─────────────────────────────────────────────────────────────────────────

  /// Large play/pause button decoration (gradient circle).
  static BoxDecoration playButtonDecoration({double size = 64}) {
    return BoxDecoration(
      gradient: accentGradient,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: accentPink.withValues(alpha: 0.35),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Secondary control button decoration (shuffle, repeat, etc.).
  static BoxDecoration controlButtonDecoration({bool isActive = false}) {
    return BoxDecoration(
      color: isActive
          ? accentPink.withValues(alpha: 0.15)
          : Colors.transparent,
      shape: BoxShape.circle,
    );
  }

  /// Progress bar track decoration.
  static BoxDecoration progressTrackDecoration() {
    return BoxDecoration(
      color: surfaceBorder,
      borderRadius: BorderRadius.circular(radiusFull),
    );
  }

  /// Progress bar fill decoration (accent gradient).
  static BoxDecoration progressFillDecoration() {
    return BoxDecoration(
      gradient: accentGradientHorizontal,
      borderRadius: BorderRadius.circular(radiusFull),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // NAVIGATION STYLING
  // ─────────────────────────────────────────────────────────────────────────

  /// Bottom nav indicator decoration.
  static BoxDecoration navIndicatorDecoration() {
    return BoxDecoration(
      gradient: accentGradientHorizontal,
      borderRadius: BorderRadius.circular(radiusFull),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INPUT DECORATION
  // ─────────────────────────────────────────────────────────────────────────

  /// Search bar / text field decoration.
  static InputDecoration searchInputDecoration({
    String hintText = 'Search music...',
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: bodyMedium.copyWith(color: textTertiary),
      prefixIcon: prefixIcon ??
          const Icon(Icons.search_rounded, color: textTertiary, size: iconSizeMD),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: surfaceLight,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: spacingLG, vertical: spacingMD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusFull),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusFull),
        borderSide: BorderSide(color: surfaceBorder.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusFull),
        borderSide: const BorderSide(color: accentPink, width: 1),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CHIP STYLING
  // ─────────────────────────────────────────────────────────────────────────

  /// Filter chip decoration (All, Songs, Artists, etc.).
  static BoxDecoration chipDecoration({bool isSelected = false}) {
    return BoxDecoration(
      color: isSelected ? accentPink.withValues(alpha: 0.15) : surfaceLight,
      borderRadius: BorderRadius.circular(radiusFull),
      border: Border.all(
        color: isSelected ? accentPink : surfaceBorder,
        width: isSelected ? 1.0 : 0.5,
      ),
    );
  }

  /// Chip text style based on selection.
  static TextStyle chipTextStyle({bool isSelected = false}) {
    return labelMedium.copyWith(
      color: isSelected ? accentPink : textSecondary,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DIVIDER / SEPARATOR
  // ─────────────────────────────────────────────────────────────────────────

  static const dividerColor = surfaceBorder;
  static const double dividerThickness = 0.5;

  // ─────────────────────────────────────────────────────────────────────────
  // THEME DATA — Complete Material ThemeData for the app
  // ─────────────────────────────────────────────────────────────────────────

  ThemeData get defaultThemeData {
    const darkScheme = ColorScheme.dark(
      primary: accentPink,
      secondary: accentOrange,
      tertiary: accentPurple,
      surface: background,
      surfaceContainerHighest: surfaceLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      error: error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      dialogBackgroundColor: surface,
      primaryColorDark: accentPink,
      fontFamily: 'Gilroy',
      primarySwatch: MaterialColor(
        accentPink.value,
        {
          50: accentPink.withValues(alpha: 0.1),
          100: accentPink.withValues(alpha: 0.2),
          200: accentPink.withValues(alpha: 0.3),
          300: accentPink.withValues(alpha: 0.4),
          400: accentPink.withValues(alpha: 0.5),
          500: accentPink.withValues(alpha: 0.6),
          600: accentPink.withValues(alpha: 0.7),
          700: accentPink.withValues(alpha: 0.8),
          800: accentPink.withValues(alpha: 0.9),
          900: accentPink,
        },
      ),
      colorScheme: darkScheme,
      iconTheme: const IconThemeData(color: textPrimary, size: iconSizeMD),
      brightness: Brightness.dark,

      // ── App Bar ──────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        surfaceTintColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textPrimary, size: iconSizeMD),
        titleTextStyle: TextStyle(
          fontFamily: 'Unageo',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
      ),

      // ── Scrollbar ───────────────────────────────────────────────────
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          accentPink.withValues(alpha: 0.5),
        ),
        interactive: true,
        radius: const Radius.circular(radiusFull),
        thickness: WidgetStateProperty.all(4),
        thumbVisibility: WidgetStateProperty.all(false),
      ),

      // ── Progress Indicator ──────────────────────────────────────────
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: accentPink),

      // ── Text Selection ──────────────────────────────────────────────
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: accentPink,
        selectionColor: accentPink.withValues(alpha: 0.3),
        selectionHandleColor: accentPink,
      ),

      // ── Switch ──────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? Colors.white : textTertiary),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? accentPink : surfaceBorder),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? accentPink
                : surfaceLight),
      ),

      // ── Search Bar ──────────────────────────────────────────────────
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(surfaceLight),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
            side: BorderSide(color: surfaceBorder.withValues(alpha: 0.3)),
          ),
        ),
        textStyle: WidgetStatePropertyAll(bodyMedium),
        hintStyle: WidgetStatePropertyAll(
          bodyMedium.copyWith(color: textTertiary),
        ),
      ),

      // ── Popup Menu ──────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          side: BorderSide(color: surfaceBorder.withValues(alpha: 0.4)),
        ),
        elevation: 8,
        textStyle: const TextStyle(color: textPrimary, fontFamily: 'Gilroy'),
      ),

      // ── Dropdown Menu ───────────────────────────────────────────────
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(surfaceLight),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMD),
            ),
          ),
        ),
        textStyle: const TextStyle(color: textPrimary, fontFamily: 'Gilroy'),
      ),

      // ── Menu ────────────────────────────────────────────────────────
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(surfaceLight),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMD),
            ),
          ),
        ),
      ),

      // ── Card ────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          side: BorderSide(color: surfaceBorder.withValues(alpha: 0.3)),
        ),
      ),

      // ── Bottom Navigation ───────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: accentPink,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),

      // ── Navigation Rail (Desktop sidebar) ──────────────────────────
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: background,
        selectedIconTheme: const IconThemeData(color: accentPink, size: 24),
        unselectedIconTheme: const IconThemeData(color: textTertiary, size: 22),
        selectedLabelTextStyle: labelMedium.copyWith(color: accentPink),
        unselectedLabelTextStyle: labelSmall.copyWith(color: textTertiary),
        indicatorColor: accentPink.withValues(alpha: 0.12),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
        ),
      ),

      // ── Input Decoration ────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        hintStyle: bodyMedium.copyWith(color: textTertiary),
        labelStyle: bodyMedium.copyWith(color: textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingLG,
          vertical: spacingMD,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: BorderSide(color: surfaceBorder.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: accentPink, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: error, width: 1),
        ),
      ),

      // ── Chip ────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLight,
        selectedColor: accentPink.withValues(alpha: 0.15),
        disabledColor: surfaceLight.withValues(alpha: 0.5),
        labelStyle: labelMedium,
        secondaryLabelStyle: labelMedium.copyWith(color: accentPink),
        side: BorderSide(color: surfaceBorder.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        padding: const EdgeInsets.symmetric(horizontal: spacingSM, vertical: spacingXS),
        showCheckmark: false,
      ),

      // ── Slider ──────────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: accentPink,
        inactiveTrackColor: surfaceBorder,
        thumbColor: Colors.white,
        overlayColor: accentPink.withValues(alpha: 0.12),
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      ),

      // ── Dialog ──────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
          side: BorderSide(color: surfaceBorder.withValues(alpha: 0.3)),
        ),
        elevation: 16,
        titleTextStyle: headingSmall,
        contentTextStyle: bodyMedium.copyWith(color: textSecondary),
      ),

      // ── Bottom Sheet ────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusXL),
          ),
        ),
        dragHandleColor: surfaceBorder,
        dragHandleSize: const Size(36, 4),
      ),

      // ── Divider ─────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: surfaceBorder.withValues(alpha: 0.4),
        thickness: dividerThickness,
        space: 0,
      ),

      // ── Snackbar ────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceLight,
        contentTextStyle: bodyMedium.copyWith(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),

      // ── Tooltip ─────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: surfaceLight,
          borderRadius: BorderRadius.circular(radiusSM),
          border: Border.all(color: surfaceBorder.withValues(alpha: 0.4)),
        ),
        textStyle: bodySmall.copyWith(color: textPrimary),
      ),

      // ── List Tile ───────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        iconColor: textSecondary,
        textColor: textPrimary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingLG,
          vertical: spacingXS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
        ),
      ),

      // ── Tab Bar ─────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: accentPink,
        unselectedLabelColor: textTertiary,
        indicatorColor: accentPink,
        labelStyle: labelMedium.copyWith(color: accentPink),
        unselectedLabelStyle: labelMedium.copyWith(color: textTertiary),
        indicatorSize: TabBarIndicatorSize.label,
        dividerHeight: 0,
      ),

      // ── Floating Action Button ──────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentPink,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
        ),
      ),
    );
  }
}

/// Backward-compat alias for [AppTheme].
/// Prefer importing from [core/theme/app_theme.dart] and using [AppTheme] directly.
// ignore: camel_case_types
typedef Default_Theme = AppTheme;
