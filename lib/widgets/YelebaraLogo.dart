import 'package:flutter/material.dart';

class YelebaraLogo extends StatelessWidget {
  final double size;
  final bool asTitle;
  const YelebaraLogo({super.key, this.size = 36, this.asTitle = false});

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/YELEBARA_logo.png',
      height: size,
      fit: BoxFit.contain,
    );
    if (asTitle) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          image,
          const SizedBox(width: 8),
          Text(
            'YELEBARA',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      );
    }
    return image;
  }
}









