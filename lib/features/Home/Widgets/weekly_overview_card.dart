import 'dart:math' as math;

import 'package:elbess_store/core/utils/size_config.dart';
import 'package:elbess_store/features/Home/data/home_dashboard_repo.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class WeeklyOverviewCard extends StatelessWidget {
  final WeeklyOverviewSummary summary;

  const WeeklyOverviewCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final ds = SizeConfig.defaultSize!;

    return Container(
      padding: EdgeInsets.all(ds * 1.8),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2B28),
        borderRadius: BorderRadius.circular(ds * 2.3),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF32302D), Color(0xFF262421)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly overview',
                      style: TextStyle(
                        fontSize: ds * 2.2,
                        fontFamily: 'semi',
                        color: Colors.white.withOpacity(0.96),
                      ),
                    ),
                    Gap(ds * 0.3),
                    Text(
                      _formatRevenue(summary.totalRevenue),
                      style: TextStyle(
                        fontSize: ds * 3.2,
                        height: 1,
                        fontFamily: 'bold',
                        color: Colors.white,
                      ),
                    ),
                    Gap(ds * 0.6),
                    Text(
                      '${summary.totalOrders} orders this week',
                      style: TextStyle(
                        fontSize: ds * 1.5,
                        fontFamily: 'semi',
                        color: Colors.white.withOpacity(0.62),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ds * 1.4,
                  vertical: ds * 0.8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3FF),
                  borderRadius: BorderRadius.circular(ds * 2.5),
                ),
                child: Text(
                  'This week',
                  style: TextStyle(
                    fontSize: ds * 1.3,
                    fontFamily: 'semi',
                    color: const Color(0xFF4A47D1),
                  ),
                ),
              ),
            ],
          ),
          Gap(ds * 1.6),
          Wrap(
            spacing: ds * 2,
            runSpacing: ds * 1,
            children: const [
              _LegendDot(color: Color(0xFF6C73FF), label: 'Orders'),
              _LegendDot(color: Color(0xFF1FC79C), label: 'Revenue'),
              _LegendDot(color: Color(0xFF9C5AF8), label: 'Delivered'),
            ],
          ),
          Gap(ds * 1.2),
          SizedBox(
            height: ds * 20,
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: ds * 4.4,
                    right: ds * 3.7,
                    top: ds * 1,
                    bottom: ds * 2.5,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(ds * 1.2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF323840).withOpacity(0.28),
                        borderRadius: BorderRadius.circular(ds * 1.2),
                      ),
                      child: CustomPaint(
                        painter: _WeeklyOverviewPainter(summary: summary),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: ds * 1.7,
                  bottom: ds * 2.7,
                  child: _YAxisLabels(ds: ds),
                ),
                Positioned(
                  right: 0,
                  top: ds * 1.7,
                  bottom: ds * 2.7,
                  child: _RightAxisLabels(ds: ds),
                ),
                Positioned(
                  left: ds * 4.4,
                  right: ds * 3.7,
                  bottom: 0,
                  child: _WeekdayLabels(ds: ds),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatRevenue(double value) {
  if (value == value.roundToDouble()) {
    return '${value.toInt()} dz';
  }

  return '${value.toStringAsFixed(2)} dz';
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const Gap(6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontFamily: 'semi',
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _YAxisLabels extends StatelessWidget {
  const _YAxisLabels({required this.ds});

  final double ds;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _AxisLabel(value: '30', ds: ds),
        _AxisLabel(value: '25', ds: ds),
        _AxisLabel(value: '20', ds: ds),
        _AxisLabel(value: '15', ds: ds),
        _AxisLabel(value: '10', ds: ds),
      ],
    );
  }
}

class _RightAxisLabels extends StatelessWidget {
  const _RightAxisLabels({required this.ds});

  final double ds;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AxisLabel(value: '3k', ds: ds),
        _AxisLabel(value: '2k', ds: ds),
        _AxisLabel(value: '2k', ds: ds),
        _AxisLabel(value: '1k', ds: ds),
      ],
    );
  }
}

class _AxisLabel extends StatelessWidget {
  const _AxisLabel({required this.value, required this.ds});

  final String value;
  final double ds;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: TextStyle(
        color: Colors.white.withOpacity(0.48),
        fontFamily: 'regular',
        fontSize: ds * 1.15,
      ),
    );
  }
}

class _WeekdayLabels extends StatelessWidget {
  const _WeekdayLabels({required this.ds});

  final double ds;

