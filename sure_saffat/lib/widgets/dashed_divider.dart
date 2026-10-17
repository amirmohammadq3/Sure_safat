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
            child: Icon(Icons.star, size: 11, color: p.gold),
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
