import 'checkout_error.dart';

export 'checkout_error.dart';

/// Result of a checkout operation.
sealed class CheckoutResult {
  const CheckoutResult();
}

/// Checkout completed successfully.
class CheckoutCompletedResult extends CheckoutResult {
  /// Details about the completed checkout.
  final CheckoutCompletedEvent event;

  /// Creates a completed result.
  const CheckoutCompletedResult({required this.event});
}

/// User canceled/dismissed the checkout.
class CheckoutCanceledResult extends CheckoutResult {
  /// Creates a canceled result.
  const CheckoutCanceledResult();
}

/// Checkout failed with an error.
class CheckoutFailedResult extends CheckoutResult {
  /// The error that caused the failure.
  final CheckoutError error;

  /// Creates a failed result.
  const CheckoutFailedResult({required this.error});
}

/// Event emitted when checkout completes successfully.
class CheckoutCompletedEvent {
  /// Details about the completed order.
  final OrderDetails orderDetails;

  /// Creates a checkout completed event.
  const CheckoutCompletedEvent({required this.orderDetails});

  /// Creates from a map (for platform channel).
  factory CheckoutCompletedEvent.fromMap(Map<String, dynamic> map) {
    return CheckoutCompletedEvent(
      orderDetails: OrderDetails.fromMap(
        Map<String, dynamic>.from(map['orderDetails'] as Map),
      ),
    );
  }

  /// Converts to map.
  Map<String, dynamic> toMap() => {'orderDetails': orderDetails.toMap()};
}

/// Details about a completed order.
class OrderDetails {
  /// The order ID.
  final String id;

  /// Customer email address.
  final String? email;

  /// Customer phone number.
  final String? phone;

  /// Billing address.
  final Address? billingAddress;

  /// Delivery information.
  final List<DeliveryInfo>? deliveries;

  /// Payment methods used.
  final List<PaymentMethod>? paymentMethods;

  /// Cart information.
  final CartInfo? cart;

  /// Creates order details.
  const OrderDetails({
    required this.id,
    this.email,
    this.phone,
    this.billingAddress,
    this.deliveries,
    this.paymentMethods,
    this.cart,
  });

  /// Creates from a map.
  factory OrderDetails.fromMap(Map<String, dynamic> map) {
    return OrderDetails(
      id: map['id'] as String,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      billingAddress: map['billingAddress'] != null
          ? Address.fromMap(
              Map<String, dynamic>.from(map['billingAddress'] as Map))
          : null,
      deliveries: (map['deliveries'] as List?)
          ?.map(
              (e) => DeliveryInfo.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      paymentMethods: (map['paymentMethods'] as List?)
          ?.map(
              (e) => PaymentMethod.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      cart: map['cart'] != null
          ? CartInfo.fromMap(Map<String, dynamic>.from(map['cart'] as Map))
          : null,
    );
  }

  /// Converts to map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (billingAddress != null) 'billingAddress': billingAddress!.toMap(),
      if (deliveries != null)
        'deliveries': deliveries!.map((e) => e.toMap()).toList(),
      if (paymentMethods != null)
        'paymentMethods': paymentMethods!.map((e) => e.toMap()).toList(),
      if (cart != null) 'cart': cart!.toMap(),
    };
  }
}

/// Physical address information.
class Address {
  /// First name.
  final String? firstName;

  /// Last name.
  final String? lastName;

  /// Street address line 1.
  final String? address1;

  /// Street address line 2.
  final String? address2;

  /// City.
  final String? city;

  /// State/Province/Region.
  final String? province;

  /// Country code.
  final String? countryCode;

  /// Postal/ZIP code.
  final String? postalCode;

  /// Phone number.
  final String? phone;

  /// Creates an address.
  const Address({
    this.firstName,
    this.lastName,
    this.address1,
    this.address2,
    this.city,
    this.province,
    this.countryCode,
    this.postalCode,
    this.phone,
  });

