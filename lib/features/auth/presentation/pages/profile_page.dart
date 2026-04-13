import 'package:blicq/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blicq/init_dependencies.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:blicq/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blicq/core/constants/size_config.dart';
import 'package:blicq/core/utils/theme.dart';
import 'package:blicq/core/common/widgets/stat_card_widget.dart';
import 'package:blicq/core/common/widgets/text_widget.dart';
import 'package:blicq/core/common/widgets/sub_text_widget.dart';
import 'package:blicq/core/common/widgets/primary_button_widget.dart';

class ProfilePage extends StatelessWidget {
  final int activeNodes;
  final String signalHealth;

  const ProfilePage({
    super.key,
    required this.activeNodes,
    required this.signalHealth,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String name = 'Guest User';
        String email = 'Not signed in';
        String? photoUrl;

        if (state is AuthAuthenticated) {
          name = state.user.name;
          email = state.user.email;
          photoUrl = state.user.photoUrl;
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: SizeConfig.heightPercentage(4)),
              _buildAvatar(photoUrl),
              SizedBox(height: SizeConfig.heightPercentage(2)),
              TextWidget(text: name),
              SubTextWidget(text: email),
              SizedBox(height: SizeConfig.heightPercentage(4)),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.widthPercentage(5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: StatCardWidget(
                        label: 'ACTIVE NODES',
                        value: activeNodes.toString(),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: StatCardWidget(
                        label: 'SIGNAL HEALTH',
                        value: signalHealth,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: SizeConfig.heightPercentage(4)),
              _buildConfigurationSection(),
              SizedBox(height: SizeConfig.heightPercentage(3)),
              _buildStatusBanner(),
              SizedBox(height: SizeConfig.heightPercentage(3)),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.widthPercentage(5),
                ),
                child: PrimaryButtonWidget(
                  text: 'Sign Out',
                  icon: Icons.logout,
                  onPressed: () async {
                    final prefs = serviceLocator<SharedPreferences>();
                    await prefs.setBool('setup_completed', false);
                    if (context.mounted) {
                      context.read<AuthBloc>().add(AuthBackRequested());
                    }
                  },
                ),
              ),
              SizedBox(height: SizeConfig.heightPercentage(2)),
              _buildVersionFooter(),
              SizedBox(height: SizeConfig.heightPercentage(5)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVersionFooter() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        String version = 'Unknown';
        if (snapshot.hasData) {
          version = snapshot.data!.version;
        }
        return Text(
          'VERSION $version STABLE',
          style: TextStyle(
            color: Colors.grey.withOpacity(0.5),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  Widget _buildAvatar(String? photoUrl) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Colors.orangeAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CircleAvatar(
            radius: SizeConfig.widthPercentage(15),
            backgroundColor: Colors.white,
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null
                ? const Icon(Icons.person, size: 50, color: Colors.grey)
                : null,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: AppTheme.primaryBlue,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.verified_user, color: Colors.white, size: 16),
        ),
      ],
    );
  }

  Widget _buildConfigurationSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.widthPercentage(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 5, bottom: 10),
            child: Text(
              'CONFIGURATION',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                _buildListTile(
                  Icons.notifications_none,
                  'Notification Preferences',
                  'Manage proximity alerts and system logs',
                ),
                const Divider(indent: 70, endIndent: 20),
                _buildListTile(
                  Icons.sensors,
                  'iBeacon Protocol Specs',
                  'UUID, Major, and Minor broadcast settings',
                ),
                const Divider(indent: 70, endIndent: 20),
                _buildListTile(
                  Icons.dashboard_outlined,
                  'Distance Algorithm Explanation',
                  'RSSI path loss model and trilateration',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 11),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
    );
  }

  Widget _buildStatusBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.widthPercentage(5)),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFFFCC33).withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.radar,
                color: Color(0xFFFF9900),
                size: 18,
              ),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BACKGROUND SCAN ACTIVE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Precision Tracking: 0.2m variance',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
