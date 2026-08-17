import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/core/widgets/app_dropdown_widget.dart';
import 'package:callx_ai/features/ai_settings/models/ai_settings_model.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class OutboundCampaignsTab extends StatefulWidget {
  final VoidCallback onDataChanged;

  const OutboundCampaignsTab({super.key, required this.onDataChanged});

  @override
  State<OutboundCampaignsTab> createState() => _OutboundCampaignsTabState();
}

class _OutboundCampaignsTabState extends State<OutboundCampaignsTab> {
  final List<ScenarioModel> _scenarios = [
    ScenarioModel(
      id: 'sc_b2b',
      name: 'B2B Sales & Tech Lead Qualification',
      category: 'B2B Sales',
      openingGreeting:
          'Hey {name}, Alex here with CallX AI. I noticed {company} has been expanding sales operations, and wanted to see if you have tested voice AI agents for cold outreach yet?',
      pitchSummary:
          'We deploy realistic AI voice bots that handle cold calls, qualify leads automatically, and book meetings directly into your calendar with zero human lag.',
      qualifyingQuestions: [
        'Are you currently using any automated tool for cold calling outreach?',
        'What is your approximate monthly volume of leads or contacts?',
        'Are you the main decision maker for evaluating new sales software?',
      ],
      actionOnInterest: 'Send Follow-up Email & Tag as Hot Lead',
    ),
    ScenarioModel(
      id: 'sc_realestate',
      name: 'Real Estate Property Acquisition',
      category: 'Real Estate',
      openingGreeting:
          'Hi {name}, this is Elena with Prime Properties. I am reaching out regarding your property on {company} street. Are you considering an offer this quarter?',
      pitchSummary:
          'We provide cash offers with zero closing fees and flexible 14-day settlement options for property owners in your area.',
      qualifyingQuestions: [
        'Is the property currently occupied or vacant?',
        'What would be your ideal timeline if you received a fair market cash offer?',
      ],
      actionOnInterest: 'Book Calendar Demo & Forward Details',
    ),
    ScenarioModel(
      id: 'sc_contractor',
      name: 'Home Renovation & Estimate Follow-Up',
      category: 'Contracting',
      openingGreeting:
          'Hello {name}, David here from Apex Construction. I am following up on the project estimation inquiry you submitted on our website.',
      pitchSummary:
          'We are booking on-site consultations for kitchen and exterior remodeling with certified local contractors.',
      qualifyingQuestions: [
        'What is the estimated budget and scope for your renovation project?',
        'Would tomorrow afternoon work best for our specialist to visit?',
      ],
      actionOnInterest: 'Transfer Call Directly to Live Sales Rep',
    ),
  ];

  late ScenarioModel _selectedScenario;

  late TextEditingController _nameCtrl;
  late TextEditingController _openingLineCtrl;
  late TextEditingController _offerPitchCtrl;

  final List<String> _interestActions = const [
    'Send Follow-up Email & Tag as Hot Lead',
    'Book Calendar Demo & Forward Details',
    'Transfer Call Directly to Live Sales Rep',
  ];

  final List<String> _categories = const [
    'B2B Sales',
    'Real Estate',
    'Contracting',
    'Health & Care',
    'Consulting',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    _selectedScenario = _scenarios.first;
    _nameCtrl = TextEditingController(text: _selectedScenario.name);
    _openingLineCtrl =
        TextEditingController(text: _selectedScenario.openingGreeting);
    _offerPitchCtrl =
        TextEditingController(text: _selectedScenario.pitchSummary);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _openingLineCtrl.dispose();
    _offerPitchCtrl.dispose();
    super.dispose();
  }

  void _switchScenario(ScenarioModel scenario) {
    setState(() {
      _selectedScenario = scenario;
      _nameCtrl.text = scenario.name;
      _openingLineCtrl.text = scenario.openingGreeting;
      _offerPitchCtrl.text = scenario.pitchSummary;
    });
  }

