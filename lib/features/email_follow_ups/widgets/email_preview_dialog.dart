import 'package:callx_ai/core/constants/app_strings.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';

class EmailPreviewDialog extends StatelessWidget {
  final Map<String, dynamic> email;

  const EmailPreviewDialog({super.key, required this.email});

  Widget _buildPreviewField(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: context.colors.darkGreyColor),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Container(
        width: 580,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.current.emailFollowUpsPreviewTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(CupertinoIcons.clear_thick),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildPreviewField(
                context,
                AppStrings.current.emailFollowUpsRecipient,
                '${email['recipientName']} (${email['recipientEmail']})'),
            const Divider(height: 24),
            _buildPreviewField(context,
                AppStrings.current.emailFollowUpsSubject, email['subject']),
            const Divider(height: 24),
            _buildPreviewField(
                context,
                AppStrings.current.emailFollowUpsTemplateUsed,
                email['templateName']),
            const Divider(height: 24),
            _buildPreviewField(
                context,
                AppStrings.current.emailFollowUpsSentDateTime,
                '${email['sentDate']}  •  ${email['sentTime']}'),
            const Divider(height: 24),
            Text(
              AppStrings.current.emailFollowUpsEmailBody,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: context.colors.darkGreyColor),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
                border: Border.all(
                    color: context.colors.mediumGreyColor.withAlpha(50)),
              ),
              child: Html(
                data: email['body'],
                style: {
                  "body": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    fontSize: FontSize(13),
                    fontFamily: 'SFProText',
                    color: isDark ? Colors.grey[300] : Colors.black87,
                  ),
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primaryLightColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(ThemeConstants.buttonRadius),
                    ),
                  ),
                  child: Text(AppStrings.current.emailFollowUpsClose,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
