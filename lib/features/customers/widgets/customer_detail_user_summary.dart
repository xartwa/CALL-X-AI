import 'package:callx_ai/core/constants/app_strings.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/features/calls/widgets/call_action_dialog.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/features/customers/widgets/add_tag_dialog.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callx_ai/core/models/tag_model.dart';
import 'package:callx_ai/core/cubit/workspace_settings_cubit.dart';
import 'package:callx_ai/core/utils/app_date_time.dart';
import 'package:callx_ai/core/utils/app_status_helper.dart';
import 'package:callx_ai/core/widgets/app_status_badge.dart';
import 'package:toastification/toastification.dart';

class CustomerDetailUserSummary extends StatelessWidget {
  final User user;
  final ValueNotifier<bool> isActiveNotifier;

  const CustomerDetailUserSummary({
    super.key,
    required this.user,
    required this.isActiveNotifier,
  });

  Color _getTagColor(BuildContext context, String text) {
    final state = context.read<WorkspaceSettingsCubit>().state;
    final lower = text.toLowerCase().trim();

    for (final tag in state.customTags) {
      if (tag.label.toLowerCase().trim() == lower) return tag.color;
    }

    return AppStatusHelper.getStatusColor(text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = AppStrings.current;

    return Container(
      height: MediaQuery.sizeOf(context).height,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
      ),
      child: Column(
        spacing: 10,
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor:
                context.colors.primaryLightColor.withValues(alpha: 0.12),
            child: Text(
              user.fullName.isNotEmpty
                  ? user.fullName.characters.first.toUpperCase()
                  : 'C',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: context.colors.primaryLightColor,
              ),
            ),
          ),
          Text(
            user.fullName.isNotEmpty ? user.fullName : 'Customer Name',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          // Company Name & Job Title
          if (user.companyName.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.building_2_fill,
                    size: 12, color: context.colors.primaryLightColor),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    user.companyName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.colors.primaryLightColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          Text(
            user.jobTitle.isEmpty ? text.noJobTitle : user.jobTitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: context.colors.darkGreyColor,
            ),
            textAlign: TextAlign.center,
          ),

          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: user.phone));
              AppUtils.showSnackBar(
                  context: context,
                  toastificationType: ToastificationType.info,
                  title: 'Copied ${user.phone} to clipboard');
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.phone_fill,
                      size: 12, color: context.colors.darkGreyColor),
                  const SizedBox(width: 6),
                  Text(
                    user.phone.isNotEmpty ? user.phone : 'No Phone',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.darkGreyColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 20),

          // Summary Key-Value Details
          _buildInfoRow(context,
              label: 'Company Type', value: user.companyType),
          _buildInfoRow(context,
              label: 'Lead Status',
              value: user.leadStatus,
              isBadge: true),
          _buildInfoRow(context,
              label: 'Lead Priority',
              value: user.leadPriority,
              isBadge: true),
          _buildInfoRow(context,
              label: 'Lead Quality',
              value: user.leadQuality,
              isBadge: true),
          if (user.nextFollowUpDate != null)
            _buildInfoRow(
              context,
              label: 'Next Follow-up',
              value: AppDateTime.displayDateOrDateTime(user.nextFollowUpDate),
              isHighlight: true,
            ),
          _buildInfoRow(context,
              label: 'Last Contact Result',
              value: user.lastContactResult,
              isBadge: true),
          _buildInfoRow(context,
              label: text.createdAt,
              value: AppDateTime.displayDateTime(user.createdAt)),
          _buildInfoRow(context,
              label: text.lastContact,
              value: AppDateTime.displayDateTime(user.lastContact)),

          const Divider(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A).withValues(alpha: 120)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
              border: Border.all(
                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(CupertinoIcons.tag_solid,
                            size: 14, color: context.colors.primaryLightColor),
                        const SizedBox(width: 6),
                        Text(
                          'TAGS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: context.colors.darkGreyColor,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () async {
                        final tagModel = await AddTagDialog.show(
                          context,
                          existingTags: user.tags,
                        );
                        if (tagModel != null && context.mounted) {
                          final numericId = int.tryParse(tagModel.id);
                          if (numericId != null && numericId > 0) {
                            context.read<CustomersCubit>().addTag(
                                  user.id,
                                  tagId: numericId,
                                );
                          } else {
                            context.read<CustomersCubit>().addTag(
                                  user.id,
                                  label: tagModel.label,
                                  color: tagModel.colorHex,
                                );
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        child: Row(
                          children: [
                            Icon(Icons.add,
                                size: 13,
                                color: context.colors.primaryLightColor),
                            const SizedBox(width: 4),
                            Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: context.colors.primaryLightColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                user.tags.isEmpty
                    ? Text(
                        'No tags added. Click Add to create one.',
                        style: TextStyle(
                            fontSize: 11,
                            color: context.colors.darkGreyColor
                                .withValues(alpha: 180)),
                      )
                    : Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: user.tags.map((tag) {
                          final color = _getTagColor(context, tag);
                          return Container(
                            height: 24,
                            padding: const EdgeInsets.only(left: 10, right: 6),
                            decoration: BoxDecoration(
                              color:
                                  color.withValues(alpha: isDark ? 0.15 : 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: color.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  tag.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () {
                                    final settingsState = context
                                        .read<WorkspaceSettingsCubit>()
                                        .state;
                                    final matchingTag = settingsState.customTags
                                        .cast<TagModel?>()
                                        .firstWhere(
                                          (t) =>
                                              t?.label.toLowerCase() ==
                                              tag.toLowerCase(),
                                          orElse: () => null,
                                        );
                                    final numericId = matchingTag != null
                                        ? int.tryParse(matchingTag.id)
                                        : null;
                                    if (numericId != null && numericId > 0) {
                                      context
                                          .read<CustomersCubit>()
                                          .removeTag(user.id, tagId: numericId);
                                    } else {
                                      context
                                          .read<CustomersCubit>()
                                          .removeTag(user.id, label: tag);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Icon(CupertinoIcons.clear_thick,
                                      size: 12, color: color),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),
          Spacer(),
          SizedBox(
            height: 42,
            width: MediaQuery.sizeOf(context).width,
            child: ElevatedButton.icon(
              onPressed: () {
                CallActionDialog.show(
                  context,
                  fullName: user.fullName,
                  phone: user.phone,
                  customerId: user.id,
                  initialTab: 'callNow',
                );
              },
              icon: const Icon(CupertinoIcons.phone_fill,
                  size: 15, color: Colors.white),
              label: Text(
                text.callActionCall,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primaryLightColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(ThemeConstants.buttonRadius),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 42,
            width: MediaQuery.sizeOf(context).width,
            child: OutlinedButton.icon(
              onPressed: () {
                CallActionDialog.show(
                  context,
                  fullName: user.fullName,
                  phone: user.phone,
                  customerId: user.id,
                  initialTab: 'schedule',
                );
              },
              icon: Icon(CupertinoIcons.calendar,
                  size: 14, color: context.colors.primaryLightColor),
              label: Text(
                'SCHEDULE',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: context.colors.primaryLightColor),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: context.colors.primaryLightColor, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(ThemeConstants.buttonRadius),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          ValueListenableBuilder<bool>(
            valueListenable: isActiveNotifier,
            builder: (context, value, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'STATUS: ${value ? text.active.toUpperCase() : text.inactive.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: value
                          ? context.colors.successColor
                          : context.colors.errorColor,
                    ),
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      value: value,
                      activeTrackColor: context.colors.successColor,
                      onChanged: (newValue) {
                        isActiveNotifier.value = newValue;
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isHighlight = false,
    bool isPriority = false,
    bool isLeadStatus = false,
    bool isBadge = false,
  }) {
    final cleanVal = value.trim();
    final isInvalid = cleanVal.isEmpty ||
        cleanVal.toUpperCase() == 'N/A' ||
        cleanVal.toLowerCase() == 'unknown' ||
        cleanVal == '-';

    final shouldShowBadge =
        (isBadge || isPriority || isLeadStatus) && !isInvalid;

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label :",
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: context.colors.darkGreyColor,
            ),
          ),
          if (shouldShowBadge)
            AppStatusBadge(
              status: cleanVal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            )
          else
            Text(
              cleanVal.isEmpty ? "N/A" : cleanVal,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                color: isHighlight
                    ? context.colors.primaryLightColor
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
        ],
      ),
    );
  }
}
