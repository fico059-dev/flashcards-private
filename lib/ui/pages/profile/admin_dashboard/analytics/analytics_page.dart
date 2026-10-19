import 'dart:convert';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flashcards/data/remote/cloud_function_service.dart';
import 'package:flashcards/domain/models/analytics/app_analytics.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/utils/file_download/file_download.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

/// Users, activity and retention at a glance, to show investors.
@RoutePage()
class AnalyticsPage extends StatefulWidget {
  /// Where the numbers come from (the server unless a test sets it).
  final Future<Map<String, dynamic>> Function()? load;

  const AnalyticsPage({super.key, this.load});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  late Future<AppAnalytics> _future = _load();
  int _days = 30;

  Future<AppAnalytics> _load() async =>
      AppAnalytics.fromJson(
        await (widget.load ?? CloudFunctionService().getAppAnalytics)(),
      );

  void _refresh() => setState(() => _future = _load());

  Future<void> _copySummary(AppAnalytics data) async {
    await Clipboard.setData(ClipboardData(text: data.summary()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Summary copied. Paste it into an email or a slide.'),
      ),
    );
  }

  Future<void> _downloadCsv(AppAnalytics data) async {
    final bytes = Uint8List.fromList(utf8.encode(data.dailyCsv()));
    final name =
        'flashpedz-daily-${DateFormat('yyyy-MM-dd').format(data.generatedAt)}.csv';
    if (kIsWeb &&
        await downloadBytes(bytes, fileName: name, mimeType: 'text/csv')) {
      return;
    }
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: 'text/csv', name: name)],
        fileNameOverrides: [name],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppAnalytics>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    "Couldn't load the numbers.\n${snapshot.error}",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _refresh,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }
        final data = snapshot.data;
        if (data == null) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Counting users and study sessions…'),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            _refresh();
            await _future;
          },
          child: _Dashboard(
            data: data,
            days: _days,
            onDaysChanged: (days) => setState(() => _days = days),
            onRefresh: _refresh,
            onCopy: () => _copySummary(data),
            onCsv: () => _downloadCsv(data),
          ),
        );
      },
    );
  }
}

class _Dashboard extends StatelessWidget {
  final AppAnalytics data;
  final int days;
  final ValueChanged<int> onDaysChanged;
  final VoidCallback onRefresh;
  final VoidCallback onCopy;
  final VoidCallback onCsv;

  const _Dashboard({
    required this.data,
    required this.days,
    required this.onDaysChanged,
    required this.onRefresh,
    required this.onCopy,
    required this.onCsv,
  });

