import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blicq/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blicq/core/constants/size_config.dart';
import 'package:blicq/core/utils/theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String? name, email, photoUrl;
        if (state is AuthAuthenticated) {
          name = state.user.name;
          email = state.user.email;
          photoUrl = state.user.photoUrl;
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.widthPercentage(5)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: SizeConfig.heightPercentage(5)),
              CircleAvatar(
                radius: SizeConfig.widthPercentage(15),
                backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null ? Icon(Icons.person, size: 50, color: AppTheme.primaryBlue) : null,
              ),
              SizedBox(height: SizeConfig.heightPercentage(2)),
              Text(
                name ?? 'User Name',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: SizeConfig.widthPercentage(6),
                ),
              ),
              Text(
                email ?? 'email@example.com',
                style: TextStyle(color: AppTheme.textLight, fontSize: SizeConfig.widthPercentage(3.5)),
              ),
              SizedBox(height: SizeConfig.heightPercentage(5)),
              _buildProfileOption(Icons.security, 'Internal Security Settings'),
              _buildProfileOption(Icons.settings, 'Application Configuration'),
              _buildProfileOption(Icons.help_outline, 'Help & Support'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthBackRequested());
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('LOG OUT', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: SizeConfig.heightPercentage(5)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileOption(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 20),
          const SizedBox(width: 15),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
        ],
      ),
    );
  }
}
