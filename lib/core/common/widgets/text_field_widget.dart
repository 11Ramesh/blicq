import 'package:flutter/material.dart';
import 'package:blicq/core/constants/size_config.dart';
import 'package:blicq/core/utils/theme.dart';

class TextFieldWidget extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final VoidCallback? onSubmit;

  const TextFieldWidget({
    super.key,
    required this.hintText,
    this.controller,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.inputBg,
        borderRadius: BorderRadius.circular(SizeConfig.widthPercentage(4)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.widthPercentage(4),
        vertical: SizeConfig.heightPercentage(0.5),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: SizeConfig.widthPercentage(4)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: SizeConfig.widthPercentage(3.5)),
          border: InputBorder.none,
          suffixIcon: Container(
            margin: EdgeInsets.all(SizeConfig.widthPercentage(2)),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_forward_rounded,
                size: SizeConfig.widthPercentage(3),
              ),
              onPressed: onSubmit,
            ),
          ),
        ),
      ),
    );
  }
}
