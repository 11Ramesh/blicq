import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:blicq/core/utils/theme.dart';
import 'package:blicq/core/constants/size_config.dart';

class SocialButton extends StatelessWidget {
  final dynamic icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final bool hasBorder;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.hasBorder = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: SizeConfig.heightPercentage(7),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.widthPercentage(4)),
            side: hasBorder ? const BorderSide(color: AppTheme.dividerGrey) : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon is IconData 
              ? Icon(icon, size: SizeConfig.widthPercentage(5)) 
              : FaIcon(icon, size: SizeConfig.widthPercentage(5)),
            SizedBox(width: SizeConfig.widthPercentage(3)),
            Text(
              label,
              style: TextStyle(
                fontSize: SizeConfig.widthPercentage(4),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
