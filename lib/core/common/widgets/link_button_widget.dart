import 'package:flutter/material.dart';
import 'package:blicq/core/constants/size_config.dart';
import 'package:blicq/core/utils/theme.dart';

class LinkButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  
  const LinkButtonWidget({
    super.key, 
    required this.text, 
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
      child: Text(
        text,
        style: TextStyle(
          decoration: TextDecoration.underline,
          fontSize: SizeConfig.widthPercentage(3),
          color: AppTheme.primaryBlue,
        ),
      ),
    );
  }
}
