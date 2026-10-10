import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/progress/progress_cubit.dart';
import 'package:flashcards/data/repositories/progress/progress_repository.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/progress/cards_progress_view.dart';
import 'package:flashcards/ui/widgets/progress/osce_progress_view.dart';
import 'package:flashcards/ui/widgets/progress/progress_widgets.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class LearningProgressPage extends StatelessWidget {
  const LearningProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProgressCubit(progressRepo: context.read<ProgressRepository>())
            ..load(),
      child: const LearningProgressView(),
    );
  }
}

class LearningProgressView extends StatelessWidget {
  const LearningProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.style_outlined), text: 'Cards'),
                Tab(icon: Icon(Icons.medical_services_outlined), text: 'OSCE'),
              ],
            ),
            Expanded(
              child: BlocBuilder<ProgressCubit, ProgressState>(
                builder: (context, state) => TabBarView(
                  children: [
                    _SectionView(
                      section: state.cards,
                      builder: (stats) => CardsProgressView(stats: stats),
                    ),
                    _SectionView(
                      section: state.osce,
                      builder: (stats) => OsceProgressView(stats: stats),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionView<T> extends StatelessWidget {
  final ProgressSection<T> section;
  final Widget Function(T data) builder;

  const _SectionView({required this.section, required this.builder});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProgressCubit>();
    final data = section.data;

    final Widget content;
    if (data != null) {
      content = builder(data);
    } else if (section.error != null) {
      content = ProgressMessage(
        icon: Icons.cloud_off,
        title: "Progress couldn't be loaded",
        message: extractErrorMessage(section.error!),
        onRetry: () => cubit.load(refresh: true),
      );
    } else {
      content = Padding(
        padding: const EdgeInsets.only(top: 120),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: context.colors.primary),
              const SizedBox(height: 16),
              const Text('Analysing your progress…'),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => cubit.load(refresh: true),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          horizontalScreenPadding * 0.6,
          12,
          horizontalScreenPadding * 0.6,
          32,
        ),
        children: [
          if (section.isLoading && data != null)
            const LinearProgressIndicator(minHeight: 2),
          content,
        ],
      ),
    );
  }
}
