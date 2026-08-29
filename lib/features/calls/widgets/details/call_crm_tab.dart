import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/routes/app_routes_path.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/core/widgets/custom_tag_widget.dart';
import 'package:callx_ai/features/calls/models/call_history_model.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/theme/app_colors.dart';

class CallCrmTab extends StatelessWidget {
  final CallHistoryModel call;

  const CallCrmTab({
    super.key,
    required this.call,
  });

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    AppUtils.showSnackBar(
      context: context,
      extraMessage: '$label copied: $text',
      toastificationType: ToastificationType.success,
    );
  }

  void _navigateToCustomerProfile(BuildContext context) {
    final customers = context.read<CustomersCubit>().state.users;
    final customer = customers.firstWhere(
      (u) => u.phone == call.phone || u.fullName == call.fullName,
      orElse: () => customers.isNotEmpty
          ? customers.first
          : User(
              id: 1,
              fullName: call.fullName,
              email: call.email ?? '',
              phone: call.phone,
              createdAt: '',
              lastContact: '',
              status: 'Active',
            ),
    );
    context.goNamed(
      AppRoutesPath.customerDetailName,
      pathParameters: {'id': customer.id.toString()},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Primary Contact Information Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
              border: Border.all(
                color: isDark ? Colors.white10 : context.colors.mediumGreyColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.person_crop_circle_fill,
                      size: 16,
                      color: context.colors.primaryLightColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CONTACT DETAILS',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Phone
                _buildInfoRow(
                  context,
                  icon: CupertinoIcons.phone,
                  label: 'Phone Number',
                  value: call.phone,
                  onCopy: () => _copyToClipboard(context, call.phone, 'Phone'),
                ),
                const SizedBox(height: 10),

                // Email
                if (call.email != null && call.email!.isNotEmpty) ...[
                  _buildInfoRow(
                    context,
                    icon: CupertinoIcons.mail,
                    label: 'Email Address',
                    value: call.email!,
                    onCopy: () => _copyToClipboard(context, call.email!, 'Email'),
                  ),
                  const SizedBox(height: 10),
                ],

                // Company
                if (call.companyName.isNotEmpty) ...[
                  _buildInfoRow(
                    context,
                    icon: CupertinoIcons.building_2_fill,
                    label: 'Company Name',
                    value: call.companyName,
                  ),
                  const SizedBox(height: 10),
                ],

                // Date & Time
                _buildInfoRow(
                  context,
                  icon: CupertinoIcons.calendar,
                  label: 'Session Time',
                  value: '${call.callDate}  •  ${call.callTime}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Lead Status, Priority & Tags Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
              border: Border.all(
                color: isDark ? Colors.white10 : context.colors.mediumGreyColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.tag_fill,
                      size: 16,
                      color: context.colors.primaryLightColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'LEAD CLASSIFICATION',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Lead Priority & Status
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lead Priority',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: context.colors.darkGreyColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          CustomTagWidget(
                            label: call.leadPriority ?? 'Warm',
                            color: (call.leadPriority?.toLowerCase() == 'hot')
                                ? context.colors.errorColor
                                : ((call.leadPriority?.toLowerCase() == 'warm')
                                    ? context.colors.warningColor
                                    : context.colors.primaryLightColor),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assigned Agent',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: context.colors.darkGreyColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            call.assignee,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Tags Wrap
                if (call.tags.isNotEmpty) ...[
                  Text(
                    'Assigned Tags',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: context.colors.darkGreyColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: call.tags.map((tag) {
                      return Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color:
                              context.colors.primaryLightColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: context.colors.primaryLightColor
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: context.colors.primaryLightColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Open in Full CRM Profile Action Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () => _navigateToCustomerProfile(context),
              icon: Icon(
                CupertinoIcons.arrow_up_right_square,
                size: 16,
                color: context.colors.primaryLightColor,
              ),
              label: Text(
                'OPEN FULL CRM PROFILE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: context.colors.primaryLightColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: context.colors.primaryLightColor.withValues(alpha: 0.5),
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
                ),
                backgroundColor:
                    context.colors.primaryLightColor.withValues(alpha: 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 14, color: context.colors.darkGreyColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: context.colors.darkGreyColor,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
        if (onCopy != null) ...[
          const SizedBox(width: 6),
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Icon(
                CupertinoIcons.doc_on_doc,
                size: 12,
                color: context.colors.primaryLightColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
