import 'package:flutter/material.dart';
import '../ac_action_registry.dart';
import '../ac_screen_context.dart';

Widget buildPosCartElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final bindKey = p['bind']?.toString() ?? 'cart';
  final cart = ctx.get(bindKey) as Map? ?? {};
  final items = cart['items'] as List? ?? [];
  final num grandTotal = cart['grandTotal'] as num? ?? 0;

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Cart', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('${items.length} items', style: const TextStyle(color: Colors.grey)),
          ],
        ),
        const Divider(),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('Cart is empty', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, idx) {
                    final item = items[idx] as Map;
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(item['name']?.toString() ?? ''),
                      subtitle: Text('${item['qty']} x ₹${item['rate']}'),
                      trailing: Text('₹${item['amount']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  },
                ),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Grand Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('₹${grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
          ],
        ),
      ],
    ),
  );
}

Widget buildPosProductGridElement(Map<String, dynamic> p, AcScreenContext ctx) {
  final rawProducts = ctx.get(p['bind']?.toString() ?? 'products') ?? p['products'];
  final List<dynamic> products = rawProducts is List ? rawProducts : [];
  final onProductTap = p['onProductTap'];

  return GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.1,
    ),
    itemCount: products.length,
    itemBuilder: (context, idx) {
      final prod = products[idx] as Map;
      return Card(
        elevation: 1,
        child: InkWell(
          onTap: () {
            if (onProductTap != null) {
              AcActionRegistry.execute(onProductTap, ctx, event: {'product': prod});
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  prod['name']?.toString() ?? '',
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text('₹${prod['rate'] ?? prod['price'] ?? 0}', style: const TextStyle(color: Color(0xFF1565C0), fontSize: 12)),
              ],
            ),
          ),
        ),
      );
    },
  );
}
