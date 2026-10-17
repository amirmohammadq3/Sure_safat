import 'ayah_model.dart';

/// بودجه‌ی تقریبی هر ورق بر اساس مجموع طول متن عربی و فارسی (به کاراکتر).
/// هر ورق دقیقاً با پایان یک آیه تمام می‌شود، هیچ‌وقت وسط یک آیه بریده نمی‌شود.
const int kPageCharBudget = 1600;

List<List<Ayah>> buildPages(List<Ayah> ayahs) {
  final pages = <List<Ayah>>[];
  var current = <Ayah>[];
  var currentWeight = 0;

  for (final a in ayahs) {
    final weight = a.arabic.length + a.persian.length;
    if (current.isNotEmpty && currentWeight + weight > kPageCharBudget) {
      pages.add(current);
      current = [];
      currentWeight = 0;
    }
    current.add(a);
    currentWeight += weight;
  }
  if (current.isNotEmpty) pages.add(current);
  return pages;
}
