import 'package:blicq/core/error/failures.dart';
import 'package:blicq/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blicq/features/auth/presentation/pages/login_page.dart';
import 'package:blicq/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blicq/core/constants/size_config.dart';
import 'package:blicq/core/utils/theme.dart';
import 'package:blicq/core/common/widgets/text_widget.dart';
import 'package:blicq/core/common/widgets/sub_text_widget.dart';
import 'package:blicq/core/common/widgets/primary_button_widget.dart';
import 'package:blicq/core/common/widgets/permission_tile_widget.dart';
import 'package:blicq/features/auth/presentation/pages/home_page.dart';
import 'package:blicq/features/auth/presentation/bloc/setup_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  @override
  void initState() {
    super.initState();
    context.read<SetupBloc>().add(SetupStatusChecked());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SetupBloc, SetupState>(
      listener: (context, state) {
        if (state is SetupSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else if (state is SetupFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOutRequested());
            },
            icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          ),
          title: Text(
            'Setup',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: SizeConfig.widthPercentage(4.5),
            ),
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.widthPercentage(6),
            ),
            child: BlocBuilder<SetupBloc, SetupState>(
              builder: (context, state) {
                bool isLocationEnabled = false;
                bool isBluetoothEnabled = false;

                if (state is SetupPermissionsStatus) {
                  isLocationEnabled = state.isLocationEnabled;
                  isBluetoothEnabled = state.isBluetoothEnabled;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: SizeConfig.heightPercentage(4)),
                    // Central Logo Illustration
                    Container(
                      width: SizeConfig.widthPercentage(35),
                      height: SizeConfig.widthPercentage(35),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          SizeConfig.widthPercentage(8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: SizeConfig.widthPercentage(18),
                          height: SizeConfig.widthPercentage(18),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryBlue,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: SizeConfig.widthPercentage(8),
                              height: SizeConfig.widthPercentage(8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.primaryBlue,
                              ),
                              child: const Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: SizeConfig.heightPercentage(5)),
                    // Text Content
                    const TextWidget(text: 'Precision is key'),
                    SizedBox(height: SizeConfig.heightPercentage(2)),
                    const SubTextWidget(
                      text:
                          'To accurately detect proximity and keep your environment secure, we need a few keys to the kingdom.',
                    ),
                    SizedBox(height: SizeConfig.heightPercentage(5)),
                    // Permission Toggles
                    PermissionTileWidget(
                      title: 'Enable Location Services (Always)',
                      subtitle: 'Required for background awareness',
                      value: isLocationEnabled,
                      onChanged: (val) {
                        context.read<SetupBloc>().add(
                          SetupPermissionsRequested(),
                        );
                      },
                    ),
                    SizedBox(height: SizeConfig.heightPercentage(2)),
                    PermissionTileWidget(
                      title: 'Enable Bluetooth Scan',
                      subtitle: 'Detects nearby trusted devices',
                      value: isBluetoothEnabled,
                      onChanged: (val) {
                        context.read<SetupBloc>().add(
                          SetupPermissionsRequested(),
                        );
                      },
                    ),
                    const Spacer(),
                    // Action Button
                    PrimaryButtonWidget(
                      text: 'Grant Permissions',
                      icon: Icons.arrow_forward,
                      onPressed: (isLocationEnabled && isBluetoothEnabled)
                          ? () => context.read<SetupBloc>().add(
                              SetupPermissionsRequested(),
                            )
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enable all permissions to proceed.',
                                  ),
                                ),
                              );
                            },
                    ),
                    SizedBox(height: SizeConfig.heightPercentage(3)),
                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: SizeConfig.widthPercentage(3.5),
                          color: Colors.grey,
                        ),
                        SizedBox(width: SizeConfig.widthPercentage(1)),
                        Text(
                          'DATA IS ENCRYPTED AND STORED LOCALLY',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: SizeConfig.widthPercentage(2.5),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SizeConfig.heightPercentage(3)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