  /// Creates from a map.
  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      firstName: map['firstName'] as String?,
      lastName: map['lastName'] as String?,
      address1: map['address1'] as String?,
      address2: map['address2'] as String?,
      city: map['city'] as String?,
      province: map['province'] as String?,
      countryCode: map['countryCode'] as String?,
      postalCode: map['postalCode'] as String?,
      phone: map['phone'] as String?,
    );
  }

  /// Converts to map.
  Map<String, dynamic> toMap() {
    return {
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (address1 != null) 'address1': address1,
      if (address2 != null) 'address2': address2,
      if (city != null) 'city': city,
      if (province != null) 'province': province,
      if (countryCode != null) 'countryCode': countryCode,
      if (postalCode != null) 'postalCode': postalCode,
      if (phone != null) 'phone': phone,
    };
  }
}

/// Delivery information.
class DeliveryInfo {
  /// Delivery method (e.g., "SHIPPING", "PICKUP").
  final String? method;

  /// Delivery details/description.
  final String? details;

  /// Creates delivery info.
  const DeliveryInfo({this.method, this.details});

  /// Creates from a map.
  factory DeliveryInfo.fromMap(Map<String, dynamic> map) {
    return DeliveryInfo(
      method: map['method'] as String?,
      details: map['details'] as String?,
    );
  }

  /// Converts to map.
  Map<String, dynamic> toMap() => {
        if (method != null) 'method': method,
        if (details != null) 'details': details,
      };
}

/// Payment method information.
class PaymentMethod {
  /// Payment type (e.g., "CREDIT_CARD", "SHOP_PAY").
  final String type;

  /// Additional details about the payment method.
  final Map<String, dynamic>? details;

  /// Creates a payment method.
  const PaymentMethod({required this.type, this.details});

  /// Creates from a map.
  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      type: map['type'] as String,
      details: map['details'] != null
          ? Map<String, dynamic>.from(map['details'] as Map)
          : null,
    );
  }

  /// Converts to map.
  Map<String, dynamic> toMap() => {
        'type': type,
        if (details != null) 'details': details,
      };
}

/// Shopping cart information.
class CartInfo {
  /// Cart token.
  final String token;

  /// Cart line items.
  final List<CartLine> lines;

  /// Price breakdown.
  final CartPrice price;

  /// Creates cart info.
  const CartInfo({
    required this.token,
    required this.lines,
    required this.price,
  });

  /// Creates from a map.
  factory CartInfo.fromMap(Map<String, dynamic> map) {
    return CartInfo(
      token: map['token'] as String,
      lines: (map['lines'] as List)
          .map((e) => CartLine.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      price: CartPrice.fromMap(Map<String, dynamic>.from(map['price'] as Map)),
    );
  }

  /// Converts to map.
  Map<String, dynamic> toMap() => {
        'token': token,
        'lines': lines.map((e) => e.toMap()).toList(),
        'price': price.toMap(),
      };
}

/// Individual cart line item.
class CartLine {
  /// Merchandise/variant ID.
  final String? merchandiseId;

  /// Product ID.
  final String? productId;

  /// Line item title.
  final String title;

  /// Quantity.
  final int quantity;

  /// Item price.
  final Money price;

  /// Product image.
  final CartLineImage? image;

  /// Applied discounts.
  final List<Discount>? discounts;

  /// Creates a cart line.
  const CartLine({
    this.merchandiseId,
    this.productId,
    required this.title,
    required this.quantity,
    required this.price,
    this.image,
    this.discounts,
  });

