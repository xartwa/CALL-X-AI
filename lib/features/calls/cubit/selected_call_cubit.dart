import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/call_history_model.dart';

class SelectedCallCubit extends Cubit<CallHistoryModel?> {
  SelectedCallCubit() : super(null);

  void selectCall(CallHistoryModel call) => emit(call);
  void clearSelection() => emit(null);
}
