import 'package:flutter/material.dart';
import 'package:checkout_sheet_kit_flutter/checkout_sheet_kit_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checkout Sheet Kit Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CheckoutDemoPage(),
    );
  }
}

class CheckoutDemoPage extends StatefulWidget {
  const CheckoutDemoPage({super.key});

  @override
  State<CheckoutDemoPage> createState() => _CheckoutDemoPageState();
}

class _CheckoutDemoPageState extends State<CheckoutDemoPage> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  String _statusMessage = 'Ready to checkout';
  final List<String> _eventLog = [];

  @override
  void initState() {
    super.initState();
    _configureCheckout();

    // Set a sample checkout URL for testing
    _urlController.text = 'https://your-store.myshopify.com/checkouts/sample';
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  /// Configure the Shopify Checkout SDK.
  Future<void> _configureCheckout() async {
    try {
      await ShopifyCheckoutSheetKit.configure(
        const Configuration(
          colorScheme: CheckoutColorScheme.automatic,
          preloading: Preloading(enabled: true),
          errorRecovery: ErrorRecovery(enabled: true),
          // iOS-specific customization
          title: 'Checkout',
        ),
      );
      _addEventLog('SDK configured successfully');
    } catch (e) {
      _addEventLog('Configuration error: $e');
    }
  }

  /// Preload the checkout URL.
  Future<void> _preloadCheckout() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showSnackBar('Please enter a checkout URL');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ShopifyCheckoutSheetKit.preload(url: url);
      _addEventLog('Checkout preloaded');
      _showSnackBar('Checkout preloaded successfully');
    } catch (e) {
      _addEventLog('Preload error: $e');
      _showSnackBar('Failed to preload: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Present the checkout sheet.
  Future<void> _presentCheckout() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showSnackBar('Please enter a checkout URL');
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Opening checkout...';
    });

    try {
      final result = await ShopifyCheckoutSheetKit.present(
        url: url,
        eventHandler: CheckoutEventHandler(
          onCheckoutCompleted: (event) {
            _addEventLog(
                '✅ Checkout completed: Order ${event.orderDetails.id}');
            if (event.orderDetails.email != null) {
              _addEventLog('   Email: ${event.orderDetails.email}');
            }
            if (event.orderDetails.cart != null) {
              _addEventLog('   Total: ${event.orderDetails.cart!.price.total}');
            }
          },
          onCheckoutCanceled: () {
            _addEventLog('❌ Checkout canceled by user');
          },
          onCheckoutFailed: (error) {
            _addEventLog('⚠️ Checkout failed: ${error.message}');
            _addEventLog('   Code: ${error.code.name}');
            _addEventLog('   Recoverable: ${error.isRecoverable}');
          },
          onCheckoutLinkClicked: (url) {
            _addEventLog('🔗 Link clicked: $url');
          },
          onWebPixelEvent: (event) {
            _addEventLog('📊 Pixel event: ${event.name}');
          },
        ),
      );

      // Handle the final result
      switch (result) {
        case CheckoutCompletedResult(:final event):
          setState(() {
            _statusMessage = 'Order completed: ${event.orderDetails.id}';
          });
          _showSnackBar('Order placed successfully!');

        case CheckoutCanceledResult():
          setState(() {
            _statusMessage = 'Checkout canceled';
          });

        case CheckoutFailedResult(:final error):
          setState(() {
            _statusMessage = 'Checkout failed: ${error.message}';
          });
          _showSnackBar('Checkout failed: ${error.message}');
      }
    } catch (e) {
      _addEventLog('Error: $e');
      setState(() {
        _statusMessage = 'Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Invalidate preloaded checkout data.
  Future<void> _invalidateCheckout() async {
    try {
      await ShopifyCheckoutSheetKit.invalidate();
      _addEventLog('Checkout cache invalidated');
      _showSnackBar('Checkout cache cleared');
    } catch (e) {
      _addEventLog('Invalidate error: $e');
    }
  }

  void _addEventLog(String message) {
    setState(() {
      _eventLog.insert(0,
          '[${DateTime.now().toIso8601String().substring(11, 19)}] $message');
      // Keep only last 50 events
      if (_eventLog.length > 50) {
        _eventLog.removeLast();
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _clearEventLog() {
    setState(() {
      _eventLog.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Checkout Sheet Kit Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearEventLog,
            tooltip: 'Clear event log',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        _isLoading ? Icons.hourglass_empty : Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _statusMessage,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      if (_isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // URL input
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Checkout URL',
                  hintText: 'https://your-store.myshopify.com/checkouts/...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _preloadCheckout,
                      icon: const Icon(Icons.downloading),
                      label: const Text('Preload'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _invalidateCheckout,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Invalidate'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Main checkout button
              FilledButton.icon(
                onPressed: _isLoading ? null : _presentCheckout,
                icon: const Icon(Icons.shopping_cart_checkout),
                label: const Text('Present Checkout'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),

              // Event log header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Event Log',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${_eventLog.length} events',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Event log list
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _eventLog.isEmpty
                      ? const Center(
                          child: Text(
                            'No events yet.\nTry preloading or presenting checkout.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _eventLog.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                _eventLog[index],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontFamily: 'monospace',
                                    ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
