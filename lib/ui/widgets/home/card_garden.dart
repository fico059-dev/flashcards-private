import 'dart:math';

import 'package:flutter/material.dart';

/// How far one group of cards has come.
enum PlotStatus { unseen, learning, reviewing, mastered }

/// Cards of the goal packs by status, drawn as a garden (or a grid) where
/// each plot is [cardsPerPlot] cards.
class GardenCounts {
  final int unseen;
  final int learning;
  final int reviewing;
  final int mastered;

  const GardenCounts({
    required this.unseen,
    required this.learning,
    required this.reviewing,
    required this.mastered,
  });

  int get total => unseen + learning + reviewing + mastered;
}

const cardsPerPlot = 20;

/// One status per plot: mastered first, then reviewing, learning and
/// unseen. A plot gets the status most of its cards have reached.
List<PlotStatus> gardenPlots(GardenCounts counts) {
  final plots = (counts.total / cardsPerPlot).ceil();
  final result = <PlotStatus>[];
  final bounds = [
    (counts.mastered, PlotStatus.mastered),
    (counts.mastered + counts.reviewing, PlotStatus.reviewing),
    (counts.mastered + counts.reviewing + counts.learning, PlotStatus.learning),
  ];
  for (var i = 0; i < plots; i++) {
    // The middle card of the plot decides its status.
    final middle = i * cardsPerPlot + cardsPerPlot / 2;
    var status = PlotStatus.unseen;
    for (final (limit, s) in bounds) {
      if (middle < limit) {
        status = s;
        break;
      }
    }
    result.add(status);
  }
  return result;
}

/// Colors for the pixel grid: blue new, yellow learning, green learned.
Color gridColor(PlotStatus status) => switch (status) {
  PlotStatus.unseen => const Color(0xFF64B5F6),
  PlotStatus.learning => const Color(0xFFFFD54F),
  PlotStatus.reviewing => const Color(0xFFA5D6A7),
  PlotStatus.mastered => const Color(0xFF2E7D32),
};

/// A garden: new cards are sprouts, learning cards yellow buds, reviewed
/// cards pink roses and mastered cards red roses.
class CardGarden extends StatelessWidget {
  final List<PlotStatus> plots;
  final bool asGrid;

  const CardGarden({super.key, required this.plots, this.asGrid = false});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Bigger flowers when there are few.
        final double cell = (asGrid ? 14.0 : 26.0)
            .clamp(
              8.0,
              max(
                8.0,
                sqrt(width * (asGrid ? 140 : 220) / max(1, plots.length)),
              ),
            )
            .toDouble();
        final columns = max(1, (width / cell).floor());
        final rows = (plots.length / columns).ceil();
        return SizedBox(
          width: width,
          height: rows * cell,
          child: CustomPaint(
            painter: asGrid
                ? _GridPainter(plots, columns, cell)
                : _GardenPainter(plots, columns, cell),
          ),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  final List<PlotStatus> plots;
  final int columns;
  final double cell;

  _GridPainter(this.plots, this.columns, this.cell);

  @override
  void paint(Canvas canvas, Size size) {
    final gap = cell * 0.12;
    for (var i = 0; i < plots.length; i++) {
      final x = (i % columns) * cell;
      final y = (i ~/ columns) * cell;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + gap / 2, y + gap / 2, cell - gap, cell - gap),
          Radius.circular(cell * 0.18),
        ),
        Paint()..color = gridColor(plots[i]),
      );
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) =>
      old.plots != plots || old.columns != columns || old.cell != cell;
}

class _GardenPainter extends CustomPainter {
  final List<PlotStatus> plots;
  final int columns;
  final double cell;

  _GardenPainter(this.plots, this.columns, this.cell);

  static const _stem = Color(0xFF4E8F3A);
  static const _leaf = Color(0xFF6DB34F);

