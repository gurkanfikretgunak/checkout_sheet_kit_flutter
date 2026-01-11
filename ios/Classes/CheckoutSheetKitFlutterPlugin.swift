import Flutter
import UIKit
import ShopifyCheckoutSheetKit

/// Flutter plugin for Shopify Checkout Sheet Kit.
///
/// This plugin bridges Flutter with the native iOS Shopify Checkout SDK,
/// providing methods to configure, preload, and present checkout experiences.
public class CheckoutSheetKitFlutterPlugin: NSObject, FlutterPlugin {
    
    private let channel: FlutterMethodChannel
    private var pendingResult: FlutterResult?
    private weak var viewController: UIViewController?
    
    private static let channelName = "com.shopify.checkout_sheet_kit_flutter"
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: registrar.messenger()
        )
        let instance = CheckoutSheetKitFlutterPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // Get the root view controller
        if let appDelegate = UIApplication.shared.delegate,
           let window = appDelegate.window,
           let rootViewController = window?.rootViewController {
            instance.viewController = rootViewController
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "configure":
            handleConfigure(call: call, result: result)
        case "preload":
            handlePreload(call: call, result: result)
        case "present":
            handlePresent(call: call, result: result)
        case "invalidate":
            handleInvalidate(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Method Handlers
    
    /// Configures the Shopify Checkout SDK with the provided settings.
    private func handleConfigure(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(
                code: "INVALID_ARGS",
                message: "Configuration arguments required",
                details: nil
            ))
            return
        }
        
        ShopifyCheckoutSheetKit.configure { config in
            // Color scheme
            if let colorScheme = args["colorScheme"] as? String {
                switch colorScheme {
                case "automatic":
                    config.colorScheme = .automatic
                case "light":
                    config.colorScheme = .light
                case "dark":
                    config.colorScheme = .dark
                case "web":
                    config.colorScheme = .web
                default:
                    break
                }
            }
            
            // Preloading
            if let preloadingMap = args["preloading"] as? [String: Any],
               let enabled = preloadingMap["enabled"] as? Bool {
                config.preloading.enabled = enabled
            }
            
            // iOS-specific: Tint color
            if let tintColorHex = args["tintColor"] as? String {
                config.tintColor = UIColor(hex: tintColorHex)
            }
            
            // iOS-specific: Background color
            if let backgroundColorHex = args["backgroundColor"] as? String {
                config.backgroundColor = UIColor(hex: backgroundColorHex)
            }
            
            // iOS-specific: Title
            if let title = args["title"] as? String {
                config.title = title
            }
        }
        
        result(nil)
    }
    
    /// Preloads checkout for faster presentation.
    private func handlePreload(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let urlString = args["url"] as? String,
              let url = URL(string: urlString) else {
            result(FlutterError(
                code: "INVALID_ARGS",
                message: "Valid checkout URL required",
                details: nil
            ))
            return
        }
        
        ShopifyCheckoutSheetKit.preload(checkout: url)
        result(nil)
    }
    
    /// Presents the checkout sheet.
    private func handlePresent(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let urlString = args["url"] as? String,
              let url = URL(string: urlString) else {
            result(FlutterError(
                code: "INVALID_ARGS",
                message: "Valid checkout URL required",
                details: nil
            ))
            return
        }
        
        // Get the presenting view controller
        var presentingVC = viewController
        if presentingVC == nil {
            presentingVC = UIApplication.shared.windows.first?.rootViewController
        }
        
        // Find the topmost presented view controller
        while let presented = presentingVC?.presentedViewController {
            presentingVC = presented
        }
        
        guard let vc = presentingVC else {
            result(FlutterError(
                code: "NO_VIEW_CONTROLLER",
                message: "No view controller available for presentation",
                details: nil
            ))
            return
        }
        
        pendingResult = result
        
        ShopifyCheckoutSheetKit.present(
            checkout: url,
            from: vc,
            delegate: self
        )
    }
    
    /// Invalidates any preloaded checkout.
    private func handleInvalidate(result: @escaping FlutterResult) {
        ShopifyCheckoutSheetKit.invalidate()
        result(nil)
    }
}

// MARK: - CheckoutDelegate

extension CheckoutSheetKitFlutterPlugin: CheckoutDelegate {
    
