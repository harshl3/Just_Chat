import 'package:meta/meta.dart';

@immutable
class Validators {
  const Validators._();

  static final RegExp _emailRegex = RegExp(
    r"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}",
    caseSensitive: false,
  );

  static bool isValidEmail(String value) {
    if (value.isEmpty) return false;
    return _emailRegex.hasMatch(value.trim());
  }
}



