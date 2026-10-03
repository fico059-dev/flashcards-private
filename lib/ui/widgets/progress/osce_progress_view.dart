import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/progress/progress_cubit.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/domain/models/progress/osce_progress.dart';
import 'package:flashcards/ui/dialogs/progress/study_goal_sheet.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/progress/progress_charts.dart';
import 'package:flashcards/ui/widgets/progress/progress_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class OsceProgressView extends StatelessWidget {
  final OsceProgressStats stats;

  const OsceProgressView({super.key, required this.stats});

  Future<void> _editGoal(BuildContext context) async {
    final cubit = context.read<ProgressCubit>();
    final goal = await showStudyGoalSheet(
      context,
      goal: cubit.state.goal,
      totalCards: cubit.state.cards.data?.totalAvailable ?? 0,
    );
    if (goal != null) cubit.saveGoal(goal);
  }

  Color _scoreColor(BuildContext context, double percent) =>
      percent >= stats.targetScore
      ? masteredColor(context)
      : percent >= stats.targetScore - 15
      ? learningColor(context)
      : Colors.red.shade400;

  @override
  Widget build(BuildContext context) {
    final avgLatest = stats.averageLatest;
    final avgBest = stats.averageBest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProgressSectionCard(
          title: 'OSCE target',
          icon: Icons.flag_outlined,
          trailing: TextButton(
            onPressed: () => _editGoal(context),
            child: const Text('Edit'),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${stats.stationsAtTarget} of ${stats.stationsTotal} stations '
                'at ${stats.targetScore}% or more',
                style: context.text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              ProgressBarRow(
                title: 'Stations on target',
                trailing: stats.stationsTotal == 0
                    ? '0%'
                    : '${(stats.stationsAtTarget / stats.stationsTotal * 100).round()}%',
                segments: stats.stationsTotal == 0
                    ? []
                    : [
                        (
                          stats.stationsAtTarget / stats.stationsTotal,
                          masteredColor(context),
                        ),
                        (
                          (stats.stations.length - stats.stationsAtTarget) /
                              stats.stationsTotal,
                          learningColor(context),
                        ),
                      ],
                subtitle:
                    '${stats.stations.length - stats.stationsAtTarget} below target · '
                    '${stats.untriedStations.length} not tried',
              ),
            ],
          ),
        ),
        StatGrid(
          tiles: [
            StatTileData(
              label: 'Stations practised',
              value: '${stats.stations.length}',
              caption: 'of ${stats.stationsTotal}',
              icon: Icons.medical_services_outlined,
            ),
            StatTileData(
              label: 'Attempts',
              value: '${stats.attemptsCount}',
              caption: 'saved results',
              icon: Icons.repeat,
              color: Colors.teal,
            ),
            StatTileData(
              label: 'Latest average',
              value: avgLatest == null ? '–' : '${avgLatest.round()}%',
              caption: 'last try of each station',
              icon: Icons.insights,
              color: avgLatest == null ? null : _scoreColor(context, avgLatest),
            ),
            StatTileData(
              label: 'Best average',
              value: avgBest == null ? '–' : '${avgBest.round()}%',
              caption: 'best try of each station',
              icon: Icons.emoji_events_outlined,
              color: Colors.amber.shade800,
            ),
          ],
        ),
        const SizedBox(height: 14),
        ProgressSectionCard(
          title: 'What to practise next',
          icon: Icons.lightbulb_outline,
          child: AdviceList(advice: stats.advice),
        ),
        if (stats.allAttempts.isNotEmpty)
          ProgressSectionCard(
            title: 'Score trend',
            subtitle: 'Every OSCE attempt, oldest to newest',
            icon: Icons.show_chart,
            child: OsceTrendChart(
              attempts: stats.allAttempts,
              target: stats.targetScore,
            ),
          ),
        if (stats.stations.isNotEmpty)
          ProgressSectionCard(
            title: 'Stations',
            subtitle: 'Weakest first · latest score (best score)',
            icon: Icons.list_alt,
            child: Column(
              children: [
                for (final station in stats.weakestFirst)
                  ProgressBarRow(
                    title: station.name,
                    trailing:
                        '${station.latest.round()}% (${station.best.round()}%)',
                    segments: [
                      (
                        station.latest / 100,
                        _scoreColor(context, station.latest),
                      ),
                    ],
                    subtitle:
                        '${station.attempts.length} '
                        '${station.attempts.length == 1 ? 'attempt' : 'attempts'}'
                        ' · last ${DateFormat('d MMM').format(station.lastDate)}'
                        '${station.attempts.length > 1 ? ' · ${station.improvement >= 0 ? '+' : ''}${station.improvement.round()}% since first' : ''}',
                  ),
              ],
            ),
          ),
        ProgressSectionCard(
          title: 'Gaps in your OSCE',
          subtitle: 'Sections and checklist items you miss most',
          icon: Icons.track_changes,
          child: stats.weakAreas.isEmpty && stats.missedChecks.isEmpty
              ? Text(
                  'Finish OSCEs and tick your checklist to see which parts '
                  'you miss most. Recorded on this device from now on.',
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final area in stats.weakAreas)
                      ProgressBarRow(
                        title: area.text.split('\n').first,
                        trailing: '${area.percent.round()}%',
                        subtitle: area.stationName,
                        segments: [
                          (
                            area.percent / 100,
                            _scoreColor(context, area.percent),
                          ),
                        ],
                      ),
                    if (stats.missedChecks.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Most missed checklist items',
                        style: context.text.labelLarge,
                      ),
                      for (final check in stats.missedChecks)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.red.shade50,
                            child: Text(
                              '${check.times}×',
                              style: context.text.labelSmall?.copyWith(
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                          title: Text(
                            check.text,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(check.stationName),
                        ),
                    ],
                  ],
                ),
        ),
        if (stats.untriedStations.isNotEmpty)
          ProgressSectionCard(
            title: 'Not tried yet',
            subtitle: stats.untriedStations.length == 1
                ? '1 station'
                : '${stats.untriedStations.length} stations',
            icon: Icons.fiber_new_outlined,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final name in stats.untriedStations.take(20))
                  Chip(label: Text(name), visualDensity: VisualDensity.compact),
                if (stats.untriedStations.length > 20)
                  Chip(
                    label: Text('+${stats.untriedStations.length - 20} more'),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
        ProgressSectionCard(
          title: 'More',
          icon: Icons.more_horiz,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history),
            title: const Text('All OSCE results'),
            subtitle: const Text('See and delete saved attempts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.router.push(const OscePerformancesRoute()),
          ),
        ),
      ],
    );
  }
}
