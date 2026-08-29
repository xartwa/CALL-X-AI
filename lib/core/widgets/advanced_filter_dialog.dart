import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/widgets/app_dropdown_widget.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdvancedFilterState {
  final String country;
  final String province;
  final String city;
  final String priority;

  const AdvancedFilterState({
    this.country = 'All Countries',
    this.province = 'All Provinces',
    this.city = 'All Cities',
    this.priority = 'All',
  });

  bool get isActive =>
      country != 'All Countries' ||
      province != 'All Provinces' ||
      city != 'All Cities' ||
      (priority != 'All' && priority != 'All Priorities');

  int get activeCount {
    int count = 0;
    if (country != 'All Countries') count++;
    if (province != 'All Provinces') count++;
    if (city != 'All Cities') count++;
    if (priority != 'All' && priority != 'All Priorities') count++;
    return count;
  }
}

class AdvancedFilterDialog extends StatefulWidget {
  final AdvancedFilterState? initialState;
  final List<String>? countries;
  final List<String>? provinces;
  final List<String>? cities;
  final List<String>? priorities;

  const AdvancedFilterDialog(
      {super.key,
      this.initialState,
      this.countries,
      this.provinces,
      this.cities,
      this.priorities});

  static Future<AdvancedFilterState?> show(
    BuildContext context, {
    AdvancedFilterState? initialState,
    List<String>? countries,
    List<String>? provinces,
    List<String>? cities,
    List<String>? priorities,
  }) {
    return showDialog<AdvancedFilterState>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AdvancedFilterDialog(
          initialState: initialState,
          countries: countries,
          provinces: provinces,
          cities: cities,
          priorities: priorities),
    );
  }

  @override
  State<AdvancedFilterDialog> createState() => _AdvancedFilterDialogState();
}

class _AdvancedFilterDialogState extends State<AdvancedFilterDialog> {
  static const String _allCountries = 'All Countries';
  static const String _allProvinces = 'All Provinces';
  static const String _allCities = 'All Cities';
  static const String _allPriorities = 'All';

  late String _selectedCountry;
  late String _selectedProvince;
  late String _selectedCity;
  late String _selectedPriority;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialState ?? const AdvancedFilterState();
    _selectedCountry = initial.country;
    _selectedProvince = initial.province;
    _selectedCity = initial.city;
    _selectedPriority = initial.priority == 'All Priorities' ? 'All' : initial.priority;
  }

  final List<String> _countries = const [
    'All Countries',
    'Canada',
    'United States',
    'United Kingdom',
    'Australia',
    'Germany'
  ];

  final List<String> _provinces = const [
    'All Provinces',
    'Ontario',
    'Alberta',
    'British Columbia',
    'California',
    'Texas',
    'New York'
  ];

  final List<String> _cities = const [
    'All Cities',
    'Toronto',
    'Calgary',
    'Vancouver',
    'Los Angeles',
    'Austin',
    'New York City'
  ];

  final List<String> _priorities = const [
    'All',
    'Hot',
    'Warm',
    'Cold',
  ];

  void _resetFilters() {
    setState(() {
      _selectedCountry = _allCountries;
      _selectedProvince = _allProvinces;
      _selectedCity = _allCities;
      _selectedPriority = _allPriorities;
    });
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        AppDropdownWidget<String>(
          value: items.contains(value) ? value : items.first,
          items: items,
          itemBuilder: (item) => item,
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
      ),
      child: Container(
        width: 480,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Pure Text Title & Close Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ADVANCED FILTERS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(CupertinoIcons.clear, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Location Filters Section
            Text(
              'LOCATION',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    label: 'Country',
                    value: _selectedCountry,
                    items: widget.countries ?? _countries,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCountry = val);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField(
                    label: 'Province / State',
                    value: _selectedProvince,
                    items: widget.provinces ?? _provinces,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedProvince = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    label: 'City',
                    value: _selectedCity,
                    items: widget.cities ?? _cities,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCity = val);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField(
                    label: 'Lead Priority',
                    value: _selectedPriority,
                    items: widget.priorities ?? _priorities,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedPriority = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Footer Action Bar: Reset + Apply
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(CupertinoIcons.arrow_counterclockwise,
                          size: 14),
                      label: const Text(
                        'RESET',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            isDark ? Colors.white70 : Colors.black87,
                        side: BorderSide(
                          color: isDark
                              ? Colors.white24
                              : context.colors.lightGreyColor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              ThemeConstants.buttonRadius),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          AdvancedFilterState(
                            country: _selectedCountry,
                            province: _selectedProvince,
                            city: _selectedCity,
                            priority: _selectedPriority,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              ThemeConstants.buttonRadius),
                        ),
                      ),
                      child: const Text(
                        'APPLY FILTERS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
