/// Error that occurred during checkout.
class CheckoutError implements Exception {
  /// Human-readable error message.
  final String message;

  /// Error code for programmatic handling.
  final CheckoutErrorCode code;

  /// Whether recovery is possible.
  final bool isRecoverable;

  /// Underlying error (platform-specific).
  final String? underlyingError;

  /// Creates a checkout error.
  const CheckoutError({
    required this.message,
    required this.code,
    this.isRecoverable = false,
    this.underlyingError,
  });

  /// Creates from a map (for platform channel).
  factory CheckoutError.fromMap(Map<String, dynamic> map) {
    return CheckoutError(
      message: map['message'] as String,
      code: CheckoutErrorCode.fromString(map['code'] as String),
      isRecoverable: map['isRecoverable'] as bool? ?? false,
      underlyingError: map['underlyingError'] as String?,
    );
  }

  /// Converts to map.
  Map<String, dynamic> toMap() => {
        'message': message,
        'code': code.name,
        'isRecoverable': isRecoverable,
        if (underlyingError != null) 'underlyingError': underlyingError,
      };

  @override
  String toString() => 'CheckoutError($code): $message';
}

/// Error codes for checkout failures.
enum CheckoutErrorCode {
  /// The checkout/cart has expired.
  cartExpired,

  /// The checkout/cart was already completed.
  cartCompleted,

  /// The cart is invalid.
  invalidCart,

  /// Checkout is unavailable (network or server error).
  checkoutUnavailable,

  /// SDK configuration error.
  configurationError,

  /// HTTP error.
  httpError,

  /// Unknown/unspecified error.
  unknown;

  /// Creates from a string value.
  static CheckoutErrorCode fromString(String value) {
    return CheckoutErrorCode.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => CheckoutErrorCode.unknown,
    );
  }
}
