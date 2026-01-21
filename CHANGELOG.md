# Changelog

All notable changes to this project will be documented in this file.

## 0.0.3

### Fixed
- `DeliveryInfo.fromMap()` now handles cases where Shopify returns `method` and `details` as Maps instead of Strings
- `CartLineImage.fromMap()` now handles Shopify's actual image format with `sm`, `md`, `lg` size variants instead of just `url`
- `PaymentMethod.fromMap()` now handles non-String `type` values defensively

### Added
- `CartLineImage.bestUrl` getter that returns the best available image URL (prefers larger sizes)
- `CartLineImage.sm`, `CartLineImage.md`, `CartLineImage.lg` fields for Shopify's size variant format

---

## 0.0.2

### Improvements

- Improved iOS view controller detection using modern Scene-based API
- Added debug logging for easier troubleshooting
- Fixed type mapping for all Shopify SDK data structures
- Better error handling and recovery

### Bug Fixes

- Fixed `DiscountValue` type mapping (now uses `Value`)
- Fixed `Location` object serialization
- Fixed `StandardEventData` serialization for web pixel events
- Fixed expression complexity in Swift plugin

---

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
