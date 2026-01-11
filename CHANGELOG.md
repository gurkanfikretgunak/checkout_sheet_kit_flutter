# Changelog

All notable changes to this project will be documented in this file.

## 0.0.1

Initial release of Shopify Checkout Sheet Kit for Flutter.

### Features

- **Present Checkout**: Display Shopify checkout in a native WebView sheet on Android and iOS
- **Preloading**: Preload checkout sessions for faster presentation
- **Configuration**: Customize checkout appearance with color schemes (automatic, light, dark, web)
- **iOS Customization**: Additional iOS-specific options (tint color, background color, navigation title)
- **Lifecycle Events**: 
  - `onCheckoutCompleted` - Receive detailed order information when checkout succeeds
  - `onCheckoutCanceled` - Handle user dismissal of checkout
  - `onCheckoutFailed` - Handle checkout errors with error codes and recovery info
  - `onCheckoutLinkClicked` - Handle external link clicks (mailto, tel, http, deep links)
  - `onWebPixelEvent` - Receive standard and custom web pixel events for analytics
- **Error Recovery**: Automatic error recovery with configurable behavior
- **Cache Invalidation**: Invalidate preloaded checkout when cart changes

### Platform Support

- Android: API 23+ (Android 6.0+)
- iOS: 13.0+

### Native SDK Versions

- Android: checkout-sheet-kit 3.0.5
- iOS: ShopifyCheckoutSheetKit ~> 3.0
