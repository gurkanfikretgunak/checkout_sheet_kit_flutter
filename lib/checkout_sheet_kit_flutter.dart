/// Shopify Checkout Sheet Kit for Flutter.
///
/// A Flutter plugin that integrates Shopify's native checkout-sheet-kit
/// SDKs for Android and iOS, providing a seamless checkout experience.
///
/// ## Features
///
/// - Present Shopify checkout in a native WebView sheet
/// - Preload checkout for faster presentation
/// - Receive lifecycle events (completed, canceled, failed)
/// - Configure appearance (color scheme, tint colors)
/// - Track web pixel events
///
/// ## Usage
///
/// ```dart
/// import 'package:checkout_sheet_kit_flutter/checkout_sheet_kit_flutter.dart';
///
/// // Configure the SDK
/// await ShopifyCheckoutSheetKit.configure(
///   Configuration(
///     colorScheme: CheckoutColorScheme.automatic,
///     preloading: Preloading(enabled: true),
///   ),
/// );
///
/// // Preload checkout (optional, for faster presentation)
/// await ShopifyCheckoutSheetKit.preload(
///   url: 'https://your-store.myshopify.com/checkouts/...',
/// );
///
/// // Present checkout
/// final result = await ShopifyCheckoutSheetKit.present(
///   url: 'https://your-store.myshopify.com/checkouts/...',
///   eventHandler: CheckoutEventHandler(
///     onCheckoutCompleted: (event) {
///       print('Order completed: ${event.orderDetails.id}');
///     },
///     onCheckoutCanceled: () {
///       print('Checkout canceled');
///     },
///     onCheckoutFailed: (error) {
///       print('Checkout failed: $error');
///     },
///   ),
/// );
///
/// // Handle result
/// switch (result) {
///   case CheckoutCompletedResult(:final event):
///     print('Success! Order ID: ${event.orderDetails.id}');
///   case CheckoutCanceledResult():
///     print('User canceled checkout');
///   case CheckoutFailedResult(:final error):
///     print('Checkout failed: ${error.message}');
/// }
/// ```
library;

export 'src/checkout_sheet_kit.dart';
export 'src/models/configuration.dart';
export 'src/models/checkout_result.dart';
export 'src/models/checkout_error.dart';
export 'src/models/pixel_event.dart';
