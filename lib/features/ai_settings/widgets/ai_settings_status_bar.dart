import 'package:callx_ai/features/ai_settings/cubit/ai_settings_cubit.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class AiSettingsStatusBar extends StatelessWidget {
  const AiSettingsStatusBar({
    super.key,
    required this.state,
    required this.onRefresh,
  });

  final AiSettingsState state;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = state.agentDraft;
    final activeScenariosCount =
        state.scenarios.where((item) => item.isActive).length;

    final isInboundActive = profile?.isAiEnabled == true;
    final inboundLabel = isInboundActive
        ? (profile?.is247 == true ? '24/7 Online' : 'Active')
        : 'Paused';

    final knowledgeLabel = profile?.knowledgePdfName != null &&
            profile!.knowledgePdfName!.isNotEmpty
        ? 'PDF Document'
        : (profile?.knowledgeText.isNotEmpty == true ? 'Custom Text' : 'Default');

    final voiceName = state.selectedVoice?.name ?? 'Skylar';

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkSlateColor : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          // 1. VOICE
          _PillItem(
            dotColor: const Color(0xFF10B981),
            label: 'VOICE',
            value: voiceName,
          ),
          _divider(isDark),

          // 2. SCENARIOS
          _PillItem(
            dotColor: const Color(0xFF8B5CF6),
            label: 'SCENARIOS',
            value: '$activeScenariosCount active',
          ),
          _divider(isDark),

          // 3. INBOUND
          _PillItem(
            dotColor: isInboundActive
                ? const Color(0xFF10B981)
                : const Color(0xFFF59E0B),
            label: 'INBOUND',
            value: inboundLabel,
          ),
          _divider(isDark),

          // 4. KNOWLEDGE
          _PillItem(
            dotColor: const Color(0xFF6366F1),
            label: 'KNOWLEDGE',
            value: knowledgeLabel,
          ),

          const Spacer(),

          // 5. VOICE ENGINE ONLINE BADGE
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'VOICE ENGINE ONLINE',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'sonic-3.5 · managed-agents',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onRefresh,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                CupertinoIcons.arrow_clockwise,
                size: 14,
                color: context.colors.darkGreyColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) => Container(
        height: 16,
        width: 1,
        margin: const EdgeInsets.symmetric(horizontal: 14),
        color: isDark ? AppColors.darkSlateColor : const Color(0xFFE2E8F0),
      );
}

class _PillItem extends StatelessWidget {
  const _PillItem({
    required this.dotColor,
    required this.label,
    required this.value,
  });

  final Color dotColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}