  void _showCreateScenarioDialog() {
    final titleCtrl = TextEditingController();
    String cat = 'B2B Sales';

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeConstants.boxRadius)),
          child: Container(
            width: 460,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'CREATE NEW SCENARIO',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      splashRadius: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(CupertinoIcons.clear, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const Text('SCENARIO NAME',
                    style:
                        TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                SizedBox(
                  height: 55,
                  child: TextField(
                    controller: titleCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'e.g. Solar Energy Outreach Pitch',
                      hintStyle: TextStyle(
                          fontSize: 12.5, color: context.colors.darkGreyColor),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 20),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(ThemeConstants.buttonRadius),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text('CATEGORY',
                    style:
                        TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                AppDropdownWidget<String>(
                  value: cat,
                  items: _categories,
                  height: 46,
                  itemBuilder: (c) => c,
                  onChanged: (val) {
                    if (val != null) cat = val;
                  },
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = titleCtrl.text.trim();
                      if (name.isNotEmpty) {
                        final newSc = ScenarioModel(
                          id: 'sc_${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          category: cat,
                          openingGreeting:
                              'Hello {name}, this is calling regarding your inquiry on {company}.',
                          pitchSummary:
                              'We provide tailored solutions to solve your specific business challenges.',
                          qualifyingQuestions: [
                            'What is your primary goal or timeline for this project?'
                          ],
                          actionOnInterest:
                              'Send Follow-up Email & Tag as Hot Lead',
                        );

                        setState(() {
                          _scenarios.add(newSc);
                          _switchScenario(newSc);
                        });
                        widget.onDataChanged();

                        AppUtils.showSnackBar(
                          context: context,
                          title: 'Scenario Created',
                          extraMessage: 'Created scenario "$name"',
                          toastificationType: ToastificationType.success,
                        );
                      }
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(ctx).colorScheme.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ThemeConstants.buttonRadius),
                      ),
                    ),
                    child: const Text(
                      'CREATE SCENARIO',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteCurrentScenario() {
    if (_scenarios.length <= 1) {
      AppUtils.showSnackBar(
        context: context,
        extraMessage: 'You must maintain at least one active scenario',
        toastificationType: ToastificationType.warning,
      );
      return;
    }

    final name = _selectedScenario.name;
    setState(() {
      _scenarios.removeWhere((s) => s.id == _selectedScenario.id);
      _switchScenario(_scenarios.first);
    });
    widget.onDataChanged();

    AppUtils.showSnackBar(
      context: context,
      title: 'Scenario Deleted',
      extraMessage: 'Removed scenario "$name"',
      toastificationType: ToastificationType.info,
    );
  }

  void _addQuestionDialog() {
    final qCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeConstants.boxRadius)),
          child: Container(
            width: 440,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('ADD QUALIFYING QUESTION',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6)),
                    IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(CupertinoIcons.clear, size: 16)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('QUESTION FOR CUSTOMER',
                    style:
                        TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                TextField(
                  controller: qCtrl,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 12.5),
                  decoration: InputDecoration(
                    hintText: 'e.g. What is your ideal project start timeline?',
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            ThemeConstants.buttonRadius)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      if (qCtrl.text.trim().isNotEmpty) {
                        setState(() {
                          _selectedScenario.qualifyingQuestions
                              .add(qCtrl.text.trim());
                        });
                        widget.onDataChanged();
                      }
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(ctx).colorScheme.primary,
                      elevation: 0,
                    ),
                    child: const Text('ADD QUESTION',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. SCENARIO SELECTOR & ACTIONS BAR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACTIVE COLD CALL SCENARIO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
              Row(
                children: [
                  // Create New Scenario Button
                  SizedBox(
                    height: 34,
                    child: ElevatedButton.icon(
                      onPressed: _showCreateScenarioDialog,
                      icon: const Icon(CupertinoIcons.plus,
                          size: 13, color: Colors.white),
                      label: const Text(
                        'NEW SCENARIO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Delete Scenario Button
                  if (_scenarios.length > 1)
                    SizedBox(
                      height: 34,
                      child: OutlinedButton.icon(
                        onPressed: _deleteCurrentScenario,
                        icon: const Icon(CupertinoIcons.delete,
                            size: 13, color: Color(0xFFEF4444)),
                        label: const Text(
                          'DELETE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFFEF4444), width: 0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Dropdown to switch scenarios
          AppDropdownWidget<ScenarioModel>(
            value: _selectedScenario,
            items: _scenarios,
            height: 46,
            itemBuilder: (sc) => '${sc.name} (${sc.category})',
            onChanged: (sc) {
              if (sc != null) _switchScenario(sc);
            },
          ),
          const SizedBox(height: 30),

          // 2. SCENARIO TITLE & CATEGORY (EDITABLE)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SCENARIO TITLE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(ThemeConstants.buttonRadius),
                        border: Border.all(
                          color: isDark
                              ? Colors.white12
                              : context.colors.lightGreyColor,
                        ),
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : Colors.black.withValues(alpha: 0.02),
                      ),
                      child: Center(
                        child: TextField(
                          controller: _nameCtrl,
                          style: const TextStyle(
                              fontSize: 12.5, fontWeight: FontWeight.w600),
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            hintText:
                                'e.g. B2B Sales & Tech Lead Qualification',
                            hintStyle: TextStyle(
                                fontSize: 12.5,
                                color: context.colors.darkGreyColor),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          onChanged: (val) {
                            _selectedScenario.name = val;
                            widget.onDataChanged();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CATEGORY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppDropdownWidget<String>(
                      value: _selectedScenario.category,
                      items: _categories,
                      height: 46,
                      itemBuilder: (c) => c,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedScenario.category = val);
                          widget.onDataChanged();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // 3. OPENING GREETING LINE
          Text(
            'OPENING GREETING (FIRST SENTENCE SPOKEN UPON ANSWER)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _openingLineCtrl,
            maxLines: 2,
            style: const TextStyle(fontSize: 13, height: 1.4),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'e.g. Hello {name}, this is Alex calling from...',
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
                borderSide: BorderSide(
                    color: isDark
                        ? Colors.white12
                        : context.colors.lightGreyColor),
              ),
            ),
            onChanged: (val) {
              _selectedScenario.openingGreeting = val;
              widget.onDataChanged();
            },
          ),
          const SizedBox(height: 30),

          // 4. COMPANY OFFER & PITCH
          Text(
            'VALUE PROPOSITION & PRODUCT SUMMARY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _offerPitchCtrl,
            maxLines: 3,
            style: const TextStyle(fontSize: 13, height: 1.4),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Briefly describe what your business offers...',
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
                borderSide: BorderSide(
                    color: isDark
                        ? Colors.white12
                        : context.colors.lightGreyColor),
              ),
            ),
            onChanged: (val) {
              _selectedScenario.pitchSummary = val;
              widget.onDataChanged();
            },
          ),
          const SizedBox(height: 30),

          // 5. QUALIFYING QUESTIONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QUALIFYING QUESTIONS FOR THIS SCENARIO (${_selectedScenario.qualifyingQuestions.length})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
              InkWell(
                onTap: _addQuestionDialog,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.plus_circle_fill,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'ADD QUESTION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Column(
            children: _selectedScenario.qualifyingQuestions
                .asMap()
                .entries
                .map((entry) {
              final idx = entry.key;
              final q = entry.value;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.02)
                      : Colors.grey[50],
                  borderRadius:
                      BorderRadius.circular(ThemeConstants.buttonRadius),
                  border: Border.all(
                    color: isDark
                        ? Colors.white10
                        : context.colors.lightGreyColor,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${idx + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        q,
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.delete, size: 15,color: AppColors.errorColor,),
                      onPressed: () {
                        setState(() => _selectedScenario.qualifyingQuestions
                            .removeAt(idx));
                        widget.onDataChanged();
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),

          // 6. ACTION ON INTEREST
          Text(
            'ACTION WHEN LEAD IS INTERESTED',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          AppDropdownWidget<String>(
            value: _selectedScenario.actionOnInterest,
            items: _interestActions,
            height: 46,
            itemBuilder: (item) => item,
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedScenario.actionOnInterest = val);
                widget.onDataChanged();
              }
            },
          ),
        ],
      ),
    );
  }
}
