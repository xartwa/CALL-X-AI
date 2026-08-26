import '../domain/entities/dashboard_snapshot.dart';

enum DashboardStatus { initial, loading, refreshing, success, empty, failure }

class DashboardState {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.snapshot,
    this.error,
  });

  final DashboardStatus status;
  final DashboardSnapshot? snapshot;
  final DashboardError? error;

  bool get hasData => snapshot != null;

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardSnapshot? snapshot,
    DashboardError? error,
    bool clearError = false,
  }) =>
      DashboardState(
        status: status ?? this.status,
        snapshot: snapshot ?? this.snapshot,
        error: clearError ? null : error ?? this.error,
      );
}

enum DashboardErrorKind { unauthorized, network, timeout, data, unknown }

class DashboardError {
  const DashboardError(this.kind);
  final DashboardErrorKind kind;
}
