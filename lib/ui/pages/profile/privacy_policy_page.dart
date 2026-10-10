import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';

@RoutePage()
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          onPressed: () => context.router.pop(),
          icon: Icon(Icons.arrow_back),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      body: ReadableWidth(
        maxWidth: 820,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalScreenPadding,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              Text('Last updated: May 12, 2025'),
              SizedBox(height: 34),

              _SectionTitle('1. Information We Collect'),
              Text(
                'We may collect the following types of data:\n'
                '- Personal information (e.g., name, email address)\n'
                '- Usage data (e.g., app interactions, feature usage)\n'
                '- Device and technical information (e.g., device type, operating system)',
              ),
              SizedBox(height: 34),

              _SectionTitle('2. How We Use Your Information'),
              Text(
                'Collected information may be used to:\n'
                '- Provide and maintain app functionality\n'
                '- Improve the user experience\n'
                '- Communicate with users (e.g., notifications, support)',
              ),
              SizedBox(height: 34),

              _SectionTitle('3. Data Sharing'),
              Text(
                'We do not sell your personal data. Information may be shared with:\n'
                '- Third-party service providers (e.g., for analytics or authentication)\n'
                '- Legal authorities, if required by law',
              ),
              SizedBox(height: 34),

              _SectionTitle('4. Data Security'),
              Text(
                'We take reasonable measures to protect your data. However, no system is 100% secure.',
              ),
              SizedBox(height: 34),

              _SectionTitle('5. Your Rights'),
              Text(
                'You have the right to:\n'
                '- Access the data we hold about you\n'
                '- Request deletion or correction of your data\n'
                '- Withdraw consent where applicable',
              ),
              SizedBox(height: 34),

              _SectionTitle('6. Contact Us'),
              Text(
                'If you have questions about this policy, you can contact us at:\n'
                'support@yourapp.com',
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }
}
