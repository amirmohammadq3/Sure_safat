class Ayah {
  final int number;
  final String arabic;
  final String persian;
  const Ayah({required this.number, required this.arabic, required this.persian});
}

class SurahData {
  final int number;
  final String nameAr;
  final String nameFa;
  final String basmala;
  final String translator;
  final List<Ayah> ayahs;

  const SurahData({
    required this.number,
    required this.nameAr,
    required this.nameFa,
    required this.basmala,
    required this.translator,
    required this.ayahs,
  });
}
