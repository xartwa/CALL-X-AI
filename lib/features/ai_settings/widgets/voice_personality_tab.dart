import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/widgets/app_dropdown_widget.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VoicePersonalityTab extends StatefulWidget {
  final VoidCallback onDataChanged;

  const VoicePersonalityTab({super.key, required this.onDataChanged});

  @override
  State<VoicePersonalityTab> createState() => _VoicePersonalityTabState();
}

class _VoicePersonalityTabState extends State<VoicePersonalityTab> {
  String _selectedVoiceId = 'sarah';
  String? _playingVoiceId;

  String _selectedTone = 'Professional & Confident';
  final List<String> _toneOptions = const [
    'Professional & Confident',
    'Friendly & Warm',
    'Direct & Fast-Paced',
    'Casual & Relaxed',
  ];

  String _speakingSpeed = 'Normal (1.0x)';
  final List<String> _speedOptions = const [
    'Slow (0.9x)',
    'Normal (1.0x)',
    'Fast (1.1x)',
  ];

  final List<Map<String, String>> _voices = const [
    {
      'id': 'sarah',
      'name': 'Sarah',
      'gender': 'Female',
      'accent': 'US English',
      'bestFor': 'Best for Cold Calling & Appointment Setting',
    },
    {
      'id': 'david',
      'name': 'David',
      'gender': 'Male',
      'accent': 'UK English',
      'bestFor': 'Best for High-Ticket B2B & Contract Closings',
    },
    {
      'id': 'emma',
      'name': 'Emma',
      'gender': 'Female',
      'accent': 'US English',
      'bestFor': 'Best for Customer Care & Follow-Up Inquiries',
    },
    {
      'id': 'michael',
      'name': 'Michael',
      'gender': 'Male',
      'accent': 'US English',
      'bestFor': 'Best for Tech Advisory & Software Consultation',
    },
  ];

  void _togglePlay(String id) {
    setState(() {
      if (_playingVoiceId == id) {
        _playingVoiceId = null;
      } else {
        _playingVoiceId = id;
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _playingVoiceId == id) {
            setState(() => _playingVoiceId = null);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. VOICE SELECTION
          Text(
            'CHOOSE AI AGENT VOICE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),

          // 4 Simple Voice Cards
          Column(
            children: _voices.map((v) {
              final isSelected = _selectedVoiceId == v['id'];
              final isPlaying = _playingVoiceId == v['id'];

              return InkWell(
                onTap: () {
                  setState(() => _selectedVoiceId = v['id']!);
                  widget.onDataChanged();
                },
                borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: isDark ? 0.12 : 0.06)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.02)
                            : Colors.grey[50]),
                    borderRadius:
                        BorderRadius.circular(ThemeConstants.boxRadius),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : (isDark
                              ? Colors.white10
                              : context.colors.lightGreyColor),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? CupertinoIcons.check_mark_circled_solid
                            : CupertinoIcons.circle,
                        size: 20,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : context.colors.darkGreyColor,
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          v['gender'] == 'Female'
                              ? CupertinoIcons
                                  .person_crop_circle_fill_badge_checkmark
                              : CupertinoIcons.person_crop_circle_fill,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  v['name']!,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${v['gender']} • ${v['accent']})',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: context.colors.darkGreyColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              v['bestFor']!,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 36,
                        child: OutlinedButton.icon(
                          onPressed: () => _togglePlay(v['id']!),
                          icon: Icon(
                            isPlaying
                                ? CupertinoIcons.stop_fill
                                : CupertinoIcons.play_arrow_solid,
                            size: 13,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          label: Text(
                            isPlaying ? 'PLAYING...' : 'LISTEN SAMPLE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.4),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // 2. TONE & SPEED SETTINGS
          Row(
            children: [
              // Conversational Tone
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONVERSATIONAL TONE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppDropdownWidget<String>(
                      value: _selectedTone,
                      items: _toneOptions,
                      height: 46,
                      itemBuilder: (item) => item,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedTone = val);
                          widget.onDataChanged();
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Speaking Speed
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SPEAKING SPEED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppDropdownWidget<String>(
                      value: _speakingSpeed,
                      items: _speedOptions,
                      height: 46,
                      itemBuilder: (item) => item,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _speakingSpeed = val);
                          widget.onDataChanged();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
