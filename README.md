# Shopify Checkout Sheet Kit for Flutter

[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](LICENSE)
[![pub package](https://img.shields.io/pub/v/checkout_sheet_kit_flutter.svg)](https://pub.dev/packages/checkout_sheet_kit_flutter)

<!-- Hero Image -->
<p align="center">
  <img src="https://github.com/user-attachments/assets/1f1d7351-1715-4165-874e-c1f2195bcb20" alt="Shopify Checkout Kit" width="100%" />
</p>

**Shopify's Checkout Kit for Flutter** is a plugin that enables Flutter apps to provide the world's highest converting, customizable, one-page checkout within an app. The presented experience is a fully-featured checkout that preserves all of the store customizations: Checkout UI extensions, Functions, Web Pixels, and more. It also provides idiomatic defaults such as support for light and dark mode, and convenient developer APIs to embed, customize, and follow the lifecycle of the checkout experience.

This plugin wraps the native SDKs:
- **Android**: [checkout-sheet-kit-android](https://github.com/Shopify/checkout-sheet-kit-android)
- **iOS**: [checkout-sheet-kit-swift](https://github.com/Shopify/checkout-sheet-kit-swift)

---

## Table of Contents

- [Requirements](#requirements)
- [Getting Started](#getting-started)
  - [Installation](#installation)
  - [Android Setup](#android-setup)
  - [iOS Setup](#ios-setup)
- [Basic Usage](#basic-usage)
  - [Obtaining a Checkout URL](#obtaining-a-checkout-url)
  - [Presenting Checkout](#presenting-checkout)
- [Configuration](#configuration)
  - [Color Scheme](#color-scheme)
  - [iOS-Specific Options](#ios-specific-options)
- [Preloading](#preloading)
  - [Important Considerations](#important-considerations)
  - [Flash Sales](#flash-sales)
  - [When to Preload](#when-to-preload)
  - [Cache Invalidation](#cache-invalidation)
  - [Lifecycle Management](#lifecycle-management)
- [Monitoring the Lifecycle of a Checkout Session](#monitoring-the-lifecycle-of-a-checkout-session)
  - [Checkout Completed](#checkout-completed)
  - [Checkout Canceled](#checkout-canceled)
  - [Checkout Failed](#checkout-failed)
  - [Link Clicked](#link-clicked)
- [Error Handling](#error-handling)
  - [Error Codes](#error-codes)
  - [Error Recovery](#error-recovery)
- [Integrating with Web Pixels](#integrating-with-web-pixels)
- [Integrating Identity & Customer Accounts](#integrating-identity--customer-accounts)
  - [Cart: Buyer Identity and Preferences](#cart-buyer-identity-and-preferences)
  - [Multipass](#multipass)
  - [Shop Pay](#shop-pay)
  - [Customer Account API](#customer-account-api)
- [Contributing](#contributing)
- [License](#license)

---

## Requirements

| Platform | Minimum Version |
|----------|-----------------|
| Flutter  | 3.3.0+          |
| Dart     | 3.0.0+          |
| Android  | API 23+ (Android 6.0+) |
| iOS      | 13.0+           |

---

## Getting Started

### Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  checkout_sheet_kit_flutter: ^0.0.2
```

Then run:

```bash
flutter pub get
```

### Android Setup

The plugin automatically includes the Shopify Checkout SDK via Gradle. Ensure your app's `minSdkVersion` is at least 23 in `android/app/build.gradle`:

```groovy
android {
    defaultConfig {
        minSdkVersion 23
    }
}
```

### iOS Setup

The plugin uses CocoaPods and will automatically include the ShopifyCheckoutSheetKit dependency. Ensure your iOS deployment target is at least 13.0 in `ios/Podfile`:

```ruby
platform :ios, '13.0'
```

Then run:

```bash
cd ios && pod install
```

---

## Basic Usage

### Obtaining a Checkout URL

To present a checkout to the buyer, your application must first obtain a checkout URL. The most common way is to use the [Storefront GraphQL API](https://shopify.dev/docs/api/storefront) to assemble a cart (via `cartCreate` and related update mutations) and load the [`checkoutUrl`](https://shopify.dev/docs/api/storefront/latest/objects/Cart#field-cart-checkouturl).

Alternatively, a [cart permalink](https://help.shopify.com/en/manual/products/details/cart-permalink) can be provided.

```dart
// Example using a GraphQL client to get checkout URL
final cartQuery = '''
  query GetCart(\$id: ID!) {
    cart(id: \$id) {
      checkoutUrl
    }
  }
''';

final result = await graphqlClient.query(cartQuery, variables: {'id': cartId});
final checkoutUrl = result['cart']['checkoutUrl'];
```

### Presenting Checkout

Once you have a checkout URL, present the checkout sheet:

```dart
import 'package:checkout_sheet_kit_flutter/checkout_sheet_kit_flutter.dart';

// Configure the SDK (typically done once at app startup)
await ShopifyCheckoutSheetKit.configure(
  Configuration(
    colorScheme: CheckoutColorScheme.automatic,
    preloading: Preloading(enabled: true),
  ),
);

// Present checkout
final result = await ShopifyCheckoutSheetKit.present(
  url: checkoutUrl,
  eventHandler: CheckoutEventHandler(
    onCheckoutCompleted: (event) {
      print('Order completed: ${event.orderDetails.id}');
    },
    onCheckoutCanceled: () {
      print('Checkout canceled');
    },
    onCheckoutFailed: (error) {
      print('Checkout failed: ${error.message}');
    },
  ),
);

// Handle result using pattern matching
switch (result) {
  case CheckoutCompletedResult(:final event):
    navigateToOrderConfirmation(event.orderDetails.id);
  case CheckoutCanceledResult():
    showMessage('Checkout canceled');
  case CheckoutFailedResult(:final error):
    showError(error.message);
}
```

> **💡 Tip:** To help optimize and deliver the best experience, the SDK also provides a [preloading API](#preloading) that can be used to initialize the checkout session ahead of time.

---

## Configuration

The SDK provides a way to customize the presented checkout experience via the `ShopifyCheckoutSheetKit.configure` function.

### Color Scheme

By default, the SDK will match the user's device color appearance. This behavior can be customized via the `colorScheme` property:

```dart
await ShopifyCheckoutSheetKit.configure(
  Configuration(
    // [Default] Automatically toggle light/dark themes based on device preference
    colorScheme: CheckoutColorScheme.automatic,
    
    // Force light mode
    // colorScheme: CheckoutColorScheme.light,
    
    // Force dark mode
    // colorScheme: CheckoutColorScheme.dark,
    
    // Use web theme as rendered by a mobile browser
    // colorScheme: CheckoutColorScheme.web,
  ),
);
```

| Value | Description |
|-------|-------------|
| `automatic` | Matches system appearance (light/dark mode) |
| `light` | Forces light mode |
| `dark` | Forces dark mode |
| `web` | Uses the web checkout theme colors |

### iOS-Specific Options

iOS provides additional customization options:

```dart
await ShopifyCheckoutSheetKit.configure(
  Configuration(
    colorScheme: CheckoutColorScheme.automatic,
    // iOS-specific options
    title: 'Checkout',                        // Navigation bar title
    tintColor: Color.fromRGBA(0, 122, 255),   // Tint color for UI elements
    backgroundColor: Color.fromRGBA(255, 255, 255), // Background color
  ),
);
```

| Option | Type | Description |
|--------|------|-------------|
| `title` | `String` | Navigation bar title |
| `tintColor` | `Color` | Tint color for UI elements |
| `backgroundColor` | `Color` | Background color |

---

## Preloading

Initializing a checkout session requires communicating with Shopify servers, which depending on network quality can result in undesirable waiting time for the buyer. To help optimize and deliver the best experience, the SDK provides a `preloading` "hint" that allows developers to signal that the checkout session should be initialized in the background, ahead of time.

```dart
// Enable preloading (enabled by default)
await ShopifyCheckoutSheetKit.configure(
  Configuration(
    preloading: Preloading(enabled: true),
  ),
);

// Preload a checkout URL
await ShopifyCheckoutSheetKit.preload(url: checkoutUrl);

// Later, present the preloaded checkout (will be faster)
await ShopifyCheckoutSheetKit.present(url: checkoutUrl);
```

Setting `enabled` to `false` will cause all calls to the `preload` function to be ignored:

```dart
await ShopifyCheckoutSheetKit.configure(
  Configuration(
    preloading: Preloading(enabled: false),
  ),
);

await ShopifyCheckoutSheetKit.preload(url: checkoutUrl); // no-op
```

### Important Considerations

1. **Resource usage**: Initiating preload results in background network requests and additional CPU/memory utilization for the client, and should be used when there is a high likelihood that the buyer will soon request to checkout.

2. **Cart state**: A preloaded checkout session reflects the cart contents at the time when `preload` is called. If the cart is updated after `preload` is called, the application needs to call `preload` again to reflect the updated checkout session.

3. **Not guaranteed**: Calling `preload()` is a hint, **not a guarantee**: the library may debounce or ignore calls depending on various conditions; the preload may not complete before `present()` is called, in which case the buyer may still see a loading indicator.

### Flash Sales

During Flash Sales or periods of high traffic, buyers may be entered into a queue system.

**Calls to preload which result in a buyer being enqueued will be rejected.** This means that a buyer will never enter the queue without their knowledge.

### When to Preload

Calling `preload()` each time an item is added to a buyer's cart can put significant strain on Shopify systems, which can result in rejected requests. Instead, call `preload()` when you have a strong signal that the buyer intends to check out—for example, when the buyer navigates to a "cart" screen.

### Cache Invalidation

Should you wish to manually clear the preload cache, use the `invalidate()` function:

```dart
await ShopifyCheckoutSheetKit.invalidate();
```

You may wish to do this if the buyer makes changes shortly before entering checkout, e.g., by changing cart quantity on a cart view.

### Lifecycle Management

Preloading renders a checkout in a background WebView, which is brought to foreground when `present()` is called. The content of preloaded checkout reflects the state of the cart when `preload()` was initially called.

If the cart is mutated after `preload()` is called, the application is responsible for invalidating the preloaded checkout:

1. **To update preloaded contents**: call `preload()` again
2. **To disable preloaded content**: toggle the preload configuration setting

The library will automatically invalidate/abort preload under the following conditions:
- Request results in network error or non-2XX server response code
- The checkout has successfully completed
- When `configure()` is called with new settings

> **Note**: A preloaded checkout is **not** automatically invalidated when checkout is closed. If a buyer loads the checkout then exits, the preloaded checkout is retained and should be updated when cart contents change.

---

## Monitoring the Lifecycle of a Checkout Session

Use `CheckoutEventHandler` to register callbacks for key lifecycle events during the checkout session:

```dart
final result = await ShopifyCheckoutSheetKit.present(
  url: checkoutUrl,
  eventHandler: CheckoutEventHandler(
    onCheckoutCompleted: (event) {
      // Called when checkout was completed successfully
    },
    onCheckoutCanceled: () {
      // Called when checkout was canceled by the buyer
    },
    onCheckoutFailed: (error) {
      // Called when checkout encountered an error
    },
    onCheckoutLinkClicked: (url) {
      // Called when buyer clicks a link within checkout
    },
    onWebPixelEvent: (event) {
      // Called when a web pixel event is emitted
    },
  ),
);
```

### Checkout Completed

The `onCheckoutCompleted` callback receives a `CheckoutCompletedEvent` with detailed order information:

```dart
onCheckoutCompleted: (event) {
  final order = event.orderDetails;
  
  print('Order ID: ${order.id}');
  print('Email: ${order.email}');
  print('Phone: ${order.phone}');
  
  // Cart information
  if (order.cart != null) {
    print('Total: ${order.cart!.price.total}');
    print('Subtotal: ${order.cart!.price.subtotal}');
    
    for (final line in order.cart!.lines) {
      print('${line.title} x ${line.quantity} = ${line.price}');
    }
  }
  
  // Billing address
  if (order.billingAddress != null) {
    print('Billing: ${order.billingAddress!.city}, ${order.billingAddress!.countryCode}');
  }
  
  // Payment methods
  order.paymentMethods?.forEach((payment) {
    print('Paid with: ${payment.type}');
  });
}
```

### Checkout Canceled

Called when the buyer dismisses the checkout without completing:

```dart
onCheckoutCanceled: () {
  // User canceled checkout
  // Note: This will also be received after closing a completed checkout
}
```

### Checkout Failed

Called when an error occurs during checkout:

```dart
onCheckoutFailed: (error) {
  print('Error: ${error.message}');
  print('Code: ${error.code}');
  print('Recoverable: ${error.isRecoverable}');
}
```

### Link Clicked

Called when the buyer clicks a link within checkout (email, phone, web, or deep links):

```dart
onCheckoutLinkClicked: (url) {
  // Handle links:
  // - mailto: email addresses
  // - tel: phone numbers
  // - http/https: web links
  // - custom schemes: deep links
  
  launchUrl(url);
}
```

---

## Error Handling

In the event of a checkout error occurring, the SDK may attempt to retry to recover from the error. Recovery will happen in the background by discarding the failed WebView and creating a new "recovery" instance.

### Error Codes

| Code | Description | Recommendation |
|------|-------------|----------------|
| `cartExpired` | The cart/checkout has expired | Create a new cart and checkout URL |
| `cartCompleted` | The cart was already completed | Create a new cart and checkout URL |
| `invalidCart` | The cart is invalid (e.g., empty) | Create a new cart and checkout URL |
| `checkoutUnavailable` | Checkout unavailable (network/server error) | Show checkout in a fallback WebView |
| `configurationError` | SDK configuration error | Resolve the configuration issue |
| `httpError` | Unexpected HTTP error | Show checkout in a fallback WebView |
| `unknown` | Unknown error | Show checkout in a fallback WebView |

### Error Recovery

Configure error recovery behavior:

```dart
await ShopifyCheckoutSheetKit.configure(
  Configuration(
    errorRecovery: ErrorRecovery(enabled: true), // default
  ),
);
```

When recovery is enabled, the SDK may automatically retry failed requests. Errors passed to `onCheckoutFailed` include an `isRecoverable` property indicating whether recovery was attempted.

**Caveats when recovery occurs:**
1. The checkout experience may look different to buyers
2. `onCheckoutCompleted` will be emitted with partial data (only order ID)
3. `onWebPixelEvent` will **not** be emitted

---

## Integrating with Web Pixels

[Standard](https://shopify.dev/docs/api/web-pixels-api/standard-events) and [custom](https://shopify.dev/docs/api/web-pixels-api/emitting-data) Web Pixel events will be relayed back to your application through the `onWebPixelEvent` callback.

> **⚠️ Important**: App developers should only subscribe to pixel events if they have proper levels of consent from merchants/buyers and are responsible for adherence to local regulations like GDPR and ePrivacy directive before disseminating these events to first-party and third-party systems.

```dart
onWebPixelEvent: (event) {
  if (!hasPermissionToCaptureEvents()) {
    return;
  }
  
  switch (event) {
    case StandardPixelEvent():
      // Standard events (page_viewed, checkout_started, etc.)
      print('Standard event: ${event.name}');
      print('Event ID: ${event.id}');
      print('Data: ${event.data}');
      
      // Send to analytics
      analyticsClient.track(event.name, event.data);
      
    case CustomPixelEvent():
      // Custom events
      print('Custom event: ${event.name}');
      print('Custom data: ${event.customData}');
  }
}
```

> **Note**: You may need to augment these events with customer/session information derived from app state.

---

## Integrating Identity & Customer Accounts

Buyer-aware checkout experience reduces friction and increases conversion. Depending on the context of the buyer (guest or signed-in), knowledge of buyer preferences, or account/identity system, the application can use one of the following methods to initialize a personalized buyer experience.

### Cart: Buyer Identity and Preferences

In addition to specifying line items, the Cart can include buyer identity (name, email, address, etc.) and delivery and payment preferences. See the [Storefront API guide](https://shopify.dev/docs/custom-storefronts/building-with-the-storefront-api/cart/manage) for details.

Included information will be used to present pre-filled and pre-selected choices to the buyer within checkout.

### Multipass

[Shopify Plus](https://help.shopify.com/en/manual/intro-to-shopify/pricing-plans/plans-features/shopify-plus-plan) merchants using [Classic Customer Accounts](https://help.shopify.com/en/manual/customers/customer-accounts/classic-customer-accounts) can use [Multipass](https://shopify.dev/docs/api/multipass) to integrate an external identity system and initialize a buyer-aware checkout session.

```json
{
  "email": "<Customer's email address>",
  "created_at": "<Current timestamp in ISO8601 encoding>",
  "remote_ip": "<Client IP address>",
  "return_to": "<Checkout URL obtained from Storefront API>",
  ...
}
```

1. Follow the [Multipass documentation](https://shopify.dev/docs/api/multipass) to create a Multipass URL and set the `'return_to'` to be the obtained `checkoutUrl`
2. Provide the Multipass URL to `ShopifyCheckoutSheetKit.present()`

> **⚠️ Important**: Encryption and signing should be done server-side to ensure Multipass keys are kept secret.

> **Note**: Multipass errors are not "recoverable" due to their one-time nature. Failed requests containing Multipass URLs will require re-generating new tokens.

### Shop Pay

To initialize accelerated Shop Pay checkout, the cart can set a [walletPreference](https://shopify.dev/docs/api/storefront/latest/mutations/cartBuyerIdentityUpdate#field-cartbuyeridentityinput-walletpreferences) to `'shop_pay'`. The sign-in state of the buyer is app-local and the buyer will be prompted to sign in to their Shop account on their first checkout, and their sign-in state will be remembered for future checkout sessions.

### Customer Account API

The Customer Account API allows you to authenticate buyers and provide a personalized checkout experience. For detailed implementation instructions, see the [Customer Account API Authentication Guide](https://shopify.dev/docs/storefronts/headless/mobile-apps/checkout-sheet-kit/authenticate-checkouts).

---

## Example

See the [example](example) folder for a complete sample app demonstrating:

- SDK configuration
- Checkout preloading
- Presenting checkout
- Handling all lifecycle events
- Error handling
- Web pixel event tracking

To run the example:

```bash
cd example
flutter run
```

<p align="center">
  <img src="https://via.placeholder.com/300x600?text=Example+App+Screenshot" alt="Example App" width="300" />
</p>

---

## Contributing

We welcome code contributions, feature requests, and reporting of issues. Please see our contributing guidelines before submitting a pull request.

---

## License

Shopify's Checkout Kit is provided under an [MIT License](LICENSE).
