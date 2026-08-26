import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/entities/dashboard_snapshot.dart';
import '../domain/usecases/get_dashboard_snapshot.dart';
import 'dashboard_state.dart';
import '../../../core/errors/app_exception.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._getSnapshot) : super(const DashboardState());

  final GetDashboardSnapshot _getSnapshot;

  Future<void> load({bool refresh = false}) async {
    if (state.status == DashboardStatus.loading ||
        state.status == DashboardStatus.refreshing) {
      return;
    }
    emit(state.copyWith(
      status: refresh && state.hasData
          ? DashboardStatus.refreshing
          : DashboardStatus.loading,
      clearError: true,
    ));
    try {
      final snapshot = await _getSnapshot();
      emit(state.copyWith(
        status:
            snapshot.todayCalls.items.isEmpty && snapshot.kpi.totalCalls == 0
                ? DashboardStatus.empty
                : DashboardStatus.success,
        snapshot: snapshot,
        clearError: true,
      ));
    } on AppException catch (exception) {
      final kind = switch (exception.type) {
        AppErrorType.unauthorized => DashboardErrorKind.unauthorized,
        AppErrorType.network => DashboardErrorKind.network,
        AppErrorType.timeout => DashboardErrorKind.timeout,
        AppErrorType.invalidData => DashboardErrorKind.data,
        _ => DashboardErrorKind.unknown,
      };
      emit(state.copyWith(
        status: DashboardStatus.failure,
        error: DashboardError(kind),
      ));
    }
  }

  Future<void> retry() => load(refresh: state.hasData);
}

DashboardTodayCall? findDashboardCall(DashboardState state, String id) {
  for (final call
      in state.snapshot?.todayCalls.items ?? const <DashboardTodayCall>[]) {
    if (call.id == id) return call;
  }
  return null;
}
