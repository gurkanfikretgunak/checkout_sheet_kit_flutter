import 'dart:async';

import 'package:flutter/services.dart';

import 'models/configuration.dart';
import 'models/checkout_result.dart';
import 'models/pixel_event.dart';

/// Main entry point for Shopify Checkout Sheet Kit.
///
/// This class provides methods to configure, preload, and present
/// Shopify checkout experiences in your Flutter app.
///
/// Example usage:
/// ```dart
/// // Configure the SDK
/// ShopifyCheckoutSheetKit.configure(
///   Configuration(
///     colorScheme: ColorScheme.automatic,
///     preloading: Preloading(enabled: true),
///   ),
/// );
///
/// // Present checkout
/// final result = await ShopifyCheckoutSheetKit.present(
///   url: 'https://your-store.myshopify.com/checkouts/...',
/// );
/// ```
class ShopifyCheckoutSheetKit {
  ShopifyCheckoutSheetKit._();

  static const MethodChannel _channel =
      MethodChannel('com.shopify.checkout_sheet_kit_flutter');

  static Configuration _configuration = Configuration();
  static CheckoutEventHandler? _eventHandler;

  /// Configures the SDK with the provided [configuration].
  ///
  /// This should be called before presenting checkout.
  /// Configuration includes color scheme, preloading settings,
  /// and platform-specific options.
  static Future<void> configure(Configuration configuration) async {
    _configuration = configuration;
    await _channel.invokeMethod('configure', configuration.toMap());
  }

  /// Gets the current SDK configuration.
  static Configuration get configuration => _configuration;

  /// Preloads the checkout at the specified [url].
  ///
  /// Call this method to warm up the checkout experience
  /// before the user is ready to check out. This reduces
  /// perceived loading time when [present] is called.
  static Future<void> preload({required String url}) async {
    await _channel.invokeMethod('preload', {'url': url});
  }

  /// Presents the checkout sheet for the specified [url].
  ///
  /// Returns a [CheckoutResult] indicating the outcome:
  /// - [CheckoutCompletedResult] when checkout succeeds
  /// - [CheckoutCanceledResult] when user dismisses checkout
  /// - [CheckoutFailedResult] when an error occurs
  ///
  /// Optionally provide an [eventHandler] to receive real-time
  /// events during the checkout process.
  static Future<CheckoutResult> present({
    required String url,
    CheckoutEventHandler? eventHandler,
  }) async {
    _eventHandler = eventHandler;

    // Set up method call handler for events from native side
    _channel.setMethodCallHandler(_handleMethodCall);

    try {
      final result = await _channel.invokeMethod('present', {'url': url});
      return _parseResult(result as Map<dynamic, dynamic>);
    } finally {
      _eventHandler = null;
    }
  }

  /// Invalidates any preloaded checkout data.
  ///
  /// Call this when the cart contents change to ensure
  /// the preloaded checkout reflects current cart state.
  static Future<void> invalidate() async {
    await _channel.invokeMethod('invalidate');
  }

  /// Handles method calls from the native platform.
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onCheckoutCompleted':
        final event = CheckoutCompletedEvent.fromMap(
          Map<String, dynamic>.from(call.arguments as Map),
        );
        _eventHandler?.onCheckoutCompleted?.call(event);
        break;

      case 'onCheckoutCanceled':
        _eventHandler?.onCheckoutCanceled?.call();
        break;

      case 'onCheckoutFailed':
        final error = CheckoutError.fromMap(
          Map<String, dynamic>.from(call.arguments as Map),
        );
        _eventHandler?.onCheckoutFailed?.call(error);
        break;

      case 'onCheckoutLinkClicked':
        final url = call.arguments['url'] as String;
        _eventHandler?.onCheckoutLinkClicked?.call(Uri.parse(url));
        break;

      case 'onWebPixelEvent':
        final event = PixelEvent.fromMap(
          Map<String, dynamic>.from(call.arguments as Map),
        );
        _eventHandler?.onWebPixelEvent?.call(event);
        break;
    }
    return null;
  }

  /// Parses the result map from native platform into a [CheckoutResult].
  static CheckoutResult _parseResult(Map<dynamic, dynamic> result) {
    final type = result['type'] as String;

    switch (type) {
      case 'completed':
        return CheckoutCompletedResult(
          event: CheckoutCompletedEvent.fromMap(
            Map<String, dynamic>.from(result['event'] as Map),
          ),
        );

      case 'canceled':
        return CheckoutCanceledResult();

      case 'failed':
        return CheckoutFailedResult(
          error: CheckoutError.fromMap(
            Map<String, dynamic>.from(result['error'] as Map),
          ),
        );

      default:
        throw StateError('Unknown checkout result type: $type');
    }
  }
}

/// Handler for checkout lifecycle events.
///
/// Provide callbacks to receive real-time updates during
/// the checkout process.
class CheckoutEventHandler {
  /// Called when checkout completes successfully.
  final void Function(CheckoutCompletedEvent event)? onCheckoutCompleted;

  /// Called when user dismisses checkout without completing.
  final void Function()? onCheckoutCanceled;

  /// Called when an error occurs during checkout.
  final void Function(CheckoutError error)? onCheckoutFailed;

  /// Called when user clicks an external link during checkout.
  final void Function(Uri url)? onCheckoutLinkClicked;

  /// Called when a web pixel event is emitted.
  final void Function(PixelEvent event)? onWebPixelEvent;

  /// Creates a checkout event handler with the specified callbacks.
  const CheckoutEventHandler({
    this.onCheckoutCompleted,
    this.onCheckoutCanceled,
    this.onCheckoutFailed,
    this.onCheckoutLinkClicked,
    this.onWebPixelEvent,
  });
}
