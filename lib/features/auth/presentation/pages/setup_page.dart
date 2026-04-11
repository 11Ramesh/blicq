import 'package:flutter/material.dart';
import 'package:blicq/core/constants/size_config.dart';
import 'package:blicq/core/utils/theme.dart';
import 'package:blicq/core/common/widgets/text_widget.dart';
import 'package:blicq/core/common/widgets/sub_text_widget.dart';
import 'package:blicq/core/common/widgets/primary_button_widget.dart';
import 'package:blicq/core/common/widgets/permission_tile_widget.dart';
import 'package:blicq/features/auth/presentation/pages/home_page.dart';
import 'package:blicq/init_dependencies.dart';
import 'package:blicq/core/common/beacon/ibeacon_service.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  bool isLocationEnabled = false;
  bool isBluetoothEnabled = false;
  final IBeaconService _beaconService = serviceLocator<IBeaconService>();

  @override
  void initState() {
    super.initState();
    _checkInitialPermissions();
  }

  Future<void> _checkInitialPermissions() async {
    final hasPermissions = await _beaconService.checkPermissions();
    final isBtEnabled = await _beaconService.isBluetoothEnabled();
    if (mounted) {
      setState(() {
        isLocationEnabled = hasPermissions;
        isBluetoothEnabled = isBtEnabled;
      });
    }
  }

  Future<void> _handleGrantPermissions() async {
    await _beaconService.requestPermissions();
    final hasPermissions = await _beaconService.checkPermissions();
    if (hasPermissions) {
       if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      // Show snackbar or message if permissions not granted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please grant all permissions to continue')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
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
          child: Column(
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
                      border: Border.all(color: AppTheme.primaryBlue, width: 2),
                    ),
                    child: Center(
                      child: Container(
                        width: SizeConfig.widthPercentage(8),
                        height: SizeConfig.widthPercentage(8),
                        decoration: BoxDecoration(
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
                onChanged: (val) async {
                  if (val) await _beaconService.requestPermissions();
                  _checkInitialPermissions();
                },
              ),
              SizedBox(height: SizeConfig.heightPercentage(2)),
              PermissionTileWidget(
                title: 'Enable Bluetooth Scan',
                subtitle: 'Detects nearby trusted devices',
                value: isBluetoothEnabled,
                onChanged: (val) async {
                  if (val) await _beaconService.requestPermissions();
                  _checkInitialPermissions();
                },
              ),
              const Spacer(),
              // Action Button
              PrimaryButtonWidget(
                text: 'Grant Permissions',
                icon: Icons.arrow_forward,
                onPressed: _handleGrantPermissions,
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
          ),
        ),
      ),
    );
  }

}
