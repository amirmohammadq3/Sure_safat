import 'package:flutter/material.dart';
import '../common/palette.dart';

class DashedDivider extends StatelessWidget {
  final AppPalette p;
  const DashedDivider({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: LayoutBuilder(builder: (context, c) {
              final count = (c.maxWidth / 9).floor();
              return Row(
                children: List.generate(
                  count,
                  (_) => Expanded(child: Center(child: Container(width: 5, height: 1.2, color: p.gold.withOpacity(0.55)))),
                ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            // نماد فارسی (☫ U+262B) دقیقاً مثل خط‌چین صفحه‌ی دعای عهد
            child: Text('\u262B', style: TextStyle(fontSize: 15, color: p.gold, height: 1)),
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, c) {
              final count = (c.maxWidth / 9).floor();
              return Row(
                children: List.generate(
                  count,
                  (_) => Expanded(child: Center(child: Container(width: 5, height: 1.2, color: p.gold.withOpacity(0.55)))),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
