import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/core/widgets/spaced_text.dart';

class CallReportsCard extends StatelessWidget {
  const CallReportsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.mediumGreyColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SpacedText(
            text: "Call Reports",
            color: context.colors.blackColor,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // Donut Chart
              SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: const Size(110, 110),
                      painter: _DonutChartPainter(
                        sections: [
                          _ChartSection(
                            value: 36,
                            color: context.colors.primaryLightColor,
                          ),
                          _ChartSection(
                            value: 20,
                            color: context.colors.primaryLightColor
                                .withValues(alpha: 0.7),
                          ),
                          _ChartSection(
                            value: 12,
                            color: context.colors.primaryLightColor
                                .withValues(alpha: 0.4),
                          ),
                          _ChartSection(
                            value: 15,
                            color: context.colors.darkGreyColor,
                          ),
                          _ChartSection(
                            value: 17,
                            color: context.colors.lightGreyColor,
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Text(
                        "100%",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.colors.blackColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Legend
              Expanded(
                child: Column(
                  children: [
                    _LegendItem(
                      title: "No Answer",
                      percentage: 36,
                      color: context.colors.primaryLightColor,
                    ),
                    _LegendItem(
                      title: "Completed",
                      percentage: 20,
                      color: context.colors.primaryLightColor
                          .withValues(alpha: 0.7),
                    ),
                    _LegendItem(
                      title: "Dropped",
                      percentage: 17,
                      color: context.colors.primaryLightColor
                          .withValues(alpha: 0.4),
                    ),
                    _LegendItem(
                      title: "Call Back",
                      percentage: 12,
                      color: context.colors.darkGreyColor,
                    ),
                    _LegendItem(
                      title: "Already Bought",
                      percentage: 15,
                      color: context.colors.lightGreyColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String title;
  final int percentage;
  final Color color;

  const _LegendItem({
    required this.title,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11.5,
                color: context.colors.darkGreyColor,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            "$percentage%",
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: context.colors.blackColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartSection {
  final double value;
  final Color color;
  _ChartSection({required this.value, required this.color});
}

class _DonutChartPainter extends CustomPainter {
  final List<_ChartSection> sections;
  _DonutChartPainter({required this.sections});

  @override
  void paint(Canvas canvas, Size size) {
    double total = 0;
    for (var s in sections) {
      total += s.value;
    }

    if (total == 0) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    double startAngle = -math.pi / 2;
    const double strokeWidth = 14.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (var s in sections) {
      final sweepAngle = (s.value / total) * 2 * math.pi;

      paint.color = s.color;
      canvas.drawArc(
        rect.deflate(strokeWidth / 2),
        startAngle,
        sweepAngle - 0.05,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
