import 'package:flutter_test/flutter_test.dart';
import 'package:callx_ai/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:callx_ai/features/dashboard/cubit/dashboard_state.dart';
import 'package:callx_ai/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:callx_ai/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:callx_ai/features/dashboard/domain/usecases/get_dashboard_snapshot.dart';
import 'package:callx_ai/core/errors/app_exception.dart';

class _FakeRepository implements DashboardRepository {
  _FakeRepository(this.result);
  final Future<DashboardSnapshot> Function() result;
  @override
  Future<DashboardSnapshot> getSnapshot() => result();
}

DashboardSnapshot _snapshot() => DashboardSnapshot(
      generatedAt: DateTime.utc(2026, 8, 26),
      timezone: 'UTC',
      date: DateTime.utc(2026, 8, 26),
      kpi: const DashboardKpi(
          totalCalls: 1, callsToday: 1, successRate: 0, totalFollowUps: 0),
      todayCalls: DashboardTodayCalls(
          date: DateTime.utc(2026, 8, 26),
          count: 0,
          hasMore: false,
          items: const []),
      callReports: const DashboardCallReports(total: 0, items: []),
    );

void main() {
  test('emits success after loading snapshot', () async {
    final cubit = DashboardCubit(
        GetDashboardSnapshot(_FakeRepository(() async => _snapshot())));
    await cubit.load();
    expect(cubit.state.status, DashboardStatus.success);
    expect(cubit.state.snapshot?.kpi.totalCalls, 1);
    await cubit.close();
  });

  test('maps unauthorized failures to an explicit state', () async {
    final cubit = DashboardCubit(GetDashboardSnapshot(_FakeRepository(() async {
      throw const AppException(AppErrorType.unauthorized);
    })));
    await cubit.load();
    expect(cubit.state.status, DashboardStatus.failure);
    expect(cubit.state.error?.kind, DashboardErrorKind.unauthorized);
    await cubit.close();
  });
}
