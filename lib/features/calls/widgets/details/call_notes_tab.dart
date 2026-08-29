import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/features/calls/models/call_history_model.dart';
import 'package:callx_ai/theme/app_colors.dart';

class CallNotesTab extends StatefulWidget {
  final CallHistoryModel call;
  final ValueChanged<CallHistoryModel>? onCallUpdated;

  const CallNotesTab({
    super.key,
    required this.call,
    this.onCallUpdated,
  });

  @override
  State<CallNotesTab> createState() => _CallNotesTabState();
}

class _CallNotesTabState extends State<CallNotesTab> {
  late final TextEditingController _notesCtrl;
  late String _selectedResult;
  String? _followUpDate;
  bool _isSaving = false;

  final List<String> _contactResults = const [
    'Interested',
    'Follow-up Required',
    'Demo Scheduled',
    'Proposal Sent',
    'Not Interested',
  ];

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController(text: widget.call.notes ?? '');
    _selectedResult = widget.call.lastContactResult ?? 'Interested';
    _followUpDate = widget.call.nextFollowUpDate;
  }

  @override
  void didUpdateWidget(CallNotesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.call.id != widget.call.id) {
      _notesCtrl.text = widget.call.notes ?? '';
      _selectedResult = widget.call.lastContactResult ?? 'Interested';
      _followUpDate = widget.call.nextFollowUpDate;
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 200));

    final updated = widget.call.copyWith(
      notes: _notesCtrl.text.trim(),
      lastContactResult: _selectedResult,
      nextFollowUpDate: _followUpDate ?? '',
    );

    widget.onCallUpdated?.call(updated);

    if (mounted) {
      setState(() => _isSaving = false);
      AppUtils.showSnackBar(
        context: context,
        extraMessage: 'Call notes & follow-up updated successfully',
        toastificationType: ToastificationType.success,
      );
    }
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      final formatted = DateFormat('yyyy/MM/dd').format(picked);
      setState(() {
        _followUpDate = formatted;
      });
    }
  }

  void _setPresetDate(int daysToAdd) {
    final target = DateTime.now().add(Duration(days: daysToAdd));
    final formatted = DateFormat('yyyy/MM/dd').format(target);
    setState(() {
      _followUpDate = formatted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Private Agent Notes Editor
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.doc_plaintext,
                          size: 16,
                          color: context.colors.primaryLightColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'INTERNAL CALL NOTES',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    if (_notesCtrl.text.isNotEmpty)
                      Text(
                        'Edited',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: context.colors.primaryLightColor,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Multi-line Text Field
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.white12 : context.colors.mediumGreyColor,
                    ),
                  ),
                  child: TextField(
                    controller: _notesCtrl,
                    maxLines: 4,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Add private agent observations, follow-up instructions, customer preferences...',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: context.colors.darkGreyColor,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Call Outcome / Contact Result Selector
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
                      CupertinoIcons.flag_fill,
                      size: 15,
                      color: context.colors.primaryLightColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CONTACT RESULT / OUTCOME',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _contactResults.map((result) {
                    final isSelected = _selectedResult == result;
                    return InkWell(
                      onTap: () => setState(() => _selectedResult = result),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.colors.primaryLightColor.withValues(alpha: 0.15)
                              : (isDark ? Colors.white10 : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? context.colors.primaryLightColor
                                : (isDark ? Colors.white12 : Colors.transparent),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              Icon(
                                CupertinoIcons.checkmark_alt,
                                size: 12,
                                color: context.colors.primaryLightColor,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              result,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight:
                                    isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? context.colors.primaryLightColor
                                    : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Next Follow-Up Date Scheduler
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.calendar_badge_plus,
                          size: 16,
                          color: context.colors.primaryLightColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'NEXT FOLLOW-UP DATE',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    if (_followUpDate != null && _followUpDate!.isNotEmpty)
                      InkWell(
                        onTap: () => setState(() => _followUpDate = null),
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: context.colors.errorColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Selected Date Bar
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.white12 : context.colors.mediumGreyColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.calendar,
                          size: 15,
                          color: context.colors.primaryLightColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          (_followUpDate != null && _followUpDate!.isNotEmpty)
                              ? _followUpDate!
                              : 'No follow-up date scheduled',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                (_followUpDate != null && _followUpDate!.isNotEmpty)
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                            color:
                                (_followUpDate != null && _followUpDate!.isNotEmpty)
                                    ? (isDark ? Colors.white : Colors.black87)
                                    : context.colors.darkGreyColor,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          CupertinoIcons.chevron_right,
                          size: 13,
                          color: context.colors.darkGreyColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Presets (Tomorrow, In 3 Days, Next Week)
                Row(
                  children: [
                    _buildPresetChip('Tomorrow', () => _setPresetDate(1)),
                    const SizedBox(width: 6),
                    _buildPresetChip('In 3 Days', () => _setPresetDate(3)),
                    const SizedBox(width: 6),
                    _buildPresetChip('Next Week', () => _setPresetDate(7)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Save All Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveChanges,
              icon: _isSaving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(CupertinoIcons.checkmark_alt,
                      size: 16, color: Colors.white),
              label: Text(
                _isSaving ? 'SAVING...' : 'SAVE NOTES & FOLLOW-UP',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primaryLightColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark ? Colors.white12 : context.colors.mediumGreyColor,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
