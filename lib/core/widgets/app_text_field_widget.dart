import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTextFieldWidget extends StatelessWidget {
  const AppTextFieldWidget({
    super.key,
    required this.controller,
    this.labelText,
    this.textInputType,
    this.isShow = true,
    this.suffixIcon,
    this.readOnly = false,
    this.hintText,
    this.prefixIcon,
    this.fillColor,
    this.onTap,
    this.onChanged,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.showBorder = false,
    this.borderColor,
    this.validator,
    this.isObscure = false,
  });
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final Function()? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? textInputType;
  final bool? isShow;
  final bool? readOnly;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLines;
  final Color? fillColor;
  final bool? showBorder;
  final Color? borderColor;
  final bool? isObscure;

  @override
  Widget build(BuildContext context) {
    final resolvedBorderColor = borderColor ?? context.colors.lightGreyColor;
    return Visibility(
      visible: isShow ?? true,
      child: TextFormField(
        onTap: onTap ?? () {},
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.w400),
        keyboardType: textInputType,
        readOnly: readOnly ?? false,
        maxLines: maxLines,
        controller: controller,
        validator: validator ?? (value) => null,
        obscureText: isObscure ?? false,
        decoration: InputDecoration(
          
          hintText: hintText,
          hintStyle: TextStyle(
              fontSize: 13.0,
              color: context.colors.darkGreyColor,
              fontWeight: FontWeight.w400),
          prefixIcon: prefixIcon,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          labelText: labelText,
          fillColor: fillColor,
          filled: fillColor != null,
          suffixIcon: suffixIcon,
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: (showBorder ?? false) == false
                      ? Colors.transparent
                      : resolvedBorderColor),
              borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: (showBorder ?? false) == false
                      ? Colors.transparent
                      : context.colors.primaryLightColor),
              borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius)),
          errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: (showBorder ?? false) == false
                      ? Colors.transparent
                      : context.colors.errorColor),
              borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius)),
          focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: (showBorder ?? false) == false
                      ? Colors.transparent
                      : context.colors.errorColor),
              borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius)),
          errorStyle: TextStyle(
              fontSize: 12.0,
              height: 0.1, // Minimizes the padding of the error text
              color: context.colors.errorColor,
              fontWeight: FontWeight.w500),
          labelStyle: const TextStyle(
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }
}
