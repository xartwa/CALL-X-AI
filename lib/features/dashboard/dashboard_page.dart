import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callx_ai/services/preferences_service.dart';
import 'cubit/todo_cubit.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_kpi_section.dart';
import 'widgets/today_scheduled_calls_section.dart';
import 'widgets/quick_operations_hub.dart';
import 'widgets/call_reports_card.dart';
import 'widgets/todo_list_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodoCubit(context.read<PreferencesService>()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header (Overview + AI Engine Pill + Workspace Settings + Theme Mode)
          DashboardHeader(),
          SizedBox(height: 28),

          // 2. KPI Metrics Summary Cards
          DashboardKpiSection(),
          SizedBox(height: 28),

          // 3. Workspace Layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT PANEL: 62% - Today's Upcoming Scheduled Calls
              Expanded(
                flex: 62,
                child: TodayScheduledCallsSection(),
              ),
              SizedBox(width: 24),

              // RIGHT PANEL: 38% - Quick Actions, Analytics & Local To-Do List
              Expanded(
                flex: 38,
                child: Column(
                  children: [
                    QuickOperationsHub(),
                    SizedBox(height: 24),
                    CallReportsCard(),
                    SizedBox(height: 24),
                    TodoListCard(),
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
