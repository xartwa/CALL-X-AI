import 'package:callx_ai/features/ai_settings/cubit/ai_settings_cubit.dart';
import 'package:callx_ai/features/ai_settings/widgets/settings_form_widgets.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InboundSettingsTab extends StatelessWidget {
  const InboundSettingsTab({super.key, required this.state});

  final AiSettingsState state;

  @override
  Widget build(BuildContext context) {
    final draft = state.draft!;
    final cubit = context.read<AiSettingsCubit>();
    return ListView(
      children: [
        SettingsBanner(
          icon: draft.isDefaultInbound
              ? CupertinoIcons.check_mark_circled_solid
              : CupertinoIcons.phone_arrow_down_left,
          text: draft.isDefaultInbound
              ? 'This scenario answers inbound calls. Saved changes go live on the next call.'
              : 'Select this scenario as the inbound receptionist to route new calls to it.',
          warning: !draft.isDefaultInbound,
        ),
        const SizedBox(height: 24),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Use as default inbound AI',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          ),
          subtitle: const Text(
            'Only one scenario can answer the dedicated phone number.',
          ),
          value: draft.isDefaultInbound,
          onChanged: draft.isDefaultInbound
              ? null
              : (value) => cubit.updateDraft(
                    (current) => current.copyWith(
                      isDefaultInbound: value,
                      isActive: value ? true : current.isActive,
                    ),
                  ),
        ),
        const Divider(height: 32),
        const SettingsLabel('LIVE INBOUND CONFIGURATION'),
        const SizedBox(height: 12),
        SettingsKeyValue(label: 'Scenario', value: draft.name),
        SettingsKeyValue(
          label: 'Status',
          value: draft.isActive ? 'Active' : 'Disabled',
        ),
        SettingsKeyValue(
          label: 'Voice',
          value: state.selectedVoice?.name ?? draft.voiceId,
        ),
        SettingsKeyValue(
          label: 'Speed',
          value: '${draft.voiceSpeed.toStringAsFixed(2)}x',
        ),
        SettingsKeyValue(label: 'Greeting', value: draft.openingGreeting),
        const SizedBox(height: 18),
        Text(
          'Inbound, outbound, and the Web Simulator use the same scenario contract. The runtime securely refreshes this default at call start and falls back to its deployed configuration if the control plane is temporarily unavailable.',
          style: TextStyle(
            fontSize: 12.5,
            height: 1.5,
            color: context.colors.darkGreyColor,
          ),
        ),
      ],
    );
  }
}
