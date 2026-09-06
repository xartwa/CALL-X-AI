import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/core/constants/app_strings.dart';
import 'package:callx_ai/core/widgets/app_action_button.dart';
import 'package:callx_ai/core/widgets/confirmation_dialog.dart';
import 'package:callx_ai/core/widgets/custom_tag_widget.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/core/utils/app_date_time.dart';
import 'package:callx_ai/core/utils/app_status_helper.dart';
import 'package:callx_ai/core/cubit/workspace_settings_cubit.dart';
import 'package:callx_ai/features/calls/cubit/calls_cubit.dart';
import 'package:callx_ai/features/calls/cubit/selected_call_cubit.dart';
import 'package:callx_ai/features/calls/models/call_history_model.dart';
import 'package:callx_ai/features/calls/widgets/call_action_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:toastification/toastification.dart';
import 'package:data_table_2/data_table_2.dart';

class CallsTableWidget extends StatefulWidget {
  final List<CallHistoryModel> calls;
  final Function(CallHistoryModel)? onRemoveCall;

  const CallsTableWidget({
    super.key,
    required this.calls,
    this.onRemoveCall,
  });

  @override
  State<CallsTableWidget> createState() => _CallsTableWidgetState();
}

class _CallsTableWidgetState extends State<CallsTableWidget> {
  final text = AppStrings.current;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  late List<CallHistoryModel> _sortedCalls;

  @override
  void initState() {
    super.initState();
    _sortedCalls = List.from(widget.calls);
  }

