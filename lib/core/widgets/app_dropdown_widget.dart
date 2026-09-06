import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';

class AppDropdownWidget<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final void Function(T?)? onChanged;
  final String Function(T)? itemBuilder;
  final Widget Function(T)? customItemBuilder;
  final String hint;
  final bool isExpanded;
  final double height;
  final Color? backgroundColor;
  final Color? borderColor;

  const AppDropdownWidget({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.itemBuilder,
    this.customItemBuilder,
    this.hint = 'Select',
    this.isExpanded = true,
    this.height = 44,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DropdownButtonHideUnderline(
      child: DropdownButton2<T>(
        isExpanded: isExpanded,
        hint: Text(
          hint,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: context.colors.darkGreyColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        items: items
            .map((T item) => DropdownMenuItem<T>(
                  value: item,
                  child: customItemBuilder != null
                      ? customItemBuilder!(item)
                      : Text(
                          itemBuilder != null
                              ? itemBuilder!(item)
                              : item.toString(),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                ))
            .toList(),
        value: (value != null && items.contains(value)) ? value : null,

        onChanged: onChanged,
        buttonStyleData: ButtonStyleData(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
            border: Border.all(
              color: borderColor ??
                  (isDark ? Colors.white12 : context.colors.lightGreyColor),
            ),
            color: backgroundColor ??
                (isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.black.withValues(alpha: 0.02)),
          ),
        ),
        iconStyleData: IconStyleData(
          icon: Icon(
            CupertinoIcons.chevron_down,
            color: context.colors.darkGreyColor,
            size: 14,
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 260,
          elevation: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
            color: isDark ? AppColors.darkSlateColor : Colors.white,
            border: Border.all(
              color: isDark ? Colors.white12 : context.colors.lightGreyColor,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          offset: const Offset(0, -4),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: WidgetStateProperty.all(4),
            thumbVisibility: WidgetStateProperty.all(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 42,
          padding: EdgeInsets.symmetric(horizontal: 14),
        ),
      ),
    );
  }
}