  /// Creates from a map.
  factory CartLine.fromMap(Map<String, dynamic> map) {
    return CartLine(
      merchandiseId: map['merchandiseId'] as String?,
      productId: map['productId'] as String?,
      title: map['title'] as String,
      quantity: map['quantity'] as int,
      price: Money.fromMap(Map<String, dynamic>.from(map['price'] as Map)),
      image: map['image'] != null
          ? CartLineImage.fromMap(
              Map<String, dynamic>.from(map['image'] as Map))
          : null,
      discounts: (map['discounts'] as List?)
          ?.map((e) => Discount.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  /// Converts to map.
  Map<String, dynamic> toMap() => {
        if (merchandiseId != null) 'merchandiseId': merchandiseId,
        if (productId != null) 'productId': productId,
        'title': title,
        'quantity': quantity,
        'price': price.toMap(),
        if (image != null) 'image': image!.toMap(),
        if (discounts != null)
          'discounts': discounts!.map((e) => e.toMap()).toList(),
      };
}

/// Cart line item image.
class CartLineImage {
  /// Image URL.
  final String url;

  /// Alt text.
  final String? altText;

  /// Creates a cart line image.
  const CartLineImage({required this.url, this.altText});

  /// Creates from a map.
  factory CartLineImage.fromMap(Map<String, dynamic> map) {
    return CartLineImage(
      url: map['url'] as String,
      altText: map['altText'] as String?,
    );
  }

  /// Converts to map.
  Map<String, dynamic> toMap() => {
        'url': url,
        if (altText != null) 'altText': altText,
      };
}

/// Cart price breakdown.
class CartPrice {
  /// Total price.
  final Money total;

  /// Subtotal (before taxes/shipping).
  final Money subtotal;

  /// Tax amount.
  final Money? taxes;

  /// Shipping cost.
  final Money? shipping;

  /// Applied discounts.
  final List<Discount>? discounts;

  /// Creates cart price.
  const CartPrice({
    required this.total,
    required this.subtotal,
    this.taxes,
    this.shipping,
    this.discounts,
  });

  /// Creates from a map.
  factory CartPrice.fromMap(Map<String, dynamic> map) {
    return CartPrice(
      total: Money.fromMap(Map<String, dynamic>.from(map['total'] as Map)),
      subtotal:
          Money.fromMap(Map<String, dynamic>.from(map['subtotal'] as Map)),
      taxes: map['taxes'] != null
          ? Money.fromMap(Map<String, dynamic>.from(map['taxes'] as Map))
          : null,
      shipping: map['shipping'] != null
          ? Money.fromMap(Map<String, dynamic>.from(map['shipping'] as Map))
          : null,
      discounts: (map['discounts'] as List?)
          ?.map((e) => Discount.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  /// Converts to map.
  Map<String, dynamic> toMap() => {
        'total': total.toMap(),
        'subtotal': subtotal.toMap(),
        if (taxes != null) 'taxes': taxes!.toMap(),
        if (shipping != null) 'shipping': shipping!.toMap(),
        if (discounts != null)
          'discounts': discounts!.map((e) => e.toMap()).toList(),
      };
}

/// Money amount with currency.
class Money {
  /// Numeric amount.
  final double amount;

  /// Currency code (e.g., "USD", "EUR").
  final String currencyCode;

  /// Creates a money value.
  const Money({required this.amount, required this.currencyCode});

  /// Creates from a map.
  factory Money.fromMap(Map<String, dynamic> map) {
    return Money(
      amount: (map['amount'] as num).toDouble(),
      currencyCode: map['currencyCode'] as String,
    );
  }

  /// Converts to map.
  Map<String, dynamic> toMap() => {
        'amount': amount,
        'currencyCode': currencyCode,
      };

  @override
  String toString() => '$currencyCode $amount';
}

/// Discount information.
class Discount {
  /// Discount title.
  final String? title;

  /// Discount amount.
  final Money? amount;

  /// Creates a discount.
  const Discount({this.title, this.amount});

  /// Creates from a map.
  factory Discount.fromMap(Map<String, dynamic> map) {
    return Discount(
      title: map['title'] as String?,
      amount: map['amount'] != null
          ? Money.fromMap(Map<String, dynamic>.from(map['amount'] as Map))
          : null,
    );
  }

  /// Converts to map.
  Map<String, dynamic> toMap() => {
        if (title != null) 'title': title,
        if (amount != null) 'amount': amount!.toMap(),
      };
}
