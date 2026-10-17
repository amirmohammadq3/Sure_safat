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
            Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.circle, size: 5, color: p.gold)),
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
              child: Text('درباره‌ی سوره صافات', style: TextStyle(color: p.textPrimary, fontWeight: FontWeight.bold, fontSize: 17)),
            ),
            const SizedBox(height: 16),
            _para(
              'سوره صافات سی‌وهفتمین سوره قرآن کریم و از سوره‌های مکی است که در جزء بیست‌وسوم جای دارد. «صافات» به معنای صف‌کشیدگان است و محور اصلی آن توحید، تهدید مشرکان و بشارت مؤمنان است. این سوره در پنج بخش کلی تنظیم شده است: بخش اول به فرشتگان و شیاطین سرکش و سرنوشت آنها می‌پردازد؛ بخش دوم انکار کافران نسبت به نبوت و معاد و عاقبت آنها در قیامت را شرح می‌دهد؛ بخش سوم بخشی از تاریخ انبیای بزرگ مانند نوح، ابراهیم، موسی، هارون، الیاس، لوط و یونس (ع) را بازگو می‌کند؛ بخش چهارم به بدترین نوع شرک، یعنی اعتقاد به رابطه خویشاوندی میان خداوند و جن یا فرشتگان، می‌پردازد؛ و بخش پنجم به پیروزی لشکر حق بر لشکر کفر و شرک و نفاق اشاره می‌نماید.',
            ),
            _divider(),
            _sectionTitle('فضیلت قرائت سوره صافات'),
            _para(
              'از پیامبر اکرم (ص) روایت شده است: «هر کس سوره صافات را بخواند، خداوند به تعداد همه جنیان و شیطان‌ها به او ده حسنه عنایت می‌کند و شیطان‌ها را از او دور می‌سازد و از شرک مبرا می‌شود و دو فرشته حافظ او در روز قیامت به سود او شهادت می‌دهند که به پیامبران الهی ایمان دارد.»',
            ),
            _para(
              'از امام صادق (ع) نیز روایت شده است: «هر که سوره صافات را در هر روز جمعه قرائت کند، همواره در حفظ و امان الهی بوده و آفت‌ها و بلاها در زندگی دنیایی از او دفع می‌شود. روزی فراوانی از جانب خداوند به او داده می‌شود و از سوی شیطان و حاکمان ستمگر آسیبی به مال و فرزندان و بدن او نمی‌رسد. اگر در همان روز یا شب جمعه بمیرد، خداوند او را شهید به شمار آورده و در روز قیامت در شمار شهدا خواهد بود و در بهشت هم‌درجه با شهیدان است.»',
            ),
            _divider(),
            _sectionTitle('آثار و برکات سوره'),
            _para('۱) آسان شدن جان دادن محتضر:\n'
                'سلیمان جعفری می‌گوید: «امام کاظم (ع) را دیدم که به فرزندش قاسم فرمود: برخیز و در کنار بستر برادرت سوره صافات را قرائت نما. قاسم چنین کرد و وقتی به آیه «أَهُمْ أَشَدُّ خَلْقًا أَمْ مَنْ خَلَقْنَا» رسید، عمر برادر پایان یافت. آنگاه یعقوب بن جعفر به امام عرض کرد: پیش از این برای کسی که در حال مرگ بود، سوره یس را قرائت می‌کردیم؛ اما امروز شما فرمودید سوره صافات را بخوانند؟ امام فرمود: سوره صافات را نزد هر مؤمنی که به سختی در حال جان دادن است بخوانند، خداوند مرگش را سریع و آسان می‌کند.»'),
            _para('۲) راه اجابت دعا:\n'
                'از پیامبر گرامی اسلام (ص) روایت شده است: «هر کس سوره یس و صافات را در روز جمعه قرائت کند و آنگاه دعا کند، خداوند خواسته‌اش را اجابت می‌کند.»'),
            _para('۳) تسکین درد:\n'
                'در کتاب المصباح کفعمی آمده است: «اگر کسی سوره صافات را بنویسد و پس از شستن آن، بدنش را با این آب بشوید، دردهایش برطرف می‌شود.»'),
            _para('۴) ایمنی از ترس عقرب گزیدگی:\n'
                'امیرالمؤمنین (ع) می‌فرماید: «هر کس از عقرب گزیدگی می‌ترسد، آیات ۷۹ تا ۸۱ این سوره را بخواند، خداوند او را از این ترس ایمن می‌کند.»'),
            _para('۵) دستیابی به شرف و جاه:\n'
                'مرحوم طبرسی در کتاب مکارم الاخلاق آورده است: «در روایت است که سوره صافات را برای دستیابی به شرف و جاه در دنیا و آخرت می‌خوانند.»'),
            _divider(),
            Text('منابع', style: TextStyle(color: p.textFaint, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 8),
            Text(
              '۱. تفسیر نمونه، ج ۱۹، ذیل سوره صافات (محتوا و فضیلت)\n'
              '۲. مجمع‌البیان، آغاز سوره صافات (روایات فضیلت)\n'
              '۳. ثواب‌الاعمال و عقاب‌الأعمال، ج ۲، ص ۱۱۲ (روایت امام صادق ع)\n'
              '۴. المصباح کفعمی (تسکین درد)\n'
              '۵. مکارم الاخلاق، طبرسی (شرف و جاه)\n'
              '۶. وسائل‌الشیعة، باب استحباب قراءة الصافات و یس عند المحتضر (آسان شدن جان دادن)\n'
              '۷. عيون الغرر في فضائل الآيات والسور، ج ۱، ص ۱۴۶ (روایت سلیمان جعفری)',
              style: TextStyle(color: p.textFaint, fontSize: 10.5, height: 1.9),
            ),
          ],
        );
      },
    );
  }
}
