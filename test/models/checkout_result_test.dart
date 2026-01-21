import 'package:flutter_test/flutter_test.dart';
import 'package:checkout_sheet_kit_flutter/checkout_sheet_kit_flutter.dart';

void main() {
  group('DeliveryInfo', () {
    test('parses when method and details are Strings', () {
      final info = DeliveryInfo.fromMap({
        'method': 'SHIPPING',
        'details': 'Standard Shipping (3-5 days)',
      });

      expect(info.method, 'SHIPPING');
      expect(info.details, 'Standard Shipping (3-5 days)');
    });

    test('parses when method is a Map with title', () {
      final info = DeliveryInfo.fromMap({
        'method': {'title': 'Standard Shipping', 'code': 'SHIP'},
        'details': {'description': 'Arrives in 3-5 days'},
      });

      expect(info.method, 'Standard Shipping');
      expect(info.details, isNotNull);
    });

    test('parses when method is a Map with name', () {
      final info = DeliveryInfo.fromMap({
        'method': {'name': 'Express'},
        'details': {'name': 'Next day delivery'},
      });

      expect(info.method, 'Express');
      expect(info.details, 'Next day delivery');
    });

    test('parses when method is a Map without title/name', () {
      final info = DeliveryInfo.fromMap({
        'method': {'additionalInfo': null, 'code': 'PICKUP'},
        'details': null,
      });

      expect(info.method, isNotNull); // Falls back to toString()
      expect(info.details, isNull);
    });

    test('handles null values', () {
      final info = DeliveryInfo.fromMap({
        'method': null,
        'details': null,
      });

      expect(info.method, isNull);
      expect(info.details, isNull);
    });
  });

  group('CartLineImage', () {
    test('parses legacy url format', () {
      final image = CartLineImage.fromMap({
        'url': 'https://example.com/image.jpg',
        'altText': 'Product image',
      });

      expect(image.url, 'https://example.com/image.jpg');
      expect(image.bestUrl, 'https://example.com/image.jpg');
      expect(image.altText, 'Product image');
    });

    test('parses Shopify size variants format', () {
      final image = CartLineImage.fromMap({
        'sm': 'https://cdn.shopify.com/small.jpg',
        'md': 'https://cdn.shopify.com/medium.jpg',
        'lg': 'https://cdn.shopify.com/large.jpg',
        'altText': null,
      });

      expect(image.url, isNull);
      expect(image.sm, isNotNull);
      expect(image.md, isNotNull);
      expect(image.lg, isNotNull);
      expect(image.bestUrl, 'https://cdn.shopify.com/large.jpg');
    });

    test('bestUrl prefers larger sizes', () {
      final image = CartLineImage.fromMap({
        'sm': 'small.jpg',
        'md': 'medium.jpg',
      });

      expect(image.bestUrl, 'medium.jpg'); // md preferred over sm
    });

    test('handles all null values', () {
      final image = CartLineImage.fromMap({
        'url': null,
        'altText': null,
      });

      expect(image.url, isNull);
      expect(image.bestUrl, isNull);
    });
  });

  group('PaymentMethod', () {
    test('parses when type is String', () {
      final method = PaymentMethod.fromMap({
        'type': 'CREDIT_CARD',
        'details': {'lastFour': '1234'},
      });

      expect(method.type, 'CREDIT_CARD');
      expect(method.details, isNotNull);
    });

    test('handles non-String type values', () {
      final method = PaymentMethod.fromMap({
        'type': 123,
        'details': null,
      });

      expect(method.type, '123');
    });

    test('handles null type with fallback', () {
      final method = PaymentMethod.fromMap({
        'type': null,
        'details': null,
      });

      expect(method.type, 'unknown');
    });
  });
}
