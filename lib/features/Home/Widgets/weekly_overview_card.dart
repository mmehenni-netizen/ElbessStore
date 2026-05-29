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
        color: Colors.white,
        borderRadius: BorderRadius.circular(ds * 2.3),
        border: Border.all(color: const Color(0xFFE8EBF2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
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
                        color: const Color(0xFF111827),
                      ),
                    ),
                    Gap(ds * 0.3),
                    Text(
                      'Delivered revenue',
                      style: TextStyle(
                        fontSize: ds * 1.2,
                        fontFamily: 'medium',
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Gap(ds * 0.3),
                    Text(
                      _formatRevenue(summary.deliveredRevenue),
                      style: TextStyle(
                        fontSize: ds * 3.2,
                        height: 1,
                        fontFamily: 'bold',
                        color: const Color(0xFF111827),
                      ),
                    ),
                    Gap(ds * 0.6),
                    Wrap(
                      spacing: ds * 0.8,
                      runSpacing: ds * 0.8,
                      children: [
                        _MetricChip(label: 'Orders', value: '${summary.totalOrders}'),
                        _MetricChip(label: 'Delivered', value: '${summary.deliveredCount}'),
                        _MetricChip(label: 'Avg order', value: _formatRevenue(summary.averageOrderValue)),
                      ],
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
                  color: const Color(0xFFF5F7FB),
                  borderRadius: BorderRadius.circular(ds * 2.5),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  'This week',
                  style: TextStyle(
                    fontSize: ds * 1.3,
                    fontFamily: 'semi',
                    color: const Color(0xFF475569),
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
              _LegendDot(color: Color(0xFF4F6DF5), label: 'Orders'),
              _LegendDot(color: Color(0xFF17B887), label: 'Revenue'),
              _LegendDot(color: Color(0xFF8B5CF6), label: 'Delivered'),
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(ds * 1.2),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: CustomPaint(
                      painter: _WeeklyOverviewPainter(summary: summary),
                      child: const SizedBox.expand(),
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
            color: const Color(0xFF475569),
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
        color: const Color(0xFF94A3B8),
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
                color: const Color(0xFF94A3B8),
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
      ..color = const Color(0xFFE2E8F0)
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
          const Color(0xFF4F6DF5).withOpacity(0.16),
          const Color(0xFF4F6DF5).withOpacity(0.03),
        ],
      ).createShader(chartRect)
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    final ordersPaint = Paint()
      ..color = const Color(0xFF4F6DF5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_smoothPath(ordersPoints), ordersPaint);

    final revenuePaint = Paint()
      ..color = const Color(0xFF17B887)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    _drawDashedPath(canvas, _smoothPath(revenuePoints), revenuePaint, [7, 6]);

    final deliveredPaint = Paint()
      ..color = const Color(0xFF8B5CF6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    _drawDashedPath(canvas, _smoothPath(deliveredPoints), deliveredPaint, [1, 5]);

    _drawPoints(canvas, ordersPoints, const Color(0xFF4F6DF5));
    _drawPoints(canvas, revenuePoints, const Color(0xFF17B887));
    _drawPoints(canvas, deliveredPoints, const Color(0xFF8B5CF6));

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
      Paint()..color = const Color(0xFF4F6DF5).withOpacity(0.05),
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

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'semi',
              color: Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'bold',
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}
