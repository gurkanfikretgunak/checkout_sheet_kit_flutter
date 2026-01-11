/// Web pixel event emitted during checkout.
sealed class PixelEvent {
  /// The event name/type.
  String get name;

  /// Event timestamp.
  final DateTime? timestamp;

  /// Creates a pixel event.
  const PixelEvent({this.timestamp});

  /// Creates from a map (for platform channel).
  factory PixelEvent.fromMap(Map<String, dynamic> map) {
    final type = map['type'] as String;

    switch (type) {
      case 'standard':
        return StandardPixelEvent.fromMap(map);
      case 'custom':
        return CustomPixelEvent.fromMap(map);
      default:
        return CustomPixelEvent(
          name: map['name'] as String? ?? 'unknown',
          customData: map['customData'] as Map<String, dynamic>?,
          timestamp: _parseTimestamp(map['timestamp']),
        );
    }
  }

  /// Converts to map.
  Map<String, dynamic> toMap();

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

/// Standard Shopify pixel event.
class StandardPixelEvent extends PixelEvent {
  @override
  final String name;

  /// Event ID.
  final String? id;

  /// Event context data.
  final PixelEventContext? context;

  /// Event-specific data.
  final Map<String, dynamic>? data;

  /// Creates a standard pixel event.
  const StandardPixelEvent({
    required this.name,
    this.id,
    this.context,
    this.data,
    super.timestamp,
  });

  /// Creates from a map.
  factory StandardPixelEvent.fromMap(Map<String, dynamic> map) {
    return StandardPixelEvent(
      name: map['name'] as String,
      id: map['id'] as String?,
      context: map['context'] != null
          ? PixelEventContext.fromMap(
              Map<String, dynamic>.from(map['context'] as Map))
          : null,
      data: map['data'] != null
          ? Map<String, dynamic>.from(map['data'] as Map)
          : null,
      timestamp: PixelEvent._parseTimestamp(map['timestamp']),
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': 'standard',
        'name': name,
        if (id != null) 'id': id,
        if (context != null) 'context': context!.toMap(),
        if (data != null) 'data': data,
        if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
      };
}

/// Custom pixel event.
class CustomPixelEvent extends PixelEvent {
  @override
  final String name;

  /// Custom event data.
  final Map<String, dynamic>? customData;

  /// Creates a custom pixel event.
  const CustomPixelEvent({
    required this.name,
    this.customData,
    super.timestamp,
  });

  /// Creates from a map.
  factory CustomPixelEvent.fromMap(Map<String, dynamic> map) {
    return CustomPixelEvent(
      name: map['name'] as String,
      customData: map['customData'] != null
          ? Map<String, dynamic>.from(map['customData'] as Map)
          : null,
      timestamp: PixelEvent._parseTimestamp(map['timestamp']),
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': 'custom',
        'name': name,
        if (customData != null) 'customData': customData,
        if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
      };
}

/// Context for pixel events.
class PixelEventContext {
  /// Document information.
  final PixelDocument? document;

  /// Navigator information.
  final PixelNavigator? navigator;

  /// Window information.
  final PixelWindow? window;

  /// Creates pixel event context.
  const PixelEventContext({
    this.document,
    this.navigator,
    this.window,
  });

  /// Creates from a map.
  factory PixelEventContext.fromMap(Map<String, dynamic> map) {
    return PixelEventContext(
      document: map['document'] != null
          ? PixelDocument.fromMap(
              Map<String, dynamic>.from(map['document'] as Map))
          : null,
      navigator: map['navigator'] != null
          ? PixelNavigator.fromMap(
              Map<String, dynamic>.from(map['navigator'] as Map))
          : null,
      window: map['window'] != null
          ? PixelWindow.fromMap(Map<String, dynamic>.from(map['window'] as Map))
          : null,
    );
  }

  /// Converts to map.
  Map<String, dynamic> toMap() => {
        if (document != null) 'document': document!.toMap(),
        if (navigator != null) 'navigator': navigator!.toMap(),
        if (window != null) 'window': window!.toMap(),
      };
}

/// Document information for pixel events.
class PixelDocument {
  /// Page location/URL.
  final String? location;

