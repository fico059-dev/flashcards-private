/// قسما اختبار القدرات: اللفظي والكمي.
enum PackSection {
  verbal('verbal', 'لفظي'),
  quant('quant', 'كمي');

  const PackSection(this.id, this.arabicName);

  /// القيمة المخزّنة في حقل `section` بمستند الحزمة في Firestore.
  final String id;
  final String arabicName;

  static PackSection fromId(String? id) => PackSection.values.firstWhere(
    (s) => s.id == id,
    orElse: () => PackSection.verbal,
  );

  /// كل قسم له نطاق خاص من أرقام الصفحات داخل كاش الحزم المشترك.
  int get cachePageOffset => index * 1000;
}
