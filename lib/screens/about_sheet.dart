import 'package:flutter/material.dart';
import '../common/palette.dart';

class AboutSheet extends StatelessWidget {
  final AppPalette p;
  const AboutSheet({super.key, required this.p});

  static void show(BuildContext context, AppPalette p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: p.sheetBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => AboutSheet(p: p),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 6),
        child: Text(t, style: TextStyle(color: p.gold, fontWeight: FontWeight.bold, fontSize: 16)),
      );

  Widget _para(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Text(t, style: TextStyle(color: p.textPrimary, fontSize: 13.5, height: 1.95)),
      );

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(child: Divider(color: p.divider)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('\u262B', style: TextStyle(fontSize: 13, color: p.gold))),
            Expanded(child: Divider(color: p.divider)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollCtrl) {
        return ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          children: [
            Center(
              child: Container(width: 42, height: 4, decoration: BoxDecoration(color: p.divider, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text('سوره صافات', style: TextStyle(color: p.textPrimary, fontWeight: FontWeight.bold, fontSize: 17)),
            ),
            const SizedBox(height: 16),
            _para(
              'سوره صافات سی‌وهفتمین سوره قرآن کریم و از سوره‌های مکی است که در جزء بیست‌وسوم قرار دارد و ۱۸۲ آیه دارد. «صافات» به معنای صف‌کشیدگان است و نام سوره از آیه نخست آن گرفته شده است. محورهای اصلی سوره شامل توحید، نبوت، معاد، رد باورهای مشرکان و بیان سرانجام مؤمنان و منکران است. محتوای سوره را می‌توان در پنج بخش کلی خلاصه کرد: بخش نخست درباره فرشتگان و شیاطین سرکش است؛ بخش دوم انکار نبوت و معاد از سوی کافران و سرانجام آنان در قیامت را بیان می‌کند؛ بخش سوم به بخش‌هایی از زندگی پیامبرانی چون نوح، ابراهیم، اسحاق، موسی، هارون، الیاس، لوط و یونس (ع) می‌پردازد؛ بخش چهارم باور مشرکان درباره نسبت خویشاوندی خداوند با جن و فرشتگان را رد می‌کند؛ و بخش پایانی از سرانجام مخالفان حق، پیروزی نهایی حق و ستایش و تنزیه خداوند سخن می‌گوید.',
            ),
            _divider(),
            _sectionTitle('فضیلت قرائت سوره صافات'),
            _para(
              'حدیث اول: فضیلت قرائت سوره صافات در روز جمعه\n\n'
              'از امام صادق (ع) روایت شده است که هر کس سوره صافات را در هر روز جمعه بخواند، در زندگی دنیا از آفات و بلاها محفوظ می‌ماند، روزی فراوانی نصیبش می‌شود و از آسیب شیطان سرکش و ستمگران در امان خواهد بود. همچنین در روایت آمده است که اگر در آن روز یا شب از دنیا برود، خداوند او را در شمار شهیدان برمی‌انگیزد و در بهشت با آنان هم‌درجه می‌گرداند.',
            ),
            _para(
              'حدیث دوم: فضیلت قرائت سوره صافات هنگام سختی مرگ\n\n'
              'از سلیمان جعفری روایت شده است که امام کاظم (ع) به فرزندش قاسم دستور داد کنار بستر برادرش سوره صافات را بخواند. قاسم شروع به قرائت کرد و هنگامی که به آیه «أَهُمْ أَشَدُّ خَلْقًا أَمْ مَنْ خَلَقْنَا» رسید، آن جوان از دنیا رفت. پس از آن، یعقوب بن جعفر از امام پرسید که پیش‌تر هنگام احتضار سوره یس خوانده می‌شد و علت دستور ایشان به خواندن سوره صافات چیست. امام فرمود که نزد هیچ بنده‌ای که در سختی و رنج مرگ گرفتار باشد، این سوره خوانده نمی‌شود مگر آنکه خداوند آسایش او را زودتر می‌رساند.',
            ),
            _divider(),
            Text('منابع', style: TextStyle(color: p.textFaint, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 8),
            Text(
              '۱. قرآن کریم، سوره صافات.\n'
              '۲. شیخ صدوق، ثواب الأعمال، بخش پاداش قرائت سوره صافات.\n'
              '۳. شیخ کلینی، الکافی، جلد ۳، باب تلقین المیت.\n'
              '۴. شیخ طوسی، تهذیب الأحکام، جلد ۱، باب تلقین المحتضر.\n'
              '۵. شیخ طبرسی، مجمع البیان، جلد ۸، تفسیر سوره صافات.\n'
              '۶. مکارم شیرازی و همکاران، تفسیر نمونه، جلد ۱۹، تفسیر سوره صافات.',
              style: TextStyle(color: p.textFaint, fontSize: 10.5, height: 1.9),
            ),
          ],
        );
      },
    );
  }
}
