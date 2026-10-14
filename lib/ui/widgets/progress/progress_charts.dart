import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flashcards/domain/models/progress/card_progress.dart';
import 'package:flashcards/domain/models/progress/osce_progress.dart';
import 'package:flashcards/domain/models/progress/study_log.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const _chartHeight = 180.0;

Color masteredColor(BuildContext context) => Colors.green.shade600;
Color reviewingColor(BuildContext context) => context.colors.primary;
Color learningColor(BuildContext context) => Colors.orange.shade600;
Color unseenColor(BuildContext context) => context.colors.outlineVariant;

/// Studied cards so far, where the current pace leads, and the path needed
/// to reach the target by the exam.
class TrajectoryChart extends StatelessWidget {
  final Trajectory trajectory;

  const TrajectoryChart({super.key, required this.trajectory});

  @override
  Widget build(BuildContext context) {
    final t = trajectory;
    final today = startOfDay(DateTime.now());
    final start = t.history.first.key;
    final end = t.examDate != null && t.examDate!.isAfter(today)
        ? t.examDate!
        : today.add(const Duration(days: 30));

    double x(DateTime date) => date.difference(start).inDays.toDouble();
    final todayX = x(today);
    final endX = max(x(end), todayX + 1);

    // The pace line stops where it reaches the target.
    final reachX = t.pace > 0 ? todayX + t.remaining / t.pace : endX;
    final paceEnd = reachX < endX
        ? FlSpot(reachX, t.target.toDouble())
        : FlSpot(endX, t.studied + t.pace * (endX - todayX));
    final projectedEnd = paceEnd.y;
    final maxY =
        [
          t.target.toDouble(),
          projectedEnd,
          ...t.history.map((e) => e.value.toDouble()),
          10.0,
        ].reduce(max) *
        1.1;

    final lines = <LineChartBarData>[
      LineChartBarData(
        spots: [
          for (final e in t.history) FlSpot(x(e.key), e.value.toDouble()),
        ],
        color: context.colors.primary,
        barWidth: 3,
        isCurved: t.history.length > 2,
        preventCurveOverShooting: true,
        dotData: FlDotData(show: t.history.length < 15),
        belowBarData: BarAreaData(
          show: true,
          color: context.colors.primary.withValues(alpha: 0.12),
        ),
      ),
      if (t.pace > 0 && t.remaining > 0)
        LineChartBarData(
          spots: [FlSpot(todayX, t.studied.toDouble()), paceEnd],
          color: context.colors.primary.withValues(alpha: 0.6),
          barWidth: 2,
          dashArray: [6, 4],
          dotData: const FlDotData(show: false),
        ),
      if (t.examDate != null && t.daysLeft != null && t.daysLeft! > 0)
        LineChartBarData(
          spots: [
            FlSpot(todayX, t.studied.toDouble()),
            FlSpot(x(t.examDate!), t.target.toDouble()),
          ],
          color: Colors.green.shade600,
          barWidth: 2,
          dashArray: [2, 4],
          dotData: const FlDotData(show: false),
        ),
    ];

    String label(double value) {
      final date = start.add(Duration(days: value.round()));
      return DateFormat('d MMM').format(date);
    }

    return Column(
      children: [
        SizedBox(
          height: _chartHeight + 20,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: endX,
              minY: 0,
              maxY: maxY,
              lineBarsData: lines,
              lineTouchData: const LineTouchData(enabled: false),
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: _niceInterval(maxY),
                getDrawingHorizontalLine: (_) => FlLine(
                  color: context.colors.outlineVariant.withValues(alpha: 0.5),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: t.target.toDouble(),
                    color: Colors.green.shade600.withValues(alpha: 0.7),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topLeft,
                      style: context.text.labelSmall?.copyWith(
                        color: Colors.green.shade700,
                      ),
                      labelResolver: (_) => 'Target ${t.target}',
                    ),
                  ),
                ],
                verticalLines: [
                  VerticalLine(
                    x: todayX,
                    color: context.colors.outline.withValues(alpha: 0.5),
                    strokeWidth: 1,
                    dashArray: [2, 3],
                  ),
                ],
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: _niceInterval(maxY),
                    getTitlesWidget: (value, meta) => _isOffStep(value, meta)
                        ? const SizedBox.shrink()
                        : SideTitleWidget(
                            meta: meta,
                            child: Text(
                              _compact(value),
                              style: context.text.labelSmall,
                            ),
                          ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: max(1, endX / 4),
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text(label(value), style: context.text.labelSmall),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 14,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            ChartLegend(color: context.colors.primary, label: 'Studied'),
            if (t.pace > 0 && t.remaining > 0)
              ChartLegend(
                color: context.colors.primary.withValues(alpha: 0.6),
                label: 'Your pace',
                dashed: true,
              ),
            if (t.examDate != null && (t.daysLeft ?? 0) > 0)
              ChartLegend(
                color: Colors.green.shade600,
                label: 'Needed',
                dashed: true,
              ),
          ],
        ),
      ],
    );
  }
}

