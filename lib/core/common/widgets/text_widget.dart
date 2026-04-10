import 'package:flutter/material.dart';
import 'package:blicq/core/constants/size_config.dart';

class TextWidget extends StatelessWidget {
  final String text;
  const TextWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: SizeConfig.widthPercentage(7),
          ),
    );
  }
}
