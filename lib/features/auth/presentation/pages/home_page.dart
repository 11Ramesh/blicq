import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blicq/core/constants/size_config.dart';
import 'package:blicq/core/utils/theme.dart';
import 'package:blicq/features/auth/presentation/pages/scan_page.dart';
import 'package:blicq/features/auth/presentation/pages/alerts_page.dart';
import 'package:blicq/features/auth/presentation/pages/profile_page.dart';
import 'package:blicq/features/auth/presentation/bloc/beacon_bloc.dart';
import 'package:blicq/core/common/beacon/ibeacon_service.dart';
import 'package:blicq/core/common/notifications/notification_service.dart';
import 'package:blicq/init_dependencies.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _isInBackground = false;

  final NotificationService _notificationService = serviceLocator<NotificationService>();

  // Notification tracking (local to session)
  final Set<String> _notifiedBeacons = {};
  final Set<String> _nearFiveMeterBeacons = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<BeaconBloc>().add(BeaconStarted());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isInBackground = state == AppLifecycleState.paused || state == AppLifecycleState.inactive;
  }

  void _showBluetoothDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Bluetooth Required'),
        content: const Text(
          'Bluetooth is required to scan for nearby beacons. Please enable it to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('MAYBE LATER'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              serviceLocator<IBeaconService>().openBluetoothSettings();
            },
            child: const Text('ENABLE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleNotifications(List<BeaconModel> beacons) {
    for (final beacon in beacons) {
      final key = '${beacon.uuid}_${beacon.major}_${beacon.minor}';

      // 1. Detection Notification
      if (!_notifiedBeacons.contains(key)) {
        _notifiedBeacons.add(key);
        if (_isInBackground) {
          _notificationService.showNotification(
            id: key.hashCode,
            title: 'Beacon Detected',
            body: 'A known beacon (${beacon.uuid.substring(0, 8)}) is nearby.',
          );
        }
      }

      // 2. 5-Meter Mark Logic
      if (beacon.estimatedDistance <= 5.0) {
        if (!_nearFiveMeterBeacons.contains(key)) {
          _nearFiveMeterBeacons.add(key);
          _notificationService.showNotification(
            id: key.hashCode + 1,
            title: 'Proximity Alert',
            body: 'You are within 5 meters of beacon ${beacon.uuid.substring(0, 8)}!',
          );
          if (!_isInBackground) {
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text('Precision Alert: Within 5m of ${beacon.uuid.substring(0, 8)}'),
            //     backgroundColor: AppTheme.primaryBlue,
            //     behavior: SnackBarBehavior.floating,
            //   ),
            // );
          }
        }
      } else {
        _nearFiveMeterBeacons.remove(key);
      }
    }
    
    // Cleanup tracking for beacons no longer in range
    final activeKeys = beacons.map((b) => '${b.uuid}_${b.major}_${b.minor}').toSet();
    _notifiedBeacons.retainAll(activeKeys);
    _nearFiveMeterBeacons.retainAll(activeKeys);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BeaconBloc, BeaconState>(
      listener: (context, state) {
        if (state is BeaconScanning) {
          if (!state.bluetoothEnabled) {
            _showBluetoothDialog();
          }
          _handleNotifications(state.detectedBeacons);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFD),
        appBar: _buildAppBar(context),
        body: BlocBuilder<BeaconBloc, BeaconState>(
          builder: (context, state) {
            List<BeaconModel> detectedBeacons = [];
            int strongestRSSI = -100;

            if (state is BeaconScanning) {
              detectedBeacons = state.detectedBeacons;
              strongestRSSI = state.strongestRSSI;
            }

            final List<Widget> pages = [
              ScanPage(
                detectedBeacons: detectedBeacons,
                strongestRSSI: strongestRSSI,
                onRefresh: () => context.read<BeaconBloc>().add(BeaconStarted()),
              ),
              AlertsPage(
                activeScans: detectedBeacons.length,
                nearbyBeacons: detectedBeacons.where((b) => b.proximity.toLowerCase() == 'near').length,
              ),
              ProfilePage(
                activeNodes: detectedBeacons.length,
                signalHealth: _calculateSignalHealth(strongestRSSI),
              ),
            ];

            return IndexedStack(index: _currentIndex, children: pages);
          },
        ),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton(
                onPressed: () => context.read<BeaconBloc>().add(BeaconCheckBluetooth()),
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  String _calculateSignalHealth(int rssi) {
    if (rssi == -100) return '0%';
    double percentage = ((rssi + 100) / 70) * 100;
    if (percentage > 100) percentage = 100;
    if (percentage < 0) percentage = 0;
    return '${percentage.toInt()}%';
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    String title = 'Proximity Aware';
    if (_currentIndex == 1) title = 'Alerts';
    if (_currentIndex == 2) title = 'Profile';

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: _currentIndex != 1,
      leading: _currentIndex == 1
          ? const Icon(Icons.sensors, color: AppTheme.primaryBlue)
          : null,
      title: Text(
        title,
        style: TextStyle(
          color: AppTheme.textDark,
          fontWeight: FontWeight.bold,
          fontSize: SizeConfig.widthPercentage(4.5),
        ),
      ),
      actions: [
        if (_currentIndex == 0)
          IconButton(
            onPressed: () => context.read<BeaconBloc>().add(BeaconCheckBluetooth()),
            icon: const Icon(Icons.bluetooth, color: AppTheme.primaryBlue),
          ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: 'SCAN'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'ALERTS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'PROFILE',
          ),
        ],
      ),
    );
  }
}
