import 'dart:math';

String? validateString(String string, {bool enableEmpty = false}) {
  if (string.isEmpty && !enableEmpty) return "هذا الحقل مطلوب";
  if (string.isNotEmpty && string.length < 3)
    return "فضلاً أضف معلومات أكثر";
  return null;
}

String? validateEmail(String email) {
  RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  if (email.isEmpty) return "البريد الإلكتروني مطلوب";
  if (email.length < 5 || email.length > 254) return "صيغة البريد الإلكتروني غير صحيحة";
  if (!emailRegex.hasMatch(email)) return "صيغة البريد الإلكتروني غير صحيحة";
  return null;
}

String? validatePassword(String password) {
  // Firebase will handle password strength
  if (password.isEmpty) return "كلمة المرور مطلوبة";
  return null;
}

String? validateRepeatPassword(String password, String repeatPassword) {
  if (password != repeatPassword) return "كلمتا المرور غير متطابقتين";
  return null;
}

String? validateName(String name) {
  RegExp namePattern = RegExp(r'^[A-Za-z]+$');

  if (name.isEmpty) return "الاسم مطلوب";
  if (name.length < 2 || name.length > 50) {
    return "الاسم يجب أن يكون بين 2 و50 حرفاً";
  }
  if (!namePattern.hasMatch(name)) return "الاسم يجب أن يحتوي حروفاً فقط";
  return null;
}

String? validateSurname(String surname) {
  RegExp surnamePattern = RegExp(r'^[A-Za-z]+$');

  if (surname.isEmpty) return "اسم العائلة مطلوب";
  if (surname.length < 2 || surname.length > 50) {
    return "اسم العائلة يجب أن يكون بين 2 و50 حرفاً";
  }
  if (!surnamePattern.hasMatch(surname)) {
    return "اسم العائلة يجب أن يحتوي حروفاً فقط";
  }
  return null;
}

// TODO use package to validate phone number
String? validatePhoneNumber(String phone) {
  RegExp phoneRegex = RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');

  if (phone.isEmpty) return "رقم الجوال مطلوب";
  if (phone.length < 7 || phone.length > 15) {
    return "رقم الجوال بين 7 و15 خانة";
  }
  if (!phoneRegex.hasMatch(phone)) return "صيغة رقم الجوال غير صحيحة";
  return null;
}

void putErrorIfExists(Map<String, String> map, String key, String? value) {
  if (value != null) map[key] = value;
}

String? validateCardsPerSession(int cardsPerSession) {
  if (cardsPerSession < 5 || cardsPerSession > 100) {
    return "أدخل رقماً بين 5 و100";
  }
  return null;
}

String? validateNumber(String number, int minValue, int maxValue) {
  final numberParsed = int.tryParse(number);
  if (numberParsed == null) return "أدخل رقماً";

  if (numberParsed < minValue || numberParsed > maxValue) {
    return "القيمة يجب أن تكون بين $minValue و$maxValue";
  }

  return null;
}

String? validateClampedNumber(
  String number,
  int minValue,
  int maxValue,
  int clampValue,
) {
  final numberParsed = int.tryParse(number);
  if (numberParsed == null) return "أدخل رقماً";

  final effectiveMax = maxValue.clamp(minValue, clampValue);

  if (numberParsed < minValue || numberParsed > effectiveMax) {
    return "القيمة يجب أن تكون بين $minValue و$effectiveMax";
  }

  return null;
}
