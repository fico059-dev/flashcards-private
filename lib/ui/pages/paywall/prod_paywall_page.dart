import 'dart:async';

import 'package:auto_route/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';
import 'package:flashcards/data/remote/cloud_function_service.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import '../../../payments/purchase_service.dart';

@RoutePage()
class ProdPaywallPage extends StatefulWidget {
  const ProdPaywallPage({super.key});
  @override
  State<ProdPaywallPage> createState() => _ProdPaywallPageState();
}

class _ProdPaywallPageState extends State<ProdPaywallPage> {
  bool annual = false;
  bool loadingGrant = false;
  bool _inited = false;

  final _purchase = PurchaseService();

  @override
  void initState() {
    super.initState();
    _initIap();
  }

  Future<void> _initIap() async {
    // In-app purchases only exist in the iPhone/Android apps.
    if (kIsWeb) return;
    await _purchase.init({
      'cards_monthly',
      'cards_yearly',
      'both_monthly',
      'both_yearly',
    });
    if (!mounted) return;
    setState(() => _inited = true);

    unawaited(_purchase.restore());

    _purchase.statusStream.listen((msg) async {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

      if (msg == 'Success') {
        await FirebaseAuth.instance.currentUser?.getIdToken(true);
        if (mounted) Navigator.pop(context, true);
      }
    });
  }

  @override
  void dispose() {
    if (!kIsWeb) _purchase.dispose();
    super.dispose();
  }

  Future<void> _grant(String scope) async {
    setState(() => loadingGrant = true);
    try {
      await CloudFunctionService().devGrant(scope: scope, minutes: 120);
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

  List _filteredProducts() {
    final suffix = annual ? '_yearly' : '_monthly';
    final list = _purchase.products
        .where((p) => p.id.endsWith(suffix))
        .toList();

    int rank(String id) {
      if (id.startsWith('cards_')) return 0;
      if (id.startsWith('osce_')) return 1;
      if (id.startsWith('both_')) return 2;
      return 99;
    }

    list.sort((a, b) => rank(a.id).compareTo(rank(b.id)));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const _WebSubscriptionInfo();

    final period = annual ? 'Annual' : 'Monthly';
    final products = _filteredProducts();

    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade')),
      body: ReadableWidth(
        maxWidth: 820,
        child: ListView(
          children: [
            SwitchListTile(
              inactiveTrackColor: context.colors.outlineVariant,
              title: Text('Billing period: $period'),
              value: annual,
              onChanged: (v) => setState(() => annual = v),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                'Plans',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            if (!_inited)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_purchase.products.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No products available yet. Check Play Console setup / wait for sync.',
                ),
              )
            else if (products.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No ${annual ? 'annual' : 'monthly'} plans found. '
                  'Check that SKUs match the expected naming.',
                ),
              )
            else
              ...products.map(
                (p) => Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(p.title),
                    subtitle: Text(p.description),
                    trailing: Text(p.price),
                    onTap: () => _purchase.buy(p),
                  ),
                ),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _purchase.restore,
                  child: const Text('Restore purchases'),
                ),
              ],
            ),

            const Divider(),

            if (kDebugMode) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Text(
                  'Developer shortcuts',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              _DevPlan('Cards only (DEV grant)', () => _grant('packs')),
              _DevPlan('All Access (DEV grant)', () => _grant('both')),
              if (loadingGrant)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DevPlan extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _DevPlan(this.title, this.onTap, {super.key});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: ListTile(
      title: Text(title),
      trailing: const Icon(Icons.bolt),
      onTap: onTap,
    ),
  );
}

/// Subscriptions are bought in the iPhone app; on the web the user is told
/// so. A subscription bought there works on the website with the same account.
class _WebSubscriptionInfo extends StatelessWidget {
  const _WebSubscriptionInfo();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade')),
      body: ReadableWidth(
        maxWidth: 820,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  Icon(
                    Icons.workspace_premium,
                    size: 64,
                    color: context.colors.primary,
                  ),
                  Text(
                    'Subscribe in the iPhone app',
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    "Subscriptions can't be bought on the website yet. "
                    'Subscribe in the FlashPedz iPhone app, then sign in here '
                    'with the same account: your premium packs will be '
                    'unlocked on the website too.',
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'Already subscribed? Sign out and sign in again to refresh '
                    'your access.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