  @override
  Widget build(BuildContext context) {
    final n = NumberFormat.decimalPattern();
    String pct(double? v) => v == null ? '–' : '${v.toStringAsFixed(0)}%';
    final growth = data.signupGrowth;
    final series = data.daily.skip(max(0, data.daily.length - days)).toList();
    final text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 30, label: Text('30 days')),
                        ButtonSegment(value: 90, label: Text('90 days')),
                      ],
                      selected: {days},
                      onSelectionChanged: (v) => onDaysChanged(v.first),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: onCopy,
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy summary'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onCsv,
                      icon: const Icon(Icons.download),
                      label: const Text('Daily data (CSV)'),
                    ),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: onRefresh,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Updated ${DateFormat.yMMMd().add_jm().format(data.generatedAt)}. '
                  'A learner is someone who studied at least one card.',
                  style: text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                const _SectionTitle('Growth'),
                _TileGrid(
                  tiles: [
                    _Tile('Total users', n.format(data.totalUsers)),
                    _Tile(
                      'New users (30 days)',
                      n.format(data.new30),
                      note: growth == null
                          ? '${n.format(data.new7)} in the last 7 days'
                          : '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(0)}% vs previous 30 days',
                      good: growth == null ? null : growth >= 0,
                    ),
                    _Tile(
                      'Activation',
                      pct(data.activation),
                      note: '${n.format(data.learnersEver)} users have studied',
                    ),
                  ],
                ),
                _ChartCard(
                  title: 'Total users',
                  child: _LineChart(
                    values: [for (final d in series) d.totalUsers.toDouble()],
                    dates: [for (final d in series) d.date],
                    unit: 'users',
                  ),
                ),
                _ChartCard(
                  title: 'New sign-ups per day',
                  child: _BarChart(
                    values: [for (final d in series) d.signups.toDouble()],
                    dates: [for (final d in series) d.date],
                    unit: 'sign-ups',
                  ),
                ),
                const SizedBox(height: 8),
                const _SectionTitle('Engagement'),
                _TileGrid(
                  tiles: [
                    _Tile(
                      'Daily learners',
                      n.format(data.dau),
                      note: '7-day average ${data.avgDauLast7}',
                    ),
                    _Tile('Weekly learners', n.format(data.wau)),
                    _Tile('Monthly learners', n.format(data.mau)),
                    _Tile(
                      'Stickiness',
                      pct(data.stickiness),
                      note: 'Daily ÷ monthly learners',
                    ),
                    _Tile(
                      'Cards studied (30 days)',
                      n.format(data.cardsLast30),
                      note: '${n.format(data.cardsAllTime)} all time',
                    ),
                    _Tile(
                      'Cards per study day',
                      n.format(data.cardsPerActiveDay),
                      note: 'Per learner, last 30 days',
                    ),
                    _Tile(
                      'OSCE questions practised',
                      n.format(data.osceAttempts),
                    ),
                    _Tile(
                      'Learners with an exam goal',
                      n.format(data.withGoal),
                      note: '${n.format(data.streak3)} on a 3+ day streak',
                    ),
                  ],
                ),
                _ChartCard(
                  title: 'Active learners per day',
                  child: _BarChart(
                    values: [
                      for (final d in series) d.activeLearners.toDouble(),
                    ],
                    dates: [for (final d in series) d.date],
                    unit: 'learners',
                  ),
                ),
                _ChartCard(
                  title: 'Cards studied per day',
                  child: _BarChart(
                    values: [for (final d in series) d.cardsStudied.toDouble()],
                    dates: [for (final d in series) d.date],
                    unit: 'cards',
                  ),
                ),
                const SizedBox(height: 8),
                const _SectionTitle('Retention'),
                _TileGrid(
                  tiles: [
                    _Tile(
                      'Day 1',
                      pct(data.d1),
                      note: 'Studied again the next day or later',
                    ),
                    _Tile(
                      'Day 7',
                      pct(data.d7),
                      note: 'Studied again a week or more later',
                    ),
                    _Tile(
                      'Day 30',
                      pct(data.d30),
                      note: 'Studied again a month or more later',
                    ),
                  ],
                ),
                _ChartCard(
                  title: 'Sign-up weeks: who came back',
                  child: _CohortTable(cohorts: data.cohorts),
                ),
                const SizedBox(height: 8),
                const _SectionTitle('Audience and content'),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth > 700;
                    final provider = _ChartCard(
                      title: 'Sign-in method',
                      child: _Breakdown(
                        counts: data.byProvider,
                        label: _providerName,
                      ),
                    );
                    final education = _ChartCard(
                      title: 'Education level',
                      child: _Breakdown(
                        counts: data.byEducation,
                        label: _educationName,
                      ),
                    );
                    if (!wide) return Column(children: [provider, education]);
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: provider),
                        const SizedBox(width: 12),
                        Expanded(child: education),
                      ],
                    );
                  },
                ),
                _TileGrid(
                  tiles: [
                    _Tile('Flashcard packs', n.format(data.packs)),
                    _Tile('Flashcards', n.format(data.flashcards)),
                    _Tile('OSCE stations', n.format(data.osces)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _providerName(String id) => switch (id) {
  'password' => 'Email',
  'google.com' => 'Google',
  'apple.com' => 'Apple',
  'phone' => 'Phone',
  _ => 'Other',
};

String _educationName(String id) => switch (id) {
  'medicalStudent' => 'Medical student',
  'intern' => 'Intern',
  'juniorResident' => 'Junior resident',
  'seniorResident' => 'Senior resident',
  'fellow' => 'Fellow',
  'consultant' => 'Consultant',
  _ => 'Not set',
};

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    ),
  );
}

class _Tile {
  final String label;
  final String value;
  final String? note;

  /// Colors the note green (true) or red (false).
  final bool? good;

  const _Tile(this.label, this.value, {this.note, this.good});
}

class _TileGrid extends StatelessWidget {
  final List<_Tile> tiles;

