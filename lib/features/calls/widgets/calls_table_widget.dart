import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/core/constants/app_strings.dart';
import 'package:callx_ai/core/widgets/app_action_button.dart';
import 'package:callx_ai/core/widgets/confirmation_dialog.dart';
import 'package:callx_ai/core/widgets/custom_tag_widget.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/core/cubit/workspace_settings_cubit.dart';
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
            final dateA = '${a.callDate} ${a.callTime}';
            final dateB = '${b.callDate} ${b.callTime}';
            result = dateA.compareTo(dateB);
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
            final tagA = a.tags.isNotEmpty ? a.tags.first.toLowerCase() : '';
            final tagB = b.tags.isNotEmpty ? b.tags.first.toLowerCase() : '';
            result = tagA.compareTo(tagB);
            break;
          case 9:
            result = (a.nextFollowUpDate ?? '')
                .compareTo(b.nextFollowUpDate ?? '');
            break;
        }
        return ascending ? result : -result;
      });
    });
  }

  Color _getSemanticColor(BuildContext context, String value) {
    final state = context.read<WorkspaceSettingsCubit>().state;
    final lower = value.toLowerCase();

    for (final tag in state.leadStatuses) {
      if (tag.label.toLowerCase() == lower) return tag.color;
    }
    for (final tag in state.leadPriorities) {
      if (tag.label.toLowerCase() == lower) return tag.color;
    }
    for (final tag in state.leadQualities) {
      if (tag.label.toLowerCase() == lower) return tag.color;
    }
    for (final tag in state.customTags) {
      if (tag.label.toLowerCase() == lower) return tag.color;
    }
    for (final tag in state.callStatuses) {
      if (tag.label.toLowerCase() == lower) return tag.color;
    }

    if (lower.contains('completed') ||
        lower.contains('qualified') ||
        lower.contains('hot') ||
        lower.contains('vip')) {
      return const Color(0xFF10B981);
    }
    if (lower.contains('warm') ||
        lower.contains('queued') ||
        lower.contains('upcoming') ||
        lower.contains('pending')) {
      return const Color(0xFFF59E0B);
    }
    if (lower.contains('failed') ||
        lower.contains('cold') ||
        lower.contains('lost') ||
        lower.contains('cancelled')) {
      return const Color(0xFFEF4444);
    }
    return const Color(0xFF3B82F6);
  }

  @override
  Widget build(BuildContext context) {
    final text = AppStrings.current;

    return DataTable2(
      columnSpacing: 16,
      horizontalMargin: 16,
      minWidth: 1600,
      headingRowHeight: 55,
      dataRowHeight: 64,
      showCheckboxColumn: false,
      dividerThickness: 0.5,
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      headingRowColor: WidgetStatePropertyAll(context.colors.skyBlueColor),
      headingTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: context.colors.blackColor,
        fontSize: 12,
        letterSpacing: 0.3,
      ),
      dataTextStyle: TextStyle(
        fontSize: 12.5,
        color: context.colors.blackColor.withValues(alpha: 0.87),
      ),
      columns: [
        DataColumn2(
            label: const Text('Contact'), size: ColumnSize.L, onSort: _sort),
        DataColumn2(
            label: const Text('Company'), size: ColumnSize.L, onSort: _sort),
        DataColumn2(label: Text(text.phone), size: ColumnSize.L, onSort: _sort),
        DataColumn2(
            label: const Text('Duration'), size: ColumnSize.M, onSort: _sort),
        DataColumn2(
            label: Text(text.dateTime), size: ColumnSize.L, onSort: _sort),
        DataColumn2(
            label: const Text('Priority'), size: ColumnSize.M, onSort: _sort),
        DataColumn2(
            label: Text(text.status), size: ColumnSize.M, onSort: _sort),
        DataColumn2(
            label: Text(text.assignee), size: ColumnSize.M, onSort: _sort),
        DataColumn2(
            label: const Text('Tag'), size: ColumnSize.M, onSort: _sort),
        DataColumn2(
            label: const Text('Follow-Up'), size: ColumnSize.M, onSort: _sort),
        DataColumn2(label: Text(text.actions), size: ColumnSize.L),
      ],
      rows: _sortedCalls.map((call) {
        final isSelected =
            context.watch<SelectedCallCubit>().state?.id == call.id;

        return DataRow2(
          selected: isSelected,
          onSelectChanged: (_) =>
              context.read<SelectedCallCubit>().selectCall(call),
          color: WidgetStateProperty.resolveWith<Color?>((s) {
            if (s.contains(WidgetState.selected)) {
              return context.colors.skyBlueColor.withValues(alpha: 0.4);
            }
            if (s.contains(WidgetState.hovered)) {
              return context.colors.skyBlueColor.withValues(alpha: 0.25);
            }
            return null;
          }),
          cells: [
            // Contact Name (Clickable)
            DataCell(InkWell(
              onTap: () => context.read<SelectedCallCubit>().selectCall(call),
              child: Text(
                call.fullName.isNotEmpty ? call.fullName : 'No Name',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )),

            // Company
            DataCell(Text(
              call.companyName.isNotEmpty ? call.companyName : '-',
              style: TextStyle(
                fontSize: 12,
                color: context.colors.primaryLightColor,
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
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(CupertinoIcons.phone_fill,
                    size: 11, color: context.colors.darkGreyColor),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    call.phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.blackColor.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ]),
            )),

            // Duration
            DataCell(Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.stopwatch,
                  size: 12,
                  color: context.colors.darkGreyColor,
                ),
                const SizedBox(width: 4),
                Text(
                  call.duration.isNotEmpty ? call.duration : '0:00',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: call.duration != '0:00'
                        ? (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87)
                        : context.colors.darkGreyColor,
                  ),
                ),
              ],
            )),

            // Date - Time
            DataCell(Text(
              '${call.callDate} - ${call.callTime}',
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
            DataCell(Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  call.assignee.toLowerCase() == 'ai'
                      ? CupertinoIcons.bolt_badge_a
                      : CupertinoIcons.person_fill,
                  size: 12,
                  color: call.assignee.toLowerCase() == 'ai'
                      ? Theme.of(context).colorScheme.primary
                      : context.colors.darkGreyColor,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    call.assignee,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: call.assignee.toLowerCase() == 'ai'
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: call.assignee.toLowerCase() == 'ai'
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )),

            // Tag
            DataCell(
              call.tags.isEmpty
                  ? Text('-',
                      style: TextStyle(color: context.colors.darkGreyColor))
                  : CustomTagWidget(
                      label: call.tags.first,
                      color: _getSemanticColor(context, call.tags.first),
                    ),
            ),

            // Follow-Up
            DataCell(Text(
              (call.nextFollowUpDate != null &&
                      call.nextFollowUpDate!.isNotEmpty)
                  ? call.nextFollowUpDate!
                  : '-',
              style: TextStyle(
                fontSize: 12,
                fontWeight: (call.nextFollowUpDate != null &&
                        call.nextFollowUpDate!.isNotEmpty)
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: (call.nextFollowUpDate != null &&
                        call.nextFollowUpDate!.isNotEmpty)
                    ? context.colors.primaryLightColor
                    : context.colors.darkGreyColor,
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
                ),
              ),
              const SizedBox(width: 8),
              AppActionButton(
                type: AppActionType.view,
                onTap: () =>
                    context.read<SelectedCallCubit>().selectCall(call),
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
