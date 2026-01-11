import 'package:flutter_test/flutter_test.dart';
import 'package:checkout_sheet_kit_flutter/checkout_sheet_kit_flutter.dart';

void main() {
  group('Configuration', () {
    test('creates with default values', () {
      const config = Configuration();
      expect(config.colorScheme, CheckoutColorScheme.automatic);
      expect(config.preloading.enabled, true);
      expect(config.errorRecovery.enabled, true);
    });

    test('toMap includes all properties', () {
      const config = Configuration(
        colorScheme: CheckoutColorScheme.dark,
        preloading: Preloading(enabled: false),
        errorRecovery: ErrorRecovery(enabled: false),
        title: 'Test Checkout',
      );

      final map = config.toMap();
      expect(map['colorScheme'], 'dark');
      expect(map['preloading']['enabled'], false);
      expect(map['errorRecovery']['enabled'], false);
      expect(map['title'], 'Test Checkout');
    });

    test('copyWith creates new instance with changes', () {
      const original = Configuration(colorScheme: CheckoutColorScheme.light);
      final copied = original.copyWith(colorScheme: CheckoutColorScheme.dark);

      expect(original.colorScheme, CheckoutColorScheme.light);
      expect(copied.colorScheme, CheckoutColorScheme.dark);
    });
  });

  group('Color', () {
    test('fromRGBA creates correct color', () {
      const color = Color.fromRGBA(255, 128, 0);
      expect(color.red, 255);
      expect(color.green, 128);
      expect(color.blue, 0);
      expect(color.alpha, 255);
    });

    test('fromHex parses RGB format', () {
      final color = Color.fromHex(0xFF8000);
      expect(color.red, 255);
      expect(color.green, 128);
      expect(color.blue, 0);
    });

    test('toHex returns correct format', () {
      const color = Color.fromRGBA(255, 128, 0, 255);
      expect(color.toHex(), '#ffff8000');
    });
  });

  group('Money', () {
    test('fromMap parses correctly', () {
      final money = Money.fromMap({
        'amount': 99.99,
        'currencyCode': 'USD',
      });

      expect(money.amount, 99.99);
      expect(money.currencyCode, 'USD');
    });

    test('toString formats correctly', () {
      const money = Money(amount: 49.99, currencyCode: 'EUR');
      expect(money.toString(), 'EUR 49.99');
    });
  });

  group('CheckoutError', () {
    test('fromMap parses all fields', () {
      final error = CheckoutError.fromMap({
        'message': 'Cart has expired',
        'code': 'cartExpired',
        'isRecoverable': true,
        'underlyingError': 'Network timeout',
      });

      expect(error.message, 'Cart has expired');
      expect(error.code, CheckoutErrorCode.cartExpired);
      expect(error.isRecoverable, true);
      expect(error.underlyingError, 'Network timeout');
    });

    test('fromMap handles unknown code', () {
      final error = CheckoutError.fromMap({
        'message': 'Something went wrong',
        'code': 'unknownCode',
        'isRecoverable': false,
      });

      expect(error.code, CheckoutErrorCode.unknown);
    });
  });

  group('CheckoutErrorCode', () {
    test('fromString parses known codes', () {
      expect(CheckoutErrorCode.fromString('cartExpired'),
          CheckoutErrorCode.cartExpired);
      expect(CheckoutErrorCode.fromString('checkoutUnavailable'),
          CheckoutErrorCode.checkoutUnavailable);
      expect(CheckoutErrorCode.fromString('configurationError'),
          CheckoutErrorCode.configurationError);
    });

    test('fromString handles case insensitivity', () {
      expect(CheckoutErrorCode.fromString('CARTEXPIRED'),
          CheckoutErrorCode.cartExpired);
      expect(CheckoutErrorCode.fromString('CartExpired'),
          CheckoutErrorCode.cartExpired);
    });

    test('fromString returns unknown for invalid codes', () {
      expect(CheckoutErrorCode.fromString('invalidCode'),
          CheckoutErrorCode.unknown);
      expect(CheckoutErrorCode.fromString(''), CheckoutErrorCode.unknown);
    });
  });

  group('OrderDetails', () {
    test('fromMap parses minimal order', () {
      final order = OrderDetails.fromMap({
        'id': 'order_123',
      });

      expect(order.id, 'order_123');
      expect(order.email, isNull);
      expect(order.cart, isNull);
    });

    test('fromMap parses full order', () {
      final order = OrderDetails.fromMap({
        'id': 'order_456',
        'email': 'test@example.com',
        'phone': '+1234567890',
        'cart': {
          'token': 'cart_token',
          'lines': [
            {
              'title': 'Test Product',
              'quantity': 2,
              'price': {'amount': 25.00, 'currencyCode': 'USD'},
            },
          ],
          'price': {
            'total': {'amount': 50.00, 'currencyCode': 'USD'},
            'subtotal': {'amount': 50.00, 'currencyCode': 'USD'},
          },
        },
      });

      expect(order.id, 'order_456');
      expect(order.email, 'test@example.com');
      expect(order.phone, '+1234567890');
      expect(order.cart, isNotNull);
      expect(order.cart!.lines.length, 1);
      expect(order.cart!.lines.first.title, 'Test Product');
    });
  });

  group('CheckoutResult', () {
    test('CheckoutCompletedResult holds event', () {
      final event = CheckoutCompletedEvent.fromMap({
        'orderDetails': {'id': 'order_789'},
      });
      final result = CheckoutCompletedResult(event: event);

      expect(result.event.orderDetails.id, 'order_789');
    });

    test('CheckoutCanceledResult is created', () {
      const result = CheckoutCanceledResult();
      expect(result, isA<CheckoutCanceledResult>());
    });

    test('CheckoutFailedResult holds error', () {
      const error = CheckoutError(
        message: 'Test error',
        code: CheckoutErrorCode.unknown,
      );
      const result = CheckoutFailedResult(error: error);

      expect(result.error.message, 'Test error');
    });
  });

  group('PixelEvent', () {
    test('fromMap creates StandardPixelEvent', () {
      final event = PixelEvent.fromMap({
        'type': 'standard',
        'name': 'page_viewed',
        'id': 'event_123',
      });

      expect(event, isA<StandardPixelEvent>());
      expect(event.name, 'page_viewed');
    });

    test('fromMap creates CustomPixelEvent', () {
      final event = PixelEvent.fromMap({
        'type': 'custom',
        'name': 'my_custom_event',
        'customData': {'key': 'value'},
      });

      expect(event, isA<CustomPixelEvent>());
      expect((event as CustomPixelEvent).customData?['key'], 'value');
    });
  });
}
