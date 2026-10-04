import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';
import 'package:flashcards/data/remote/cloud_function_service.dart';

class DevPaywallPage extends StatefulWidget {
  const DevPaywallPage({super.key});
  @override
  State<DevPaywallPage> createState() => _DevPaywallPageState();
}

class _DevPaywallPageState extends State<DevPaywallPage> {
  bool annual = false;
  bool loading = false;

  Future<void> _grant(String scope) async {
    setState(() => loading = true);
    try {
      await CloudFunctionService().devGrant(scope: scope, minutes: 120);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final period = annual ? 'Annual' : 'Monthly';
    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade')),
      body: ReadableWidth(
        maxWidth: 820,
        child: Column(
          children: [
            SwitchListTile(
              inactiveTrackColor: context.colors.outlineVariant,
              title: Text('Billing period: $period'),
              value: annual,
              onChanged: (v) => setState(() => annual = v),
            ),
            _Plan('Cards only', () => _grant('packs')),
            _Plan('All Access', () => _grant('both')),
            if (loading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}

class _Plan extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _Plan(this.title, this.onTap, {super.key});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward),
      onTap: onTap,
    ),
  );
}
