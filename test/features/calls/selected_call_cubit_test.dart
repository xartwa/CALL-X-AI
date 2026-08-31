import 'package:flutter_test/flutter_test.dart';
import 'package:callx_ai/features/calls/cubit/selected_call_cubit.dart';
import 'package:callx_ai/features/calls/models/call_history_model.dart';

void main() {
  group('SelectedCallCubit Tests', () {
    late SelectedCallCubit cubit;

    setUp(() {
      cubit = SelectedCallCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is null', () {
      expect(cubit.state, isNull);
    });

    test('selectCall emits selected call', () {
      final call = CallHistoryModel(
        id: '1',
        fullName: 'Test User',
        phone: '0912 000 1122',
        status: 'Completed',
        assignee: 'AI',
        duration: '2:15',
        callTime: '10:00',
        callDate: '2026/08/29',
      );

      cubit.selectCall(call);
      expect(cubit.state, equals(call));
    });

    test('updateNotes updates notes in current selected call state', () {
      final call = CallHistoryModel(
        id: '1',
        fullName: 'Test User',
        phone: '0912 000 1122',
        status: 'Completed',
        assignee: 'AI',
        duration: '2:15',
        callTime: '10:00',
        callDate: '2026/08/29',
      );

      cubit.selectCall(call);
      cubit.updateNotes('New discussion points');
      expect(cubit.state?.notes, 'New discussion points');
    });

    test('updateFollowUpDate updates nextFollowUpDate in state', () {
      final call = CallHistoryModel(
        id: '1',
        fullName: 'Test User',
        phone: '0912 000 1122',
        status: 'Completed',
        assignee: 'AI',
        duration: '2:15',
        callTime: '10:00',
        callDate: '2026/08/29',
      );

      cubit.selectCall(call);
      final followUp = DateTime.utc(2026, 9, 10, 7);
      cubit.updateFollowUpDate(followUp);
      expect(cubit.state?.nextFollowUpDate, followUp);
    });

    test('clearSelection emits null', () {
      final call = CallHistoryModel(
        id: '1',
        fullName: 'Test User',
        phone: '0912 000 1122',
        status: 'Completed',
        assignee: 'AI',
        duration: '2:15',
        callTime: '10:00',
        callDate: '2026/08/29',
      );

      cubit.selectCall(call);
      expect(cubit.state, isNotNull);

      cubit.clearSelection();
      expect(cubit.state, isNull);
    });
  });
}
