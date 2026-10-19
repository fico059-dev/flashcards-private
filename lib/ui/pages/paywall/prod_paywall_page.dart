import 'dart:async';

import 'package:auto_route/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcards/data/remote/cloud_function_service.dart';
import 'package:flashcards/payments/product_ids.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../payments/purchase_service.dart';

@RoutePage()
class ProdPaywallPage extends StatefulWidget {
  const ProdPaywallPage({super.key});
  @override
  State<ProdPaywallPage> createState() => _ProdPaywallPageState();
}

class _ProdPaywallPageState extends State<ProdPaywallPage> {
  bool loadingGrant = false;
  bool _inited = false;
  StreamSubscription<String>? _statusSub;

  final _purchase = PurchaseService();

  @override
  void initState() {
    super.initState();
    _initIap();
  }

  Future<void> _initIap() async {
    await _purchase.init(kProductIds);
    if (!mounted) return;
    setState(() => _inited = true);

    _statusSub = _purchase.statusStream.listen((msg) async {
      if (!mounted) return;
      if (msg == PurchaseService.successMessage) {
        await FirebaseAuth.instance.currentUser?.getIdToken(true);
        if (mounted) Navigator.pop(context, true);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    });
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _purchase.dispose();
    super.dispose();
  }

  Future<void> _devGrant() async {
    setState(() => loadingGrant = true);
    try {
      await CloudFunctionService().devGrant(scope: 'premium', minutes: 120);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => loadingGrant = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = List<ProductDetails>.of(_purchase.products)
      ..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));

    return Scaffold(
      appBar: AppBar(title: const Text('الاشتراك المميّز')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'افتح كل حزم القدرات (اللفظي والكمي) مع شرح مفصّل لكل إجابة.',
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          if (!_inited)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (products.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'الاشتراكات غير متاحة حالياً على هذا الجهاز. '
                'جرّب من تطبيق الجوال.',
              ),
            )
          else
            ...products.map(
              (p) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text(p.title),
                  subtitle: Text(p.description),
                  trailing: Text(
                    p.price,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),
                  onTap: () => _purchase.buy(p),
                ),
              ),
            ),
          Center(
            child: TextButton(
              onPressed: _purchase.restore,
              child: const Text('استعادة المشتريات'),
            ),
          ),
          if (kDebugMode) ...[
            const Divider(),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: const Text('تفعيل مؤقت للتجربة (DEV)'),
                trailing: loadingGrant
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.bolt),
                onTap: _devGrant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
