import 'package:flutter/material.dart';
import 'package:blicq/core/constants/size_config.dart';
import 'package:blicq/core/utils/theme.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.widthPercentage(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: SizeConfig.heightPercentage(2)),
          Text(
            'Alerts & Notifications',
            style: TextStyle(
              color: AppTheme.textDark,
              fontWeight: FontWeight.bold,
              fontSize: SizeConfig.widthPercentage(6),
            ),
          ),
          SizedBox(height: SizeConfig.heightPercentage(1)),
          Text(
            'Keep track of your proximity events',
            style: TextStyle(
              color: AppTheme.textLight,
              fontSize: SizeConfig.widthPercentage(3.5),
            ),
          ),
          const Spacer(),
          Center(
            child: Column(
              children: [
                Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 10),
                Text(
                  'No notifications yet',
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
