import 'package:flutter/services.dart';

class IdInputFormatter extends TextInputFormatter {
  IdInputFormatter({required this.onInvalidInput});

  final ValueChanged<bool> onInvalidInput;
  final FilteringTextInputFormatter _allowedCharacters =
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'));

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final filteredValue = _allowedCharacters.formatEditUpdate(
      oldValue,
      newValue,
    );
    onInvalidInput(filteredValue.text != newValue.text);
    return filteredValue;
  }
}