    public func checkoutDidComplete(event: CheckoutCompletedEvent) {
        let eventMap = mapCheckoutCompletedEvent(event)
        
        // Send event through channel
        channel.invokeMethod("onCheckoutCompleted", arguments: eventMap)
        
        // Return result
        pendingResult?([
            "type": "completed",
            "event": eventMap
        ])
        pendingResult = nil
    }
    
    public func checkoutDidCancel() {
        // Send event through channel
        channel.invokeMethod("onCheckoutCanceled", arguments: nil)
        
        // Return result
        pendingResult?(["type": "canceled"])
        pendingResult = nil
    }
    
    public func checkoutDidFail(error: CheckoutError) {
        let errorMap = mapCheckoutError(error)
        
        // Send event through channel
        channel.invokeMethod("onCheckoutFailed", arguments: errorMap)
        
        // Return result
        pendingResult?([
            "type": "failed",
            "error": errorMap
        ])
        pendingResult = nil
    }
    
    public func shouldRecoverFromError(error: CheckoutError) -> Bool {
        return error.isRecoverable
    }
    
    public func checkoutDidClickLink(url: URL) {
        channel.invokeMethod("onCheckoutLinkClicked", arguments: ["url": url.absoluteString])
    }
    
    public func checkoutDidEmitWebPixelEvent(event: PixelEvent) {
        channel.invokeMethod("onWebPixelEvent", arguments: mapPixelEvent(event))
    }
}

// MARK: - Mapping Helpers

extension CheckoutSheetKitFlutterPlugin {
    
    /// Maps CheckoutCompletedEvent to a Flutter-compatible dictionary.
    private func mapCheckoutCompletedEvent(_ event: CheckoutCompletedEvent) -> [String: Any?] {
        let orderDetails = event.orderDetails
        return [
            "orderDetails": mapOrderDetails(orderDetails)
        ]
    }
    
    private func mapOrderDetails(_ orderDetails: CheckoutCompletedEvent.OrderDetails) -> [String: Any?] {
        return [
            "id": orderDetails.id,
            "email": orderDetails.email,
            "phone": orderDetails.phone,
            "billingAddress": mapAddress(orderDetails.billingAddress),
            "deliveries": orderDetails.deliveries?.map { mapDelivery($0) },
            "paymentMethods": orderDetails.paymentMethods?.map { mapPaymentMethod($0) },
            "cart": mapCart(orderDetails.cart)
        ]
    }
    
    private func mapAddress(_ address: CheckoutCompletedEvent.Address?) -> [String: Any?]? {
        guard let address = address else { return nil }
        return [
            "firstName": address.firstName,
            "lastName": address.lastName,
            "address1": address.address1,
            "address2": address.address2,
            "city": address.city,
            "province": address.zoneCode,
            "countryCode": address.countryCode,
            "postalCode": address.postalCode,
            "phone": address.phone
        ]
    }
    
    private func mapDelivery(_ delivery: CheckoutCompletedEvent.DeliveryInfo) -> [String: Any?] {
        return [
            "method": delivery.method,
            "details": [
                "name": delivery.details.name,
                "additionalInfo": delivery.details.additionalInfo
            ] as [String: Any?]
        ]
    }
    
    private func mapPaymentMethod(_ payment: CheckoutCompletedEvent.PaymentMethod) -> [String: Any?] {
        return [
            "type": payment.type,
            "details": payment.details
        ]
    }
    
    private func mapCart(_ cart: CheckoutCompletedEvent.CartInfo) -> [String: Any?] {
        return [
            "token": cart.token,
            "lines": cart.lines.map { mapCartLine($0) },
            "price": mapCartPrice(cart.price)
        ]
    }
    
    private func mapCartLine(_ line: CheckoutCompletedEvent.CartLine) -> [String: Any?] {
        return [
            "merchandiseId": line.merchandiseId,
            "productId": line.productId,
            "title": line.title,
            "quantity": line.quantity,
            "price": [
                "amount": line.price.amount,
                "currencyCode": line.price.currencyCode
            ],
            "image": line.image.map { [
                "sm": $0.sm,
                "md": $0.md,
                "lg": $0.lg,
                "altText": $0.altText
            ] as [String: Any?] },
            "discounts": line.discounts?.map { mapDiscount($0) }
        ]
    }
    
