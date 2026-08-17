import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/widgets/app_dropdown_widget.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InboundReceptionTab extends StatefulWidget {
  final VoidCallback onDataChanged;

  const InboundReceptionTab({super.key, required this.onDataChanged});

  @override
  State<InboundReceptionTab> createState() => _InboundReceptionTabState();
}

class _InboundReceptionTabState extends State<InboundReceptionTab> {
  String _operatingHours = '24/7 Virtual Receptionist';
  final List<String> _operatingOptions = const [
    '24/7 Virtual Receptionist',
    'Business Hours Only (9 AM - 6 PM)',
    'After-Hours & Weekend Answering',
  ];

  late TextEditingController _welcomeGreetingCtrl;
  late TextEditingController _faqInfoCtrl;
  late TextEditingController _transferPhoneCtrl;

  @override
  void initState() {
    super.initState();
    _welcomeGreetingCtrl = TextEditingController(
      text:
          'Thank you for calling CallX AI. My name is Sarah, your virtual assistant. How may I help you today?',
    );
    _faqInfoCtrl = TextEditingController(
      text:
          'CallX AI provides automated voice cold calling for businesses. Plans start at \$499/month. Our support team is available Mon-Fri 9am-6pm PST.',
    );
    _transferPhoneCtrl = TextEditingController(
      text: '+1 (800) 555-0199',
    );
  }

  @override
  void dispose() {
    _welcomeGreetingCtrl.dispose();
    _faqInfoCtrl.dispose();
    _transferPhoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. INBOUND SCHEDULE
          Text(
            'INBOUND ANSWERING SCHEDULE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          AppDropdownWidget<String>(
            value: _operatingHours,
            items: _operatingOptions,
            height: 46,
            itemBuilder: (item) => item,
            onChanged: (val) {
              if (val != null) {
                setState(() => _operatingHours = val);
                widget.onDataChanged();
              }
            },
          ),
          const SizedBox(height: 30),

          // 2. WELCOME GREETING
          Text(
            'INBOUND WELCOME MESSAGE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _welcomeGreetingCtrl,
            maxLines: 2,
            style: const TextStyle(fontSize: 13, height: 1.4),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Spoken immediately when a customer calls...',
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
                borderSide: BorderSide(
                    color: isDark
                        ? Colors.white12
                        : context.colors.lightGreyColor),
              ),
            ),
            onChanged: (_) => widget.onDataChanged(),
          ),
          const SizedBox(height: 30),

          // 3. COMPANY FAQS & KNOWLEDGE
          Text(
            'COMPANY INFORMATION & FAQS (FOR AI TO ANSWER)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _faqInfoCtrl,
            maxLines: 4,
            style: const TextStyle(fontSize: 13, height: 1.4),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Enter company pricing, services, and frequently asked questions...',
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
                borderSide: BorderSide(
                    color: isDark
                        ? Colors.white12
                        : context.colors.lightGreyColor),
              ),
            ),
            onChanged: (_) => widget.onDataChanged(),
          ),
          const SizedBox(height: 30),

          // 4. FORWARDING PHONE
          Text(
            'HUMAN TRANSFER PHONE NUMBER',
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
              borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
              border: Border.all(
                color: isDark ? Colors.white12 : context.colors.lightGreyColor,
              ),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.black.withValues(alpha: 0.02),
            ),
            child: Center(
              child: TextField(
                controller: _transferPhoneCtrl,
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w600),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: const Icon(CupertinoIcons.phone_fill, size: 14),
                  hintText: '+1 (800) 000-0000',
                  hintStyle: TextStyle(
                      fontSize: 12.5, color: context.colors.darkGreyColor),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
                onChanged: (_) => widget.onDataChanged(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
