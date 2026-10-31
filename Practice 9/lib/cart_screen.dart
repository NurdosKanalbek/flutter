import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isTotalExpanded = false;

  Future<void> _confirmClear(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
          'Are you sure you want to remove all books from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (shouldClear == true && context.mounted) {
      context.read<Cart>().clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(
            tooltip: 'Clear cart',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmClear(context),
          ),
        ],
      ),
      body: Consumer<Cart>(
        builder: (context, cart, _) {
          final items = cart.items;

          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final b = items[index];
                    final qty = cart.qtyOf(b);

                    return ListTile(
                      title: Text(b.title),
                      subtitle: Text(
                        '${b.price} ₸ × $qty = ${b.price * qty} ₸',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '×$qty',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            tooltip: 'Add another copy',
                            onPressed: () => cart.increment(b),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: 'Remove from cart',
                            onPressed: () => cart.remove(b),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Card(
                margin: const EdgeInsets.all(12),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isTotalExpanded = !_isTotalExpanded;
                          });
                        },
                        child: Consumer<Cart>(
                          child: const Row(
                            children: [
                              Icon(Icons.receipt_long, color: Colors.orange),
                              SizedBox(width: 8),
                              Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          builder: (context, cartModel, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                child!,
                                Row(
                                  children: [
                                    Text(
                                      '${cartModel.total} ₸',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: Colors.orange.shade800,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      _isTotalExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      if (_isTotalExpanded) ...[
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Distinct Titles:'),
                            Text('${cart.count}'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Status:'),
                            const Text(
                              'Ready for checkout',
                              style: TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
