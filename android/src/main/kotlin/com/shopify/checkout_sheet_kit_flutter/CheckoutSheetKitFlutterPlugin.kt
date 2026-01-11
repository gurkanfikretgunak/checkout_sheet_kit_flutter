package com.shopify.checkout_sheet_kit_flutter

import android.app.Activity
import android.net.Uri
import android.webkit.PermissionRequest
import android.webkit.ValueCallback
import android.webkit.WebChromeClient.FileChooserParams
import androidx.activity.ComponentActivity
import com.shopify.checkoutsheetkit.CheckoutCompletedEvent
import com.shopify.checkoutsheetkit.CheckoutException
import com.shopify.checkoutsheetkit.ColorScheme
import com.shopify.checkoutsheetkit.DefaultCheckoutEventProcessor
import com.shopify.checkoutsheetkit.Preloading
import com.shopify.checkoutsheetkit.ShopifyCheckoutSheetKit
import com.shopify.checkoutsheetkit.pixelevents.PixelEvent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Flutter plugin for Shopify Checkout Sheet Kit.
 *
 * This plugin bridges Flutter with the native Android Shopify Checkout SDK,
 * providing methods to configure, preload, and present checkout experiences.
 */
class CheckoutSheetKitFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var pendingResult: Result? = null

    companion object {
        private const val CHANNEL_NAME = "com.shopify.checkout_sheet_kit_flutter"
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "configure" -> handleConfigure(call, result)
            "preload" -> handlePreload(call, result)
            "present" -> handlePresent(call, result)
            "invalidate" -> handleInvalidate(result)
            else -> result.notImplemented()
        }
    }

    /**
     * Configures the Shopify Checkout SDK with the provided settings.
     */
    private fun handleConfigure(call: MethodCall, result: Result) {
        try {
            val args = call.arguments as? Map<*, *> ?: run {
                result.error("INVALID_ARGS", "Configuration arguments required", null)
                return
            }

            ShopifyCheckoutSheetKit.configure { config ->
                // Color scheme
                when (args["colorScheme"] as? String) {
                    "automatic" -> config.colorScheme = ColorScheme.Automatic()
                    "light" -> config.colorScheme = ColorScheme.Light()
                    "dark" -> config.colorScheme = ColorScheme.Dark()
                    "web" -> config.colorScheme = ColorScheme.Web()
                }

                // Preloading
                @Suppress("UNCHECKED_CAST")
                (args["preloading"] as? Map<String, Any>)?.let { preloadingMap ->
                    val enabled = preloadingMap["enabled"] as? Boolean ?: true
                    config.preloading = Preloading(enabled = enabled)
                }
            }

            result.success(null)
        } catch (e: Exception) {
            result.error("CONFIGURE_ERROR", e.message, e.stackTraceToString())
        }
    }

    /**
     * Preloads checkout for faster presentation.
     */
    private fun handlePreload(call: MethodCall, result: Result) {
        try {
            val url = call.argument<String>("url") ?: run {
                result.error("INVALID_ARGS", "Checkout URL required", null)
                return
            }

            val componentActivity = activity as? ComponentActivity ?: run {
                result.error("NO_ACTIVITY", "ComponentActivity required for preload", null)
                return
            }

            ShopifyCheckoutSheetKit.preload(url, componentActivity)
            result.success(null)
        } catch (e: Exception) {
            result.error("PRELOAD_ERROR", e.message, e.stackTraceToString())
        }
    }

    /**
     * Presents the checkout sheet.
     */
    private fun handlePresent(call: MethodCall, result: Result) {
        try {
            val url = call.argument<String>("url") ?: run {
                result.error("INVALID_ARGS", "Checkout URL required", null)
                return
            }

            val componentActivity = activity as? ComponentActivity ?: run {
                result.error("NO_ACTIVITY", "ComponentActivity required for present", null)
                return
            }

            pendingResult = result

            val eventProcessor = object : DefaultCheckoutEventProcessor(componentActivity) {
                override fun onCheckoutCompleted(checkoutCompletedEvent: CheckoutCompletedEvent) {
                    val eventMap = mapCheckoutCompletedEvent(checkoutCompletedEvent)
                    
                    // Send event through channel
                    channel.invokeMethod("onCheckoutCompleted", eventMap)
                    
                    // Return result
                    pendingResult?.success(
                        mapOf(
                            "type" to "completed",
                            "event" to eventMap
                        )
                    )
                    pendingResult = null
                }

                override fun onCheckoutCanceled() {
                    // Send event through channel
                    channel.invokeMethod("onCheckoutCanceled", null)
                    
                    // Return result
                    pendingResult?.success(mapOf("type" to "canceled"))
                    pendingResult = null
                }

                override fun onCheckoutFailed(error: CheckoutException) {
                    val errorMap = mapCheckoutError(error)
                    
                    // Send event through channel
                    channel.invokeMethod("onCheckoutFailed", errorMap)
                    
                    // Return result
                    pendingResult?.success(
                        mapOf(
                            "type" to "failed",
                            "error" to errorMap
                        )
                    )
                    pendingResult = null
                }

                override fun onCheckoutLinkClicked(uri: Uri) {
                    channel.invokeMethod(
                        "onCheckoutLinkClicked",
                        mapOf("url" to uri.toString())
                    )
                }

                override fun onWebPixelEvent(event: PixelEvent) {
                    channel.invokeMethod("onWebPixelEvent", mapPixelEvent(event))
                }

                override fun onPermissionRequest(permissionRequest: PermissionRequest) {
                    // Grant camera/microphone permissions for Shop Pay
                    permissionRequest.grant(permissionRequest.resources)
                }
            }

            ShopifyCheckoutSheetKit.present(url, componentActivity, eventProcessor)
        } catch (e: Exception) {
            pendingResult?.error("PRESENT_ERROR", e.message, e.stackTraceToString())
            pendingResult = null
        }
    }

    /**
     * Invalidates any preloaded checkout.
     */
    private fun handleInvalidate(result: Result) {
        try {
            ShopifyCheckoutSheetKit.invalidate()
            result.success(null)
        } catch (e: Exception) {
            result.error("INVALIDATE_ERROR", e.message, e.stackTraceToString())
        }
    }

    /**
     * Maps CheckoutCompletedEvent to a Flutter-compatible map.
     */
    private fun mapCheckoutCompletedEvent(event: CheckoutCompletedEvent): Map<String, Any?> {
        val orderDetails = event.orderDetails
        return mapOf(
            "orderDetails" to mapOf(
                "id" to orderDetails.id,
                "email" to orderDetails.email,
                "phone" to orderDetails.phone,
                "billingAddress" to orderDetails.billingAddress?.let { address ->
                    mapOf(
                        "firstName" to address.firstName,
                        "lastName" to address.lastName,
                        "address1" to address.address1,
                        "address2" to address.address2,
                        "city" to address.city,
                        "province" to address.zoneCode,
                        "countryCode" to address.countryCode,
                        "postalCode" to address.postalCode,
                        "phone" to address.phone
                    )
                },
                "deliveries" to orderDetails.deliveries?.map { delivery ->
                    mapOf(
                        "method" to delivery.method,
                        "details" to delivery.details
                    )
                },
                "paymentMethods" to orderDetails.paymentMethods?.map { payment ->
                    mapOf(
                        "type" to payment.type,
                        "details" to payment.details
                    )
                },
                "cart" to orderDetails.cart?.let { cart ->
                    mapOf(
                        "token" to cart.token,
                        "lines" to cart.lines.map { line ->
                            mapOf(
                                "merchandiseId" to line.merchandiseId,
                                "productId" to line.productId,
                                "title" to line.title,
                                "quantity" to line.quantity,
                                "price" to mapOf(
                                    "amount" to line.price.amount,
                                    "currencyCode" to line.price.currencyCode
                                ),
                                "image" to line.image?.let { img ->
                                    mapOf(
                                        "url" to img.url,
                                        "altText" to img.altText
                                    )
                                },
                                "discounts" to line.discounts?.map { discount ->
                                    mapOf(
                                        "title" to discount.title,
                                        "amount" to discount.amount?.let {
                                            mapOf(
                                                "amount" to it.amount,
                                                "currencyCode" to it.currencyCode
                                            )
                                        }
                                    )
                                }
                            )
                        },
                        "price" to mapOf(
                            "total" to mapOf(
                                "amount" to cart.price.total.amount,
                                "currencyCode" to cart.price.total.currencyCode
                            ),
                            "subtotal" to mapOf(
                                "amount" to cart.price.subtotal.amount,
                                "currencyCode" to cart.price.subtotal.currencyCode
                            ),
                            "taxes" to cart.price.taxes?.let {
                                mapOf(
                                    "amount" to it.amount,
                                    "currencyCode" to it.currencyCode
                                )
                            },
                            "shipping" to cart.price.shipping?.let {
                                mapOf(
                                    "amount" to it.amount,
                                    "currencyCode" to it.currencyCode
                                )
                            },
                            "discounts" to cart.price.discounts?.map { discount ->
                                mapOf(
                                    "title" to discount.title,
                                    "amount" to discount.amount?.let {
                                        mapOf(
                                            "amount" to it.amount,
                                            "currencyCode" to it.currencyCode
                                        )
                                    }
                                )
                            }
                        )
                    )
                }
            )
        )
    }

    /**
     * Maps CheckoutException to a Flutter-compatible error map.
     */
    private fun mapCheckoutError(error: CheckoutException): Map<String, Any?> {
        val code = when (error) {
            is com.shopify.checkoutsheetkit.CheckoutExpiredException -> when {
                error.errorDescription?.contains("completed", ignoreCase = true) == true -> "cartCompleted"
                error.errorDescription?.contains("invalid", ignoreCase = true) == true -> "invalidCart"
                else -> "cartExpired"
            }
            is com.shopify.checkoutsheetkit.CheckoutUnavailableException -> "checkoutUnavailable"
            is com.shopify.checkoutsheetkit.ConfigurationException -> "configurationError"
            else -> "unknown"
        }

        return mapOf(
            "message" to (error.errorDescription ?: error.message ?: "Unknown error"),
            "code" to code,
            "isRecoverable" to error.isRecoverable,
            "underlyingError" to error.cause?.message
        )
    }

    /**
     * Maps PixelEvent to a Flutter-compatible map.
     */
    private fun mapPixelEvent(event: PixelEvent): Map<String, Any?> {
        return when (event) {
            is com.shopify.checkoutsheetkit.pixelevents.StandardPixelEvent -> mapOf(
                "type" to "standard",
                "name" to event.name,
                "id" to event.id,
                "timestamp" to event.timestamp,
                "context" to event.context?.let { ctx ->
                    mapOf(
                        "document" to ctx.document?.let { doc ->
                            mapOf(
                                "location" to doc.location,
                                "referrer" to doc.referrer,
                                "characterSet" to doc.characterSet,
                                "title" to doc.title
                            )
                        },
                        "navigator" to ctx.navigator?.let { nav ->
                            mapOf(
                                "language" to nav.language,
                                "cookieEnabled" to nav.cookieEnabled,
                                "languages" to nav.languages,
                                "userAgent" to nav.userAgent
                            )
                        },
                        "window" to ctx.window?.let { win ->
                            mapOf(
                                "innerHeight" to win.innerHeight,
                                "innerWidth" to win.innerWidth,
                                "origin" to win.origin,
                                "outerHeight" to win.outerHeight,
                                "outerWidth" to win.outerWidth,
                                "pageXOffset" to win.pageXOffset,
                                "pageYOffset" to win.pageYOffset,
                                "screenHeight" to win.screenHeight,
                                "screenWidth" to win.screenWidth
                            )
                        }
                    )
                },
                "data" to event.data
            )
            is com.shopify.checkoutsheetkit.pixelevents.CustomPixelEvent -> mapOf(
                "type" to "custom",
                "name" to event.name,
                "timestamp" to event.timestamp,
                "customData" to event.customData
            )
            else -> mapOf(
                "type" to "unknown",
                "name" to "unknown"
            )
        }
    }
}
