import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/core/widgets/spaced_text.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../domain/entities/dashboard_snapshot.dart';
import 'package:callx_ai/core/widgets/app_feedback.dart';

class CallReportsCard extends StatelessWidget {
  const CallReportsCard({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<DashboardCubit>().state;
    final reports = state.snapshot?.callReports;
    if (state.status == DashboardStatus.loading && reports == null) {
      return const SizedBox(height: 210, child: AppLoadingView());
    }
    if (reports == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: context.colors.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: context.colors.mediumGreyColor.withValues(alpha: 0.25))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SpacedText(
            text: 'Call Reports',
            color: context.colors.blackColor,
            fontWeight: FontWeight.w700,
            fontSize: 16),
        const SizedBox(height: 24),
        Row(children: [
          SizedBox(
              width: 110,
              height: 110,
              child: Stack(children: [
                CustomPaint(
                    size: const Size(110, 110),
                    painter: _DonutChartPainter(
                        sections: reports.items
                            .map((item) => _ChartSection(
                                value: item.percentage,
                                color: _parseColor(item.colorHex)))
                            .toList())),
                Center(
                    child: Text('${reports.total}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.colors.blackColor))),
              ])),
          const SizedBox(width: 24),
          Expanded(
              child: Column(
                  children: reports.items
                      .map((item) => _LegendItem.fromReport(item))
                      .toList())),
        ]),
      ]),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem(
      {required this.title, required this.percentage, required this.color});
  factory _LegendItem.fromReport(DashboardCallReportItem item) => _LegendItem(
      title: item.label,
      percentage: item.percentage,
      color: _parseColor(item.colorHex));
  final String title;
  final double percentage;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 8),
        Expanded(
            child: Text(title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 11.5, color: context.colors.darkGreyColor))),
        Text('${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: context.colors.blackColor)),
      ]));
}

class _ChartSection {
  const _ChartSection({required this.value, required this.color});
  final double value;
  final Color color;
}

class _DonutChartPainter extends CustomPainter {
  const _DonutChartPainter({required this.sections});
  final List<_ChartSection> sections;
  @override
  void paint(Canvas canvas, Size size) {
    final total =
        sections.fold<double>(0, (sum, section) => sum + section.value);
    if (total <= 0) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height).deflate(7);
    var start = -math.pi / 2;
    for (final section in sections) {
      paint.color = section.color;
      final sweep = section.value / total * 2 * math.pi;
      canvas.drawArc(rect, start, math.max(0, sweep - 0.05), false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) =>
      oldDelegate.sections != sections;
}

Color _parseColor(String value) {
  final parsed = int.tryParse(value.replaceFirst('#', ''), radix: 16);
  return parsed == null ? const Color(0xFF6366F1) : Color(0xFF000000 | parsed);
}
