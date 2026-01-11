/// SDK configuration options for Shopify Checkout Sheet Kit.
class Configuration {
  /// The color scheme for the checkout UI.
  final CheckoutColorScheme colorScheme;

  /// Preloading configuration.
  final Preloading preloading;

  /// Error recovery configuration.
  final ErrorRecovery errorRecovery;

  /// iOS-specific: Tint color for UI elements.
  final Color? tintColor;

  /// iOS-specific: Background color.
  final Color? backgroundColor;

  /// iOS-specific: Navigation bar title.
  final String? title;

  /// Creates SDK configuration with the specified options.
  const Configuration({
    this.colorScheme = CheckoutColorScheme.automatic,
    this.preloading = const Preloading(),
    this.errorRecovery = const ErrorRecovery(),
    this.tintColor,
    this.backgroundColor,
    this.title,
  });

  /// Converts configuration to a map for platform channel.
  Map<String, dynamic> toMap() {
    return {
      'colorScheme': colorScheme.name,
      'preloading': preloading.toMap(),
      'errorRecovery': errorRecovery.toMap(),
      if (tintColor != null) 'tintColor': tintColor!.toHex(),
      if (backgroundColor != null) 'backgroundColor': backgroundColor!.toHex(),
      if (title != null) 'title': title,
    };
  }

  /// Creates a copy with the specified changes.
  Configuration copyWith({
    CheckoutColorScheme? colorScheme,
    Preloading? preloading,
    ErrorRecovery? errorRecovery,
    Color? tintColor,
    Color? backgroundColor,
    String? title,
  }) {
    return Configuration(
      colorScheme: colorScheme ?? this.colorScheme,
      preloading: preloading ?? this.preloading,
      errorRecovery: errorRecovery ?? this.errorRecovery,
      tintColor: tintColor ?? this.tintColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      title: title ?? this.title,
    );
  }
}

/// Color scheme options for the checkout UI.
enum CheckoutColorScheme {
  /// Automatically matches system appearance (light/dark mode).
  automatic,

  /// Forces light mode appearance.
  light,

  /// Forces dark mode appearance.
  dark,

  /// Uses colors defined by the web checkout theme.
  web,
}

/// Configuration for checkout preloading behavior.
class Preloading {
  /// Whether preloading is enabled.
  final bool enabled;

  /// Creates preloading configuration.
  const Preloading({this.enabled = true});

  /// Converts to map for platform channel.
  Map<String, dynamic> toMap() => {'enabled': enabled};
}

/// Configuration for error recovery behavior.
class ErrorRecovery {
  /// Whether automatic error recovery is enabled.
  final bool enabled;

  /// Creates error recovery configuration.
  const ErrorRecovery({this.enabled = true});

  /// Converts to map for platform channel.
  Map<String, dynamic> toMap() => {'enabled': enabled};
}

/// Simple color class for cross-platform color representation.
class Color {
  /// Red component (0-255).
  final int red;

  /// Green component (0-255).
  final int green;

  /// Blue component (0-255).
  final int blue;

  /// Alpha component (0-255).
  final int alpha;

  /// Creates a color from RGBA components.
  const Color.fromRGBA(this.red, this.green, this.blue, [this.alpha = 255]);

  /// Creates a color from a hex value (0xAARRGGBB or 0xRRGGBB).
  factory Color.fromHex(int hex) {
    if (hex <= 0xFFFFFF) {
      // 0xRRGGBB format
      return Color.fromRGBA(
        (hex >> 16) & 0xFF,
        (hex >> 8) & 0xFF,
        hex & 0xFF,
      );
    }
    // 0xAARRGGBB format
    return Color.fromRGBA(
      (hex >> 16) & 0xFF,
      (hex >> 8) & 0xFF,
      hex & 0xFF,
      (hex >> 24) & 0xFF,
    );
  }

  /// Converts to hex string for platform channel.
  String toHex() {
    return '#${alpha.toRadixString(16).padLeft(2, '0')}'
        '${red.toRadixString(16).padLeft(2, '0')}'
        '${green.toRadixString(16).padLeft(2, '0')}'
        '${blue.toRadixString(16).padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Color &&
        other.red == red &&
        other.green == green &&
        other.blue == blue &&
        other.alpha == alpha;
  }

  @override
  int get hashCode => Object.hash(red, green, blue, alpha);
}
