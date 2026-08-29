import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/routes/app_routes_path.dart';
import 'package:callx_ai/features/calls/models/call_history_model.dart';
import 'package:callx_ai/features/calls/widgets/call_action_dialog.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/theme/app_colors.dart';

class CallDetailsFooter extends StatelessWidget {
  final CallHistoryModel call;
  final VoidCallback onCallAdded;

  const CallDetailsFooter({
    super.key,
    required this.call,
    required this.onCallAdded,
  });

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(ThemeConstants.boxRadius),
        ),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : context.colors.mediumGreyColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 1. Call Now / Re-dial Primary Button
          Expanded(
            flex: 6,
            child: SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await CallActionDialog.show(
                    context,
                    fullName: call.fullName,
                    phone: call.phone,
                    initialTab: 'callNow',
                  );
                  onCallAdded();
                },
                icon: const Icon(
                  CupertinoIcons.phone_fill,
                  size: 14,
                  color: Colors.white,
                ),
                label: const Text(
                  'RE-DIAL',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
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
          ),
          const SizedBox(width: 8),

          // 2. Schedule Callback Button
          Expanded(
            flex: 6,
            child: SizedBox(
              height: 40,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await CallActionDialog.show(
                    context,
                    fullName: call.fullName,
                    phone: call.phone,
                    initialTab: 'schedule',
                  );
                  onCallAdded();
                },
                icon: Icon(
                  CupertinoIcons.calendar,
                  size: 14,
                  color: context.colors.primaryLightColor,
                ),
                label: Text(
                  'SCHEDULE',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: context.colors.primaryLightColor,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: context.colors.primaryLightColor.withValues(alpha: 0.7),
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ThemeConstants.buttonRadius),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 3. View Profile Icon/Button
          SizedBox(
            height: 40,
            width: 40,
            child: OutlinedButton(
              onPressed: () => _navigateToCustomerProfile(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: BorderSide(
                  color: isDark ? Colors.white24 : context.colors.mediumGreyColor,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(ThemeConstants.buttonRadius),
                ),
              ),
              child: Icon(
                CupertinoIcons.person_crop_circle,
                size: 18,
                color: context.colors.primaryLightColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