/// How the studied cards are split between the learning stages.
class CardStatusDonut extends StatelessWidget {
  final CardProgressStats stats;

  const CardStatusDonut({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final parts = [
      ('Mastered', stats.mastered, masteredColor(context)),
      ('Reviewing', stats.young, reviewingColor(context)),
      ('Learning', stats.learning, learningColor(context)),
      ('New', stats.unseen, unseenColor(context)),
    ];
    final total = parts.fold(0, (sum, p) => sum + p.$2);

    return Row(
      children: [
        SizedBox(
          width: 130,
          height: 130,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 42,
                  startDegreeOffset: -90,
                  sections: total == 0
                      ? [
                          PieChartSectionData(
                            value: 1,
                            color: unseenColor(context),
                            radius: 18,
                            showTitle: false,
                          ),
                        ]
                      : [
                          for (final p in parts)
                            if (p.$2 > 0)
                              PieChartSectionData(
                                value: p.$2.toDouble(),
                                color: p.$3,
                                radius: 18,
                                showTitle: false,
                              ),
                        ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    total == 0
                        ? '0%'
                        : '${(stats.studied / total * 100).round()}%',
                    style: context.text.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('studied', style: context.text.labelSmall),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final p in parts)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      ChartLegend(color: p.$3, label: p.$1),
                      const Spacer(),
                      Text(
                        '${p.$2}',
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Daily bars: reviews in the last 14 days, or cards due in the next 14.
class DailyBarChart extends StatelessWidget {
  final List<int> values;

  /// Part of each bar drawn in a second colour (e.g. new cards).
  final List<int>? highlighted;
  final bool isFuture;
  final Color? color;

  const DailyBarChart({
    super.key,
    required this.values,
    this.highlighted,
    this.isFuture = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final today = startOfDay(DateTime.now());
    final barColor = color ?? context.colors.primary;
    final maxY = max(4, values.fold(0, max)) * 1.15;

    String label(int index) {
      if (isFuture) {
        if (index == 0) return 'Today';
        return index % 3 == 0 ? '+${index}d' : '';
      }
      final day = today.subtract(Duration(days: values.length - 1 - index));
      if (index == values.length - 1) return 'Today';
      return index % 3 == 1 ? DateFormat('E').format(day).substring(0, 2) : '';
    }

    return SizedBox(
      height: _chartHeight,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: _niceInterval(maxY),
            getDrawingHorizontalLine: (_) => FlLine(
              color: context.colors.outlineVariant.withValues(alpha: 0.5),
              strokeWidth: 1,
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                '${rod.toY.round()}',
                TextStyle(
                  color: context.colors.onInverseSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              getTooltipColor: (_) => context.colors.inverseSurface,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: _niceInterval(maxY),
                getTitlesWidget: (value, meta) => _isOffStep(value, meta)
                    ? const SizedBox.shrink()
                    : SideTitleWidget(
                        meta: meta,
                        child: Text(
                          _compact(value),
                          style: context.text.labelSmall,
                        ),
                      ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(
                    label(value.toInt()),
                    style: context.text.labelSmall,
                  ),
                ),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < values.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: values[i].toDouble(),
                    width: 12,
                    color: barColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                    rodStackItems: highlighted == null || highlighted![i] == 0
                        ? null
                        : [
                            BarChartRodStackItem(
                              0,
                              min(highlighted![i], values[i]).toDouble(),
                              Colors.green.shade600,
                            ),
                          ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Every OSCE attempt in order, with the target score.
class OsceTrendChart extends StatelessWidget {
  final List<OsceAttemptPoint> attempts;
  final int target;

  const OsceTrendChart({
    super.key,
    required this.attempts,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (var i = 0; i < attempts.length; i++)
        FlSpot(i.toDouble(), attempts[i].percent),
    ];
    // Moving average of the last 3 attempts shows the trend.
    final trend = [
      for (var i = 0; i < attempts.length; i++)
        FlSpot(
          i.toDouble(),
          attempts
                  .sublist(max(0, i - 2), i + 1)
                  .fold(0.0, (sum, a) => sum + a.percent) /
              (i - max(0, i - 2) + 1),
        ),
    ];

    return Column(
      children: [
        SizedBox(
          height: _chartHeight,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 100,
              minX: 0,
              maxX: max(1, attempts.length - 1).toDouble(),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: 25,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: context.colors.outlineVariant.withValues(alpha: 0.5),
                  strokeWidth: 1,
                ),
              ),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: target.toDouble(),
                    color: Colors.green.shade600.withValues(alpha: 0.7),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topLeft,
                      style: context.text.labelSmall?.copyWith(
                        color: Colors.green.shade700,
                      ),
                      labelResolver: (_) => 'Target $target%',
                    ),
                  ),
                ],
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => context.colors.inverseSurface,
                  getTooltipItems: (spots) => [
                    for (final s in spots)
                      s.barIndex == 0
                          ? LineTooltipItem(
                              '${s.y.round()}%\n'
                              '${DateFormat('d MMM').format(attempts[s.x.toInt()].date)}',
                              TextStyle(color: context.colors.onInverseSurface),
                            )
                          : null,
                  ],
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                bottomTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 25,
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text(
                        '${value.round()}%',
                        style: context.text.labelSmall,
                      ),
                    ),
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  color: context.colors.primary.withValues(alpha: 0.5),
                  barWidth: 1.5,
                  dotData: FlDotData(
                    getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                      radius: 3.5,
                      color: spot.y >= target
                          ? Colors.green.shade600
                          : learningColor(context),
                      strokeWidth: 0,
                    ),
                  ),
                ),
                if (attempts.length >= 3)
                  LineChartBarData(
                    spots: trend,
                    color: context.colors.primary,
                    barWidth: 3,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    dotData: const FlDotData(show: false),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 14,
          alignment: WrapAlignment.center,
          children: [
            ChartLegend(color: Colors.green.shade600, label: 'On target'),
            ChartLegend(color: learningColor(context), label: 'Below target'),
            if (attempts.length >= 3)
              ChartLegend(color: context.colors.primary, label: 'Trend'),
          ],
        ),
      ],
    );
  }
}

class ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  final bool dashed;

  const ChartLegend({
    super.key,
    required this.color,
    required this.label,
    this.dashed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dashed ? 16 : 10,
          height: dashed ? 3 : 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(dashed ? 1 : 3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: context.text.labelMedium),
      ],
    );
  }
}

/// The axis max usually isn't a multiple of the step, and its label would
/// overlap the one below it.
bool _isOffStep(double value, TitleMeta meta) =>
    value == meta.max && (value / meta.appliedInterval) % 1 > 0.001;

double _niceInterval(double maxY) {
  final rough = maxY / 4;
  if (rough <= 1) return 1;
  final magnitude = pow(10, (log(rough) / ln10).floor()).toDouble();
  for (final step in [1, 2, 2.5, 5, 10]) {
    if (rough <= step * magnitude) return step * magnitude;
  }
  return 10 * magnitude;
}

String _compact(double value) {
  if (value >= 1000) {
    final k = value / 1000;
    return '${k.toStringAsFixed(k >= 10 || k == k.roundToDouble() ? 0 : 1)}k';
  }
  return value.round().toString();
}
