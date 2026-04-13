import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:blicq/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blicq/core/utils/theme.dart';
import 'package:blicq/core/constants/size_config.dart';
import 'package:blicq/features/auth/presentation/widgets/social_button.dart';
import 'package:blicq/core/common/widgets/text_widget.dart';
import 'package:blicq/core/common/widgets/sub_text_widget.dart';
import 'package:blicq/core/common/widgets/text_field_widget.dart';
import 'package:blicq/core/common/widgets/link_button_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onLogin() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      // For "test purpose" as mentioned by the user, we use a default password
      // or they can add a password field later.
      context.read<AuthBloc>().add(
        AuthEmailSignInRequested(email: email, password: 'password123'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final height = SizeConfig.screenHeight;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.widthPercentage(6),
            ),
            child: SizedBox(
              height: height - MediaQuery.of(context).padding.top,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: SizeConfig.heightPercentage(5)),
                  // Logo
                  Container(
                    width: SizeConfig.widthPercentage(20),
                    height: SizeConfig.widthPercentage(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(
                        SizeConfig.widthPercentage(5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          blurRadius: SizeConfig.widthPercentage(5),
                          offset: Offset(0, SizeConfig.widthPercentage(2.5)),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.location_on_outlined,
                        color: Colors.white,
                        size: SizeConfig.widthPercentage(10),
                      ),
                    ),
                  ),
                  SizedBox(height: SizeConfig.heightPercentage(5)),

                  const TextWidget(text: 'Welcome to Proximity Aware'),
                  SizedBox(height: SizeConfig.heightPercentage(2)),

                  const SubTextWidget(
                    text:
                        'Stay connected with precision location tracking and real-time proximity alerts.',
                  ),
                  SizedBox(height: SizeConfig.heightPercentage(6)),

                  // Apple Button
                  SocialButton(
                    icon: FontAwesomeIcons.apple,
                    label: 'Sign in with Apple',
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthAppleSignInRequested());
                    },
                  ),
                  SizedBox(height: SizeConfig.heightPercentage(2)),

                  // Google Button
                  SocialButton(
                    icon: FontAwesomeIcons.google,
                    label: 'Sign in with Google',
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    hasBorder: true,
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthGoogleSignInRequested());
                    },
                  ),
                  SizedBox(height: SizeConfig.heightPercentage(4)),

                  // Divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: AppTheme.dividerGrey),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.widthPercentage(4),
                        ),
                        child: Text(
                          'OR ACCESS VIA',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                fontSize: SizeConfig.widthPercentage(2.5),
                              ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: AppTheme.dividerGrey),
                      ),
                    ],
                  ),
                  SizedBox(height: SizeConfig.heightPercentage(4)),

                  TextFieldWidget(
                    hintText: 'Enter your email',
                    controller: _emailController,
                    onSubmit: () {
                      _onLogin();
                    },
                  ),
                  SizedBox(height: SizeConfig.heightPercentage(3)),

                  // Secure Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.widthPercentage(4),
                      vertical: SizeConfig.heightPercentage(1),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FC),
                      borderRadius: BorderRadius.circular(
                        SizeConfig.widthPercentage(3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: SizeConfig.widthPercentage(4),
                          color: AppTheme.primaryBlue,
                        ),
                        SizedBox(width: SizeConfig.widthPercentage(2)),
                        Text(
                          'SECURE FIREBASE SSO',
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: SizeConfig.widthPercentage(2.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // const Spacer(),

                  // Footer
                  Text(
                    'By signing in, you agree to our',
                    style: TextStyle(fontSize: SizeConfig.widthPercentage(3)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LinkButtonWidget(
                        text: 'Terms of Service',
                        onPressed: () {},
                      ),
                      Text(
                        ' and ',
                        style: TextStyle(
                          fontSize: SizeConfig.widthPercentage(3),
                        ),
                      ),
                      LinkButtonWidget(
                        text: 'Privacy Policy',
                        onPressed: () {},
                      ),
                    ],
                  ),
                  // SizedBox(height: SizeConfig.heightPercentage(2.5)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
