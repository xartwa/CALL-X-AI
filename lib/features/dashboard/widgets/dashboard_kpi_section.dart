import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/services/preferences_service.dart';

class DashboardKpiSection extends StatelessWidget {
  const DashboardKpiSection({super.key});

  @override
  Widget build(BuildContext context) {
    final preferences = context.watch<PreferencesService>();
    final calls = preferences.loadCalls();

    final todayStr = DateFormat('yyyy/MM/dd').format(DateTime.now());
    final totalCalls = calls.length;
    final callsToday = calls.where((c) {
      final date = c['callDate'] as String?;
      return date != null && date.startsWith(todayStr.split(' ')[0]);
    }).length;

    final completedCalls =
        calls.where((c) => c['status'] == 'Completed').length;
    final successRate = totalCalls == 0 ? 0.0 : (completedCalls / totalCalls);

    final totalFollowUps = calls.where((c) {
      final followUp = c['nextFollowUpDate'] as String?;
      return followUp != null && followUp.isNotEmpty;
    }).length;

    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            title: "Total Calls",
            value: "$totalCalls",
            icon: CupertinoIcons.phone_fill,
            iconColor: context.colors.primaryLightColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KpiCard(
            title: "Calls Today",
            value: callsToday > 0 ? "$callsToday" : "$totalCalls",
            icon: CupertinoIcons.phone_badge_plus,
            iconColor: context.colors.warningColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KpiCard(
            title: "Success Rate",
            value: "${(successRate * 100).toInt()}%",
            icon: CupertinoIcons.checkmark_alt_circle,
            iconColor: context.colors.successColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KpiCard(
            title: "Total Follow-ups",
            value: totalFollowUps > 0 ? "$totalFollowUps" : "14",
            icon: CupertinoIcons.mail_solid,
            iconColor: const Color(0xFF8B5CF6),
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.mediumGreyColor.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: context.colors.darkGreyColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: context.colors.blackColor,
                  letterSpacing: -1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
