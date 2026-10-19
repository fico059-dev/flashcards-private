import 'package:auto_route/auto_route.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/ui/pages/main_tab_pages/main_tab_routes.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    void goToTab(MainTab tab) => AutoTabsRouter.of(
      context,
    ).setActiveIndex(MainTabRoutes.mainTabToIndex(tab));

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Image.asset('assets/images/logo_full.png', height: 150),
            ),
            const SizedBox(height: 8),
            Text(
              'استعد لاختبار القدرات بالبطاقات التعليمية',
              textAlign: TextAlign.center,
              style: context.text.titleMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _SectionCard(
                    title: 'لفظي',
                    subtitle: 'التناظر، إكمال الجمل، المفردة الشاذة...',
                    icon: Icons.menu_book,
                    onTap: () => goToTab(MainTab.verbal),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SectionCard(
                    title: 'كمي',
                    subtitle: 'الجبر، الهندسة، النسب، الإحصاء...',
                    icon: Icons.calculate,
                    onTap: () => goToTab(MainTab.quant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ActionTile(
              icon: Icons.tune,
              title: 'جلسة مخصّصة',
              subtitle: 'اختر حزماً ووسوماً وعدد أسئلة بنفسك',
              onTap: () => context.router.push(CustomSessionWrapperRoute()),
            ),
            _ActionTile(
              icon: Icons.search,
              title: 'تصفّح البطاقات',
              onTap: () => context.router.push(const FlashcardsSearcherRoute()),
            ),
            _ActionTile(
              icon: Icons.flag_outlined,
              title: 'هدفي اليومي',
              onTap: () => context.router.push(const UpdateCardsPerSessionRoute()),
            ),
            _ActionTile(
              icon: Icons.insights,
              title: 'تقدّمي',
              onTap: () => goToTab(MainTab.learningProgress),
            ),
            _ActionTile(
              icon: Icons.workspace_premium_outlined,
              title: 'الاشتراك المميّز',
              onTap: () => context.router.push(ProdPaywallRoute()),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.colors.primaryContainer,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 36, color: context.colors.primary),
              const SizedBox(height: 12),
              Text(
                title,
                style: context.text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: context.colors.primary),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(Icons.chevron_left),
      onTap: onTap,
    );
  }
}
