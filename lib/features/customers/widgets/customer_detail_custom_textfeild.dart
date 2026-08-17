import 'package:callx_ai/core/widgets/app_text_field_widget.dart';
import 'package:callx_ai/theme/app_text_theme.dart';
import 'package:flutter/material.dart';

class CustomerDetailCustomTextfeild extends StatelessWidget {
  const CustomerDetailCustomTextfeild({
    super.key,
    required this.controller,
    required this.labelText,
    this.textInputType,
    this.prefixIcon,
  });
  final TextEditingController controller;
  final String labelText;
  final TextInputType? textInputType;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Text(
              labelText.toUpperCase(),
              style: AppTextTheme.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          AppTextFieldWidget(
            controller: controller,
            showBorder: true,
            fillColor: Colors.transparent,
            textInputType: textInputType,
            prefixIcon: prefixIcon,
          ),
        ],
      ),
    );
  }
}
