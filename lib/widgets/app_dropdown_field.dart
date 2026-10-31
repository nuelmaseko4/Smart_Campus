import 'package:flutter/material.dart';
import 'package:uni_connect/widgets/app_text_field.dart';

class AppDropdownField extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.options,
    required this.onSelected,
    required this.validator,
    this.selectedValue,
    this.icon = Icons.arrow_drop_down,
    this.isLoading = false,
  });

  final String label;
  final List<String> options;
  final ValueChanged<String?> onSelected;
  final FormFieldValidator<String> validator;
  final String? selectedValue;
  final IconData icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final decoration = appFieldDecoration(
      context,
      label: label,
      prefixIcon: icon,
    );

    if (isLoading) {
      return InputDecorator(
        decoration: decoration,
        child: const LinearProgressIndicator(),
      );
    }

    return DropdownMenuFormField<String>(
      initialSelection: selectedValue,
      dropdownMenuEntries: options
          .map((option) => DropdownMenuEntry(value: option, label: option))
          .toList(),
      enableFilter: true,
      enableSearch: true,
      expandedInsets: EdgeInsets.zero,
      menuHeight: 300,
      decorationBuilder: (context, menuController) => decoration,
      onSelected: onSelected,
      validator: validator,
    );
  }
}
