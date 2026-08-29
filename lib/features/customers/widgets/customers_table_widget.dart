import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/core/constants/app_strings.dart';
import 'package:callx_ai/core/routes/app_routes_path.dart';
import 'package:callx_ai/core/widgets/app_action_button.dart';
import 'package:callx_ai/core/widgets/confirmation_dialog.dart';
import 'package:callx_ai/core/widgets/custom_tag_widget.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/core/utils/app_date_time.dart';
import 'package:callx_ai/core/cubit/workspace_settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callx_ai/features/calls/widgets/call_action_dialog.dart';
import 'package:callx_ai/features/customers/models/customer_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import 'package:data_table_2/data_table_2.dart';

export '../models/customer_model.dart';

class UsersTableWidget extends StatefulWidget {
  final List<User> users;
  final Function(User) onRemoveUser;

  const UsersTableWidget({
    super.key,
    required this.users,
    required this.onRemoveUser,
  });

  @override
  State<UsersTableWidget> createState() => _UsersTableWidgetState();
}

class _UsersTableWidgetState extends State<UsersTableWidget> {
  final text = AppStrings.current;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  late List<User> _sortedUsers;

  @override
  void initState() {
    super.initState();
    _sortedUsers = List.from(widget.users);
  }

  @override
  void didUpdateWidget(UsersTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.users != widget.users) {
      _sortedUsers = List.from(widget.users);
      if (_sortColumnIndex != null) {
        _sort(_sortColumnIndex!, _sortAscending);
      }
    }
  }

  void _sort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      _sortedUsers.sort((a, b) {
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
            result = a.email.toLowerCase().compareTo(b.email.toLowerCase());
            break;
          case 4:
            result = (a.city.isNotEmpty ? a.city : a.country)
                .toLowerCase()
                .compareTo(
                    (b.city.isNotEmpty ? b.city : b.country).toLowerCase());
            break;
          case 5:
            result = a.leadPriority
                .toLowerCase()
                .compareTo(b.leadPriority.toLowerCase());
            break;
          case 6:
            result = a.leadStatus
                .toLowerCase()
                .compareTo(b.leadStatus.toLowerCase());
            break;
          case 7:
            final tagA = a.tags.isNotEmpty ? a.tags.first.toLowerCase() : '';
            final tagB = b.tags.isNotEmpty ? b.tags.first.toLowerCase() : '';
            result = tagA.compareTo(tagB);
            break;
          case 8:
            result = (a.nextFollowUpDate ?? DateTime(1900))
                .compareTo(b.nextFollowUpDate ?? DateTime(1900));
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

    if (lower.contains('qualified') ||
        lower.contains('won') ||
        lower.contains('active') ||
        lower.contains('excellent') ||
        lower.contains('hot') ||
        lower.contains('vip')) {
      return const Color(0xFFEF4444);
    }
    if (lower.contains('warm') ||
        lower.contains('callback') ||
        lower.contains('pending') ||
        lower.contains('branding')) {
      return const Color(0xFFF59E0B);
    }
    if (lower.contains('lost') ||
        lower.contains('cold') ||
        lower.contains('inactive') ||
        lower.contains('poor') ||
        lower.contains('developer') ||
        lower.contains('gc')) {
      return const Color(0xFF10B981);
    }
    return const Color(0xFF3B82F6);
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
      headingRowColor: WidgetStatePropertyAll(context.colors.skyBlueColor),
      headingTextStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: context.colors.darkGreyColor,
        fontSize: 11.5,
        letterSpacing: 0.6,
      ),
      dataTextStyle: TextStyle(
        fontSize: 12.5,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      columns: [
        DataColumn2(
            label: const Text('CUSTOMER'), size: ColumnSize.L, onSort: _sort),
        DataColumn2(
            label: const Text('COMPANY'), size: ColumnSize.L, onSort: _sort),
        DataColumn2(
            label: Text(text.phone.toUpperCase()),
            size: ColumnSize.L,
            onSort: _sort),
        DataColumn2(
            label: const Text('EMAIL'), size: ColumnSize.L, onSort: _sort),
        DataColumn2(
            label: const Text('LOCATION'), size: ColumnSize.L, onSort: _sort),
        DataColumn2(
            label: const Text('PRIORITY'), size: ColumnSize.L, onSort: _sort),
        DataColumn2(
            label: const Text('LEAD'), size: ColumnSize.L, onSort: _sort),
        DataColumn2(
            label: const Text('TAG'), size: ColumnSize.L, onSort: _sort),
        DataColumn2(
            label: const Text('FOLLOW-UP'), size: ColumnSize.L, onSort: _sort),
        DataColumn2(
            label: Text(text.actions.toUpperCase()), size: ColumnSize.L),
      ],
      rows: _sortedUsers.map((user) {
        return DataRow2(
          color: WidgetStateProperty.resolveWith<Color?>((s) {
            if (s.contains(WidgetState.hovered)) {
              return isDark
                  ? Colors.white.withValues(alpha: 0.035)
                  : context.colors.primaryLightColor.withValues(alpha: 0.04);
            }
            return null;
          }),
          cells: [
            DataCell(InkWell(
              onTap: () => context.goNamed(AppRoutesPath.customerDetailName,
                  pathParameters: {'id': user.id.toString()}),
              child: Flexible(
                child: Text(
                  user.fullName.orDash,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )),

            DataCell(Text(
              user.companyName.orDash,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),

            DataCell(InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: user.phone));
                AppUtils.showSnackBar(
                  context: context,
                  extraMessage: 'Copied: ${user.phone}',
                  toastificationType: ToastificationType.success,
                );
              },
              child: Text(
                user.phone.orDash,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )),

            DataCell(InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: user.email));
                AppUtils.showSnackBar(
                  context: context,
                  extraMessage: 'Copied: ${user.email}',
                  toastificationType: ToastificationType.success,
                );
              },
              child: Text(
                user.email.orDash,
                style: const TextStyle(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )),

            DataCell(Text(
              user.city.isNotEmpty
                  ? '${user.city}${user.state.isNotEmpty ? ', ${user.state}' : ''}'
                  : user.country.orDash,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),

            DataCell(
              CustomTagWidget(
                label: user.leadPriority,
                color: _getSemanticColor(context, user.leadPriority),
              ),
            ),

            DataCell(
              CustomTagWidget(
                label: user.leadStatus,
                color: _getSemanticColor(context, user.leadStatus),
              ),
            ),

            DataCell(
              user.tags.isEmpty
                  ? const Text(tableDash)
                  : CustomTagWidget(
                      label: user.tags.first,
                      color: _getSemanticColor(context, user.tags.first),
                    ),
            ),

            DataCell(Text(
              AppDateTime.displayDateOrDateTime(user.nextFollowUpDate),
              style: TextStyle(
                fontSize: 12,
                fontWeight: user.nextFollowUpDate != null
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),

            // Actions (Call, View Profile, Delete)
            DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
              AppActionButton(
                  type: AppActionType.call,
                  onTap: () => CallActionDialog.show(context,
                      fullName: user.fullName,
                      phone: user.phone,
                      customerId: user.id)),
              const SizedBox(width: 8),
              AppActionButton(
                  type: AppActionType.view,
                  onTap: () => context.goNamed(AppRoutesPath.customerDetailName,
                      pathParameters: {'id': user.id.toString()})),
              const SizedBox(width: 8),
              AppActionButton(
                  type: AppActionType.delete,
                  onTap: () {
                    ConfirmationDialog.show(context,
                        title: text.deleteCustomerConfirmTitle,
                        message: text.deleteCustomerConfirmMessage,
                        confirmLabel: text.delete, onConfirm: () {
                      widget.onRemoveUser(user);
                      AppUtils.showSnackBar(
                        context: context,
                        extraMessage: text.deleteCustomerSuccess,
                        toastificationType: ToastificationType.success,
                      );
                    });
                  }),
            ])),
          ],
        );
      }).toList(),
    );
  }
}
