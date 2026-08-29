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
import 'cubit/dashboard_cubit.dart';
import 'cubit/dashboard_state.dart';
import 'domain/repositories/dashboard_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:callx_ai/core/routes/app_routes_path.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/core/widgets/app_pull_to_refresh.dart';
import 'domain/usecases/get_dashboard_snapshot.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodoCubit(context.read<PreferencesService>()),
      child: BlocProvider(
        create: (context) => DashboardCubit(
          GetDashboardSnapshot(context.read<DashboardRepository>()),
        )..load(),
        child: const _DashboardView(),
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    const content = SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardStatusBanner(),
          SizedBox(height: 16),
          // 1. Header (Overview + AI Engine Pill + Workspace Settings + Theme Mode)
          DashboardHeader(),
          SizedBox(height: 28),

          // 2. KPI Metrics Summary Cards
          DashboardKpiSection(),
          SizedBox(height: 28),

          _DashboardContent(),
        ],
      ),
    );
    return content.withPullToRefresh(
      scrollableChild: true,
      onRefresh: () async {
        context.read<TodoCubit>().loadTodos();
        await context.read<DashboardCubit>().load(refresh: true);
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          const sidePanel = Column(
            children: [
              QuickOperationsHub(),
              SizedBox(height: 24),
              CallReportsCard(),
              SizedBox(height: 24),
              TodoListCard(),
            ],
          );
          if (constraints.maxWidth < 1000) {
            return const Column(
              children: [
                TodayScheduledCallsSection(),
                SizedBox(height: 24),
                sidePanel,
              ],
            );
          }
          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 62, child: TodayScheduledCallsSection()),
              SizedBox(width: 24),
              Expanded(flex: 38, child: sidePanel),
            ],
          );
        },
      );
}

class _DashboardStatusBanner extends StatelessWidget {
  const _DashboardStatusBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.status != DashboardStatus.failure || state.error == null) {
          return const SizedBox.shrink();
        }
        final unauthorized =
            state.error!.kind == DashboardErrorKind.unauthorized;
        final message = unauthorized
            ? 'Your session has expired. Please sign in again.'
            : 'We could not refresh dashboard data. Check your connection and retry.';
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.colors.warningColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: context.colors.warningColor.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            Expanded(
                child: Text(message,
                    style: TextStyle(
                        color: context.colors.blackColor, fontSize: 12.5))),
            TextButton(
              onPressed: unauthorized
                  ? () async {
                      await context
                          .read<PreferencesService>()
                          .clearAuthSession();
                      if (context.mounted) context.go(AppRoutesPath.login);
                    }
                  : () => context.read<DashboardCubit>().retry(),
              child: Text(unauthorized ? 'Sign in' : 'Retry'),
            ),
          ]),
        );
      },
    );
  }
}