  const _TileGrid({required this.tiles});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final columns = max(2, min(4, (constraints.maxWidth / 220).floor()));
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final t in tiles)
                SizedBox(
                  width: width,
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.label,
                            style: text.labelMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t.value,
                            style: text.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (t.note != null)
                            Row(
                              children: [
                                if (t.good != null) ...[
                                  Icon(
                                    t.good!
                                        ? Icons.trending_up
                                        : Icons.trending_down,
                                    size: 16,
                                    color: t.good!
                                        ? Colors.green.shade700
                                        : context.colors.error,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Expanded(
                                  child: Text(
                                    t.note!,
                                    style: text.bodySmall?.copyWith(
                                      color: context.colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    ),
  );
}

/// Axis labels and tooltips shared by the line and bar charts.
class _Axes {
  final List<DateTime> dates;
  final double maxY;
  final BuildContext context;

  _Axes(this.context, this.dates, this.maxY);

  TextStyle get _style => Theme.of(
    context,
  ).textTheme.labelSmall!.copyWith(color: context.colors.onSurfaceVariant);

  FlTitlesData titles() {
    final step = max(1, (dates.length / 5).ceil());
    return FlTitlesData(
      topTitles: const AxisTitles(),
      rightTitles: const AxisTitles(),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: _interval(),
          getTitlesWidget: (value, meta) => value == meta.max
              ? const SizedBox.shrink()
              : Text(NumberFormat.compact().format(value), style: _style),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 24,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final i = value.round();
            if (i < 0 || i >= dates.length || i % step != 0) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(DateFormat.MMMd().format(dates[i]), style: _style),
            );
          },
        ),
      ),
    );
  }

  double _interval() {
    final raw = maxY / 4;
    if (raw <= 1) return 1;
    final magnitude = pow(10, (log(raw) / ln10).floor()).toDouble();
    for (final m in [1, 2, 5, 10]) {
      if (raw <= m * magnitude) return m * magnitude;
    }
    return raw;
  }

  FlGridData grid() => FlGridData(
    drawVerticalLine: false,
    horizontalInterval: _interval(),
    getDrawingHorizontalLine: (_) => FlLine(
      color: context.colors.outlineVariant.withValues(alpha: 0.5),
      strokeWidth: 1,
    ),
  );

  String tooltip(int i, double value, String unit) =>
      '${DateFormat.MMMd().format(dates[i])}\n'
      '${NumberFormat.decimalPattern().format(value)} $unit';
}

double _niceMax(List<double> values) {
  final top = values.fold(0.0, max);
  return top <= 0 ? 4 : top * 1.15;
}

class _LineChart extends StatelessWidget {
  final List<double> values;
  final List<DateTime> dates;
  final String unit;

  const _LineChart({
    required this.values,
    required this.dates,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = _niceMax(values);
    final axes = _Axes(context, dates, maxY);
    final color = context.colors.primary;
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          titlesData: axes.titles(),
          gridData: axes.grid(),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => context.colors.inverseSurface,
              getTooltipItems: (spots) => [
                for (final s in spots)
                  LineTooltipItem(
                    axes.tooltip(s.x.round(), s.y, unit),
                    TextStyle(color: context.colors.onInverseSurface),
                  ),
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < values.length; i++)
                  FlSpot(i.toDouble(), values[i]),
              ],
              color: color,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: color.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<double> values;
  final List<DateTime> dates;
  final String unit;

  const _BarChart({
    required this.values,
    required this.dates,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = _niceMax(values);
    final axes = _Axes(context, dates, maxY);
    final color = context.colors.primary;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Thin bars with a small gap, whatever the number of days.
        final width = max(
          2.0,
          (constraints.maxWidth - 48) / max(1, values.length) - 2,
        );
        return SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: maxY,
              titlesData: axes.titles(),
              gridData: axes.grid(),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => context.colors.inverseSurface,
                  getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                    axes.tooltip(group.x, rod.toY, unit),
                    TextStyle(color: context.colors.onInverseSurface),
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < values.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i],
                        color: color,
                        width: min(width, 18),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Horizontal bars: one per group, biggest first.
class _Breakdown extends StatelessWidget {
  final Map<String, int> counts;
  final String Function(String id) label;

  const _Breakdown({required this.counts, required this.label});

  @override
  Widget build(BuildContext context) {
    final merged = <String, int>{};
    for (final e in counts.entries) {
      final name = label(e.key);
      merged[name] = (merged[name] ?? 0) + e.value;
    }
    final entries = merged.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold(0, (a, e) => a + e.value);
    if (total == 0) return const Text('No data yet.');
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        for (final e in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(e.key, style: text.bodyMedium),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: e.value / total,
                      minHeight: 12,
                      color: context.colors.primary,
                      backgroundColor: context.colors.surfaceContainerHighest,
                    ),
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: Text(
                    '${e.value} · ${(e.value / total * 100).toStringAsFixed(0)}%',
                    textAlign: TextAlign.right,
                    style: text.bodySmall,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Each sign-up week and the share who studied 1, 2 and 4 weeks later.
class _CohortTable extends StatelessWidget {
  final List<SignupCohort> cohorts;

  const _CohortTable({required this.cohorts});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = text.labelMedium?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    Widget cell(double? value, int size) {
      final show = value != null && size > 0;
      return Container(
        height: 34,
        margin: const EdgeInsets.all(1),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: show
              ? context.colors.primary.withValues(
                  alpha: 0.08 + 0.4 * value / 100,
                )
              : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          show ? '${value.toStringAsFixed(0)}%' : '–',
          style: text.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(flex: 3, child: Text('Signed up', style: muted)),
            Expanded(flex: 2, child: Text('Users', style: muted)),
            for (final h in ['Week 1', 'Week 2', 'Week 4'])
              Expanded(
                flex: 2,
                child: Text(h, style: muted, textAlign: TextAlign.center),
              ),
          ],
        ),
        const SizedBox(height: 4),
        for (final c in cohorts.reversed)
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('Week of ${DateFormat.MMMd().format(c.week)}'),
              ),
              Expanded(flex: 2, child: Text('${c.size}')),
              Expanded(flex: 2, child: cell(c.week1, c.size)),
              Expanded(flex: 2, child: cell(c.week2, c.size)),
              Expanded(flex: 2, child: cell(c.week4, c.size)),
            ],
          ),
        const SizedBox(height: 6),
        Text(
          'Share of each week’s new users who studied again in that week '
          'after signing up. "–" means it is too early to tell.',
          style: text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