  /// Page referrer.
  final String? referrer;

  /// Character set.
  final String? characterSet;

  /// Page title.
  final String? title;

  /// Creates a pixel document.
  const PixelDocument({
    this.location,
    this.referrer,
    this.characterSet,
    this.title,
  });

  /// Creates from a map.
  factory PixelDocument.fromMap(Map<String, dynamic> map) {
    return PixelDocument(
      location: map['location'] as String?,
      referrer: map['referrer'] as String?,
      characterSet: map['characterSet'] as String?,
      title: map['title'] as String?,
    );
  }

  /// Converts to map.
  Map<String, dynamic> toMap() => {
        if (location != null) 'location': location,
        if (referrer != null) 'referrer': referrer,
        if (characterSet != null) 'characterSet': characterSet,
        if (title != null) 'title': title,
      };
}

/// Navigator information for pixel events.
class PixelNavigator {
  /// Browser language.
  final String? language;

  /// Cookies enabled.
  final bool? cookieEnabled;

  /// Browser languages.
  final List<String>? languages;

  /// User agent string.
  final String? userAgent;

  /// Creates a pixel navigator.
  const PixelNavigator({
    this.language,
    this.cookieEnabled,
    this.languages,
    this.userAgent,
  });

  /// Creates from a map.
  factory PixelNavigator.fromMap(Map<String, dynamic> map) {
    return PixelNavigator(
      language: map['language'] as String?,
      cookieEnabled: map['cookieEnabled'] as bool?,
      languages: (map['languages'] as List?)?.cast<String>(),
      userAgent: map['userAgent'] as String?,
    );
  }

  /// Converts to map.
  Map<String, dynamic> toMap() => {
        if (language != null) 'language': language,
        if (cookieEnabled != null) 'cookieEnabled': cookieEnabled,
        if (languages != null) 'languages': languages,
        if (userAgent != null) 'userAgent': userAgent,
      };
}

/// Window information for pixel events.
class PixelWindow {
  /// Window height.
  final int? innerHeight;

  /// Window width.
  final int? innerWidth;

  /// Window origin.
  final String? origin;

  /// Outer window height.
  final int? outerHeight;

  /// Outer window width.
  final int? outerWidth;

  /// Page X offset.
  final double? pageXOffset;

  /// Page Y offset.
  final double? pageYOffset;

  /// Screen height.
  final int? screenHeight;

  /// Screen width.
  final int? screenWidth;

  /// Creates a pixel window.
  const PixelWindow({
    this.innerHeight,
    this.innerWidth,
    this.origin,
    this.outerHeight,
    this.outerWidth,
    this.pageXOffset,
    this.pageYOffset,
    this.screenHeight,
    this.screenWidth,
  });

  /// Creates from a map.
  factory PixelWindow.fromMap(Map<String, dynamic> map) {
    return PixelWindow(
      innerHeight: map['innerHeight'] as int?,
      innerWidth: map['innerWidth'] as int?,
      origin: map['origin'] as String?,
      outerHeight: map['outerHeight'] as int?,
      outerWidth: map['outerWidth'] as int?,
      pageXOffset: (map['pageXOffset'] as num?)?.toDouble(),
      pageYOffset: (map['pageYOffset'] as num?)?.toDouble(),
      screenHeight: map['screenHeight'] as int?,
      screenWidth: map['screenWidth'] as int?,
    );
  }

  /// Converts to map.
  Map<String, dynamic> toMap() => {
        if (innerHeight != null) 'innerHeight': innerHeight,
        if (innerWidth != null) 'innerWidth': innerWidth,
        if (origin != null) 'origin': origin,
        if (outerHeight != null) 'outerHeight': outerHeight,
        if (outerWidth != null) 'outerWidth': outerWidth,
        if (pageXOffset != null) 'pageXOffset': pageXOffset,
        if (pageYOffset != null) 'pageYOffset': pageYOffset,
        if (screenHeight != null) 'screenHeight': screenHeight,
        if (screenWidth != null) 'screenWidth': screenWidth,
      };
}