  @override
  Widget build(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days
          .map(
            (day) => Text(
              day,
              style: TextStyle(
                color: Colors.white.withOpacity(0.62),
                fontFamily: 'regular',
                fontSize: ds * 1.1,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _WeeklyOverviewPainter extends CustomPainter {
  _WeeklyOverviewPainter({required this.summary});

  final WeeklyOverviewSummary summary;

  @override
  void paint(Canvas canvas, Size size) {
    const leftInset = 6.0;
    const rightInset = 6.0;
    const topInset = 8.0;
    const bottomInset = 20.0;

    final chartRect = Rect.fromLTWH(
      leftInset,
      topInset,
      size.width - leftInset - rightInset,
      size.height - topInset - bottomInset,
    );

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    final gridStep = chartRect.height / 4;
    for (var index = 0; index <= 4; index++) {
      final y = chartRect.top + gridStep * index;
      canvas.drawLine(Offset(chartRect.left, y), Offset(chartRect.right, y), gridPaint);
    }

    final ordersValues = summary.ordersSeries;
    final revenueValues = summary.revenueSeries.map((value) => value / 1000).toList();
    final deliveredValues = summary.deliveredSeries;
    final maxValue = _maxSeriesValue([ordersValues, revenueValues, deliveredValues]);
    const minValue = 0.0;

    final ordersPoints = _buildPoints(chartRect, ordersValues, minValue, maxValue);
    final revenuePoints = _buildPoints(chartRect, revenueValues, minValue, maxValue);
    final deliveredPoints = _buildPoints(chartRect, deliveredValues, minValue, maxValue);

    if (ordersPoints.isEmpty) {
      return;
    }

    final fillPath = _smoothPath(ordersPoints)
      ..lineTo(ordersPoints.last.dx, chartRect.bottom)
      ..lineTo(ordersPoints.first.dx, chartRect.bottom)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF6C73FF).withOpacity(0.28),
          const Color(0xFF6C73FF).withOpacity(0.05),
        ],
      ).createShader(chartRect)
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    final ordersPaint = Paint()
      ..color = const Color(0xFF6C73FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_smoothPath(ordersPoints), ordersPaint);

    final revenuePaint = Paint()
      ..color = const Color(0xFF1FC79C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    _drawDashedPath(canvas, _smoothPath(revenuePoints), revenuePaint, [7, 6]);

    final deliveredPaint = Paint()
      ..color = const Color(0xFF9C5AF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    _drawDashedPath(canvas, _smoothPath(deliveredPoints), deliveredPaint, [1, 5]);

    _drawPoints(canvas, ordersPoints, const Color(0xFF6C73FF));
    _drawPoints(canvas, revenuePoints, const Color(0xFF1FC79C));
    _drawPoints(canvas, deliveredPoints, const Color(0xFF9C5AF8));

    final highlightWidth = chartRect.width * 0.32;
    final highlightRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(
          chartRect.left + chartRect.width * 0.57,
          chartRect.top + chartRect.height * 0.42,
        ),
        width: highlightWidth,
        height: chartRect.height * 0.52,
      ),
      const Radius.circular(14),
    );

    canvas.drawRRect(
      highlightRect,
      Paint()..color = Colors.white.withOpacity(0.04),
    );
  }

  List<Offset> _buildPoints(Rect rect, List<double> values, double minValue, double maxValue) {
    if (values.isEmpty) {
      return <Offset>[];
    }

    final points = <Offset>[];
    final stepX = values.length == 1 ? 0.0 : rect.width / (values.length - 1);

    for (var index = 0; index < values.length; index++) {
      final value = values[index].clamp(minValue, maxValue);
      final normalized = (value - minValue) / (maxValue - minValue);
      final x = rect.left + stepX * index;
      final y = rect.bottom - (rect.height * normalized);
      points.add(Offset(x, y));
    }

    return points;
  }

  double _maxSeriesValue(List<List<double>> series) {
    final flattened = series.expand((values) => values);
    final maxValue = flattened.isEmpty ? 0.0 : flattened.reduce(math.max);
    return math.max(maxValue, 1.0);
  }

  Path _smoothPath(List<Offset> points) {
    if (points.isEmpty) {
      return Path();
    }

    if (points.length == 1) {
      return Path()..moveTo(points.first.dx, points.first.dy);
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (var index = 0; index < points.length - 1; index++) {
      final current = points[index];
      final next = points[index + 1];
      final controlPoint1 = Offset((current.dx + next.dx) / 2, current.dy);
      final controlPoint2 = Offset((current.dx + next.dx) / 2, next.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        next.dx,
        next.dy,
      );
    }

    return path;
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    List<double> dashArray,
  ) {
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      var draw = true;
      var index = 0;

      while (distance < metric.length) {
        final dashLength = dashArray[index % dashArray.length];
        final nextDistance = math.min(distance + dashLength, metric.length);

        if (draw) {
          canvas.drawPath(metric.extractPath(distance, nextDistance), paint);
        }

        distance = nextDistance;
        draw = !draw;
        index++;
      }
    }
  }

  void _drawPoints(Canvas canvas, List<Offset> points, Color color) {
    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final innerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 6.4, outlinePaint);
      canvas.drawCircle(point, 3.8, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyOverviewPainter oldDelegate) {
    return oldDelegate.summary != summary;
  }
}
