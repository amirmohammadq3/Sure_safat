/// ساخت نشانه‌ی پایان آیه (۝) به همراه عدد آیه در داخل آن،
/// دقیقاً طبق مستندات فونت‌های عثمانی/قرآنی:
/// توالی U+06DD + ارقام عربی-هندی (٠-٩)، بدون هیچ فاصله‌ای،
/// و برای نمایش پایدارتر در موتورهای مختلف، با نشانگرهای جهت‌دهی
/// LRO (U+202D) ... PDF (U+202C) احاطه شده است.
String ayahEndMark(int number) {
  const arabicIndicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  final digits = number.toString().split('').map((d) => arabicIndicDigits[int.parse(d)]).join();
  const endOfAyah = '\u06DD';
  const lro = '\u202D';
  const pdf = '\u202C';
  return '$lro$endOfAyah$digits$pdf';
}
