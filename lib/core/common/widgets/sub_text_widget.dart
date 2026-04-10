import 'package:flutter/material.dart';
import 'package:blicq/core/constants/size_config.dart';

class SubTextWidget extends StatelessWidget {
  final String text;
  const SubTextWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.widthPercentage(5)),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: SizeConfig.widthPercentage(4),
            ),
      ),
    );
  }
}