  @override
  void paint(Canvas canvas, Size size) {
    // Same garden every time for the same cards.
    final random = Random(plots.length);
    for (var i = 0; i < plots.length; i++) {
      final cx =
          (i % columns + 0.5) * cell +
          (random.nextDouble() - 0.5) * cell * 0.15;
      final top = (i ~/ columns) * cell;
      _plant(canvas, plots[i], Offset(cx, top), cell, random.nextDouble());
    }
  }

  void _plant(Canvas canvas, PlotStatus status, Offset at, double s, double r) {
    final ground = at.dy + s * 0.95;
    final stemPaint = Paint()
      ..color = _stem
      ..strokeWidth = max(1.0, s * 0.07)
      ..strokeCap = StrokeCap.round;
    final leafPaint = Paint()..color = _leaf;

    if (status == PlotStatus.unseen) {
      // A sprout: short stem and two small leaves.
      final tip = Offset(at.dx, ground - s * 0.32);
      canvas.drawLine(Offset(at.dx, ground), tip, stemPaint);
      _leafShape(canvas, tip, s * 0.2, -0.6, leafPaint);
      _leafShape(canvas, tip, s * 0.2, pi + 0.6, leafPaint);
      return;
    }

    final head = Offset(at.dx, at.dy + s * 0.34);
    canvas.drawLine(Offset(at.dx, ground), head, stemPaint);
    _leafShape(
      canvas,
      Offset(at.dx, ground - s * 0.25),
      s * 0.22,
      r > 0.5 ? -0.5 : pi + 0.5,
      leafPaint,
    );

    final (outer, inner, radius) = switch (status) {
      PlotStatus.learning => (
        const Color(0xFFFFC107),
        const Color(0xFFFFE082),
        s * 0.2,
      ),
      PlotStatus.reviewing => (
        const Color(0xFFF06292),
        const Color(0xFFF8BBD0),
        s * 0.28,
      ),
      _ => (const Color(0xFFC62828), const Color(0xFFE57373), s * 0.33),
    };

    if (status == PlotStatus.learning) {
      // A closed bud.
      final bud = Path()
        ..moveTo(head.dx, head.dy - radius * 1.4)
        ..quadraticBezierTo(
          head.dx + radius * 1.1,
          head.dy,
          head.dx,
          head.dy + radius * 0.6,
        )
        ..quadraticBezierTo(
          head.dx - radius * 1.1,
          head.dy,
          head.dx,
          head.dy - radius * 1.4,
        );
      canvas.drawPath(bud, Paint()..color = outer);
      canvas.drawCircle(
        head.translate(0, radius * 0.1),
        radius * 0.35,
        Paint()..color = inner,
      );
      return;
    }

    // An open rose: a ring of petals, a smaller ring and a centre.
    final petals = status == PlotStatus.mastered ? 6 : 5;
    final turn = r * pi;
    for (var p = 0; p < petals; p++) {
      final angle = turn + p * 2 * pi / petals;
      canvas.drawCircle(
        head + Offset(cos(angle), sin(angle)) * radius * 0.55,
        radius * 0.55,
        Paint()..color = outer,
      );
    }
    for (var p = 0; p < 3; p++) {
      final angle = turn + 0.5 + p * 2 * pi / 3;
      canvas.drawCircle(
        head + Offset(cos(angle), sin(angle)) * radius * 0.25,
        radius * 0.38,
        Paint()..color = inner,
      );
    }
    canvas.drawCircle(head, radius * 0.22, Paint()..color = outer);
  }

  void _leafShape(
    Canvas canvas,
    Offset base,
    double len,
    double angle,
    Paint p,
  ) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(angle);
    final leaf = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(len * 0.5, -len * 0.45, len, 0)
      ..quadraticBezierTo(len * 0.5, len * 0.45, 0, 0);
    canvas.drawPath(leaf, p);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GardenPainter old) =>
      old.plots != plots || old.columns != columns || old.cell != cell;
}