    private func mapCartPrice(_ price: CheckoutCompletedEvent.Price) -> [String: Any?] {
        return [
            "total": price.total.map { [
                "amount": $0.amount,
                "currencyCode": $0.currencyCode
            ] },
            "subtotal": price.subtotal.map { [
                "amount": $0.amount,
                "currencyCode": $0.currencyCode
            ] },
            "taxes": price.taxes.map { [
                "amount": $0.amount,
                "currencyCode": $0.currencyCode
            ] },
            "shipping": price.shipping.map { [
                "amount": $0.amount,
                "currencyCode": $0.currencyCode
            ] },
            "discounts": price.discounts?.map { mapDiscount($0) }
        ]
    }
    
    private func mapDiscount(_ discount: CheckoutCompletedEvent.Discount) -> [String: Any?] {
        return [
            "title": discount.title,
            "amount": discount.amount.map { [
                "amount": $0.amount,
                "currencyCode": $0.currencyCode
            ] }
        ]
    }
    
    /// Maps CheckoutError to a Flutter-compatible dictionary.
    private func mapCheckoutError(_ error: CheckoutError) -> [String: Any?] {
        let code: String
        let message: String
        
        switch error {
        case .checkoutExpired(let msg, let errorCode, _):
            message = msg
            switch errorCode {
            case .cartCompleted:
                code = "cartCompleted"
            case .invalidCart:
                code = "invalidCart"
            default:
                code = "cartExpired"
            }
        case .checkoutUnavailable(let msg, _, _):
            message = msg
            code = "checkoutUnavailable"
        case .configurationError(let msg, _, _):
            message = msg
            code = "configurationError"
        case .sdkError(let underlying, _):
            message = underlying.localizedDescription
            code = "unknown"
        @unknown default:
            message = "Unknown error"
            code = "unknown"
        }
        
        return [
            "message": message,
            "code": code,
            "isRecoverable": error.isRecoverable,
            "underlyingError": nil
        ]
    }
    
    /// Maps PixelEvent to a Flutter-compatible dictionary.
    private func mapPixelEvent(_ event: PixelEvent) -> [String: Any?] {
        switch event {
        case .standardEvent(let standardEvent):
            return [
                "type": "standard",
                "name": standardEvent.name ?? "unknown",
                "id": standardEvent.id,
                "timestamp": standardEvent.timestamp,
                "context": standardEvent.context.map { ctx in
                    [
                        "document": ctx.document.map { doc in
                            [
                                "location": doc.location,
                                "referrer": doc.referrer,
                                "characterSet": doc.characterSet,
                                "title": doc.title
                            ] as [String: Any?]
                        },
                        "navigator": ctx.navigator.map { nav in
                            [
                                "language": nav.language,
                                "cookieEnabled": nav.cookieEnabled,
                                "languages": nav.languages,
                                "userAgent": nav.userAgent
                            ] as [String: Any?]
                        },
                        "window": ctx.window.map { win in
                            [
                                "innerHeight": win.innerHeight,
                                "innerWidth": win.innerWidth,
                                "origin": win.origin,
                                "outerHeight": win.outerHeight,
                                "outerWidth": win.outerWidth,
                                "pageXOffset": win.pageXOffset,
                                "pageYOffset": win.pageYOffset,
                                "screenX": win.screenX,
                                "screenY": win.screenY,
                                "screenHeight": win.screen?.height,
                                "screenWidth": win.screen?.width
                            ] as [String: Any?]
                        }
                    ] as [String: Any?]
                },
                "data": standardEvent.data
            ]
        case .customEvent(let customEvent):
            return [
                "type": "custom",
                "name": customEvent.name ?? "unknown",
                "timestamp": customEvent.timestamp,
                "customData": customEvent.customData
            ]
        @unknown default:
            return [
                "type": "unknown",
                "name": "unknown"
            ]
        }
    }
}

// MARK: - UIColor Extension

extension UIColor {
    /// Creates a UIColor from a hex string (e.g., "#AARRGGBB" or "#RRGGBB").
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)
        
        let alpha, red, green, blue: CGFloat
        
        if hexString.count == 8 {
            // AARRGGBB format
            alpha = CGFloat((rgb >> 24) & 0xFF) / 255.0
            red = CGFloat((rgb >> 16) & 0xFF) / 255.0
            green = CGFloat((rgb >> 8) & 0xFF) / 255.0
            blue = CGFloat(rgb & 0xFF) / 255.0
        } else {
            // RRGGBB format
            alpha = 1.0
            red = CGFloat((rgb >> 16) & 0xFF) / 255.0
            green = CGFloat((rgb >> 8) & 0xFF) / 255.0
            blue = CGFloat(rgb & 0xFF) / 255.0
        }
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