  @override
  void didUpdateWidget(CallsTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.calls != widget.calls) {
      _sortedCalls = List.from(widget.calls);
      if (_sortColumnIndex != null) {
        _sort(_sortColumnIndex!, _sortAscending);
      }
    }
  }

  void _sort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      _sortedCalls.sort((a, b) {
        int result = 0;
        switch (columnIndex) {
          case 0:
            result =
                a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
            break;
          case 1:
            result = a.companyName
                .toLowerCase()
                .compareTo(b.companyName.toLowerCase());
            break;
          case 2:
            result = a.phone.compareTo(b.phone);
            break;
          case 3:
            result = a.duration.compareTo(b.duration);
            break;
          case 4:
            result = (a.dateTime ?? DateTime(1900))
                .compareTo(b.dateTime ?? DateTime(1900));
            break;
          case 5:
            result = (a.leadPriority ?? '')
                .toLowerCase()
                .compareTo((b.leadPriority ?? '').toLowerCase());
            break;
          case 6:
            result = a.status.toLowerCase().compareTo(b.status.toLowerCase());
            break;
          case 7:
            result =
                a.assignee.toLowerCase().compareTo(b.assignee.toLowerCase());
            break;
          case 8:
            result = (a.nextFollowUpAt ?? DateTime(1900))
                .compareTo(b.nextFollowUpAt ?? DateTime(1900));
            break;
        }
        return ascending ? result : -result;
      });
    });
  }

  Color _getSemanticColor(BuildContext context, String value) {
    final state = context.read<WorkspaceSettingsCubit>().state;
    final lower = value.toLowerCase().trim();

    for (final tag in state.customTags) {
      if (tag.label.toLowerCase().trim() == lower) return tag.color;
    }

    return AppStatusHelper.getStatusColor(value);
  }

  @override
  Widget build(BuildContext context) {
    final text = AppStrings.current;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DataTable2(
      columnSpacing: 16,
      horizontalMargin: 18,
      minWidth: 1500,
      headingRowHeight: 52,
      dataRowHeight: 70,
      showCheckboxColumn: false,
      dividerThickness: 0.5,
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      headingRowColor: WidgetStatePropertyAll(
        isDark
            ? AppColors.darkSlateColor.withValues(alpha: 0.5)
            : const Color(0xFFF1F5F9),
      ),
      headingTextStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        fontSize: 11.5,
        letterSpacing: 0.6,
      ),
      dataTextStyle: TextStyle(
        fontSize: 12.5,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        fontWeight: FontWeight.w500,
      ),

      columns: [
        DataColumn2(
            label: const Text('CONTACT'), size: ColumnSize.L, onSort: _sort),
        DataColumn2(
            label: const Text('COMPANY'), size: ColumnSize.L, onSort: _sort),
        DataColumn2(
            label: Text(text.phone.toUpperCase()),
            size: ColumnSize.L,
            onSort: _sort),
        DataColumn2(
            label: const Text('DURATION'), size: ColumnSize.M, onSort: _sort),
        DataColumn2(
            label: Text(text.dateTime.toUpperCase()),
            size: ColumnSize.L,
            onSort: _sort),
        DataColumn2(
            label: const Text('PRIORITY'), size: ColumnSize.M, onSort: _sort),
        DataColumn2(
            label: Text(text.status.toUpperCase()),
            size: ColumnSize.M,
            onSort: _sort),
        DataColumn2(
            label: Text(text.assignee.toUpperCase()),
            size: ColumnSize.M,
            onSort: _sort),
        DataColumn2(
            label: const Text('FOLLOW-UP'), size: ColumnSize.M, onSort: _sort),
        DataColumn2(
            label: Text(text.actions.toUpperCase()), size: ColumnSize.L),
      ],
      rows: _sortedCalls.map((call) {
        final isSelected =
            context.watch<CallsCubit>().state.selectedCall?.id == call.id ||
                context.watch<SelectedCallCubit>().state?.id == call.id;

        return DataRow2(
          selected: isSelected,
          onSelectChanged: (_) {
            context.read<CallsCubit>().selectCall(call);
            context.read<SelectedCallCubit>().selectCall(call);
          },
          color: WidgetStateProperty.resolveWith<Color?>((s) {
            if (s.contains(WidgetState.selected)) {
              return isDark
                  ? const Color(0xFF1D284F).withValues(alpha: 0.45)
                  : context.colors.primaryLightColor.withValues(alpha: 0.09);
            }
            if (s.contains(WidgetState.hovered)) {
              return isDark
                  ? Colors.white.withValues(alpha: 0.035)
                  : context.colors.primaryLightColor.withValues(alpha: 0.04);
            }
            return null;
          }),
          cells: [
            // Contact Name (Clickable) with Call Direction Icon
            DataCell(InkWell(
              onTap: () {
                context.read<CallsCubit>().selectCall(call);
                context.read<SelectedCallCubit>().selectCall(call);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Tooltip(
                    message: call.direction == 'Inbound'
                        ? 'Incoming Call (Inbound)'
                        : 'Outgoing Call (Outbound)',
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: (call.direction.toLowerCase() == 'inbound')
                            ? const Color(0xFF10B981).withValues(alpha: 0.15)
                            : const Color(0xFF6366F1).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        (call.direction.toLowerCase() == 'inbound')
                            ? CupertinoIcons.phone_arrow_down_left
                            : CupertinoIcons.phone_arrow_up_right,
                        size: 11,
                        color: (call.direction.toLowerCase() == 'inbound')
                            ? const Color(0xFF10B981)
                            : const Color(0xFF6366F1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      call.fullName.orDash,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),

            // Company
            DataCell(Text(
              call.companyName.orDash,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),

            // Phone
            DataCell(InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: call.phone));
                AppUtils.showSnackBar(
                  context: context,
                  extraMessage: 'Copied: ${call.phone}',
                  toastificationType: ToastificationType.success,
                );
              },
              child: Text(
                call.phone.orDash,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            )),

            // Duration
            DataCell(Text(
              call.duration.orDash,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            )),

            // Date - Time
            DataCell(Text(
              AppDateTime.displayDateTime(call.dateTime),
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),

            // Priority
            DataCell(
              CustomTagWidget(
                label: call.leadPriority ?? 'Warm',
                color: _getSemanticColor(context, call.leadPriority ?? 'Warm'),
              ),
            ),

            // Status
            DataCell(
              CustomTagWidget(
                label: call.status,
                color: _getSemanticColor(context, call.status),
              ),
            ),

            // Assignee
            DataCell(Text(
              call.assignee.orDash,
              style: TextStyle(
                fontSize: 12,
                fontWeight: call.assignee.toLowerCase() == 'ai'
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),

            // Follow-Up
            DataCell(Text(
              AppDateTime.displayDateOrDateTime(call.nextFollowUpDate),
              style: TextStyle(
                fontSize: 12,
                fontWeight: call.nextFollowUpDate != null
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),

            // Actions (Call, View/Select, Delete)
            DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
              AppActionButton(
                type: AppActionType.call,
                onTap: () => CallActionDialog.show(
                  context,
                  fullName: call.fullName,
                  phone: call.phone,
                  customerId: call.customerId,
                ),

              ),
              const SizedBox(width: 8),
              AppActionButton(
                type: AppActionType.view,
                onTap: () {
                  context.read<CallsCubit>().selectCall(call);
                  context.read<SelectedCallCubit>().selectCall(call);
                },
              ),
              const SizedBox(width: 8),
              AppActionButton(
                type: AppActionType.delete,
                onTap: () {
                  ConfirmationDialog.show(
                    context,
                    title: 'Delete Call Log',
                    message:
                        'Are you sure you want to delete the call record for "${call.fullName}"?',
                    confirmLabel: text.delete,
                    onConfirm: () {
                      widget.onRemoveCall?.call(call);
                      AppUtils.showSnackBar(
                        context: context,
                        extraMessage: 'Call record deleted successfully',
                        toastificationType: ToastificationType.success,
                      );
                    },
                  );
                },
              ),
            ])),
          ],
        );
      }).toList(),
    );
  }
}
