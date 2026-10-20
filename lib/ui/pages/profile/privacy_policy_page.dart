import 'package:flashcards/config/app_info.dart';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flutter/material.dart';

@RoutePage()
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سياسة الخصوصية'),
        leading: IconButton(
          onPressed: () => context.router.pop(),
          icon: Icon(Icons.arrow_back),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalScreenPadding,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text('آخر تحديث: 2025'),
            SizedBox(height: 34),

            _SectionTitle('1. المعلومات التي نجمعها'),
            Text(
              'قد نجمع الأنواع التالية من البيانات:\n'
              '- معلومات شخصية (مثل الاسم والبريد الإلكتروني)\n'
              '- بيانات الاستخدام (مثل التفاعل مع التطبيق والميزات)\n'
              '- معلومات الجهاز والتقنية (مثل نوع الجهاز ونظام التشغيل)',
            ),
            SizedBox(height: 34),

            _SectionTitle('2. كيف نستخدم معلوماتك'),
            Text(
              'قد تُستخدم المعلومات المجموعة من أجل:\n'
              '- تقديم وظائف التطبيق وصيانتها\n'
              '- تحسين تجربة المستخدم\n'
              '- التواصل مع المستخدمين (مثل التنبيهات والدعم)',
            ),
            SizedBox(height: 34),

            _SectionTitle('3. مشاركة البيانات'),
            Text(
              'لا نبيع بياناتك الشخصية. قد تُشارَك المعلومات مع:\n'
              '- مزوّدي خدمات خارجيين (مثل التحليلات والمصادقة)\n'
              '- الجهات القانونية إذا اشترط النظام ذلك',
            ),
            SizedBox(height: 34),

            _SectionTitle('4. أمان البيانات'),
            Text(
              'نتخذ إجراءات معقولة لحماية بياناتك، لكن لا يوجد نظام آمن بنسبة 100%.',
            ),
            SizedBox(height: 34),

            _SectionTitle('5. حقوقك'),
            Text(
              'لك الحق في:\n'
              '- الاطلاع على البيانات التي نحتفظ بها عنك\n'
              '- طلب حذف بياناتك أو تصحيحها\n'
              '- سحب الموافقة حيثما ينطبق',
            ),
            SizedBox(height: 34),

            _SectionTitle('6. تواصل معنا'),
            Text(
              'إذا عندك أسئلة عن هذه السياسة تقدر تتواصل معنا على:\n'
              '${AppInfo.supportEmail}',
            ),
            SizedBox(height: 24),
          ],
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
