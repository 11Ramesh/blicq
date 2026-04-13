import 'dart:async';
import 'package:flutter/material.dart';
import 'package:blicq/core/constants/size_config.dart';
import 'package:blicq/core/utils/theme.dart';
import 'package:blicq/features/auth/presentation/pages/scan_page.dart';
import 'package:blicq/features/auth/presentation/pages/alerts_page.dart';
import 'package:blicq/features/auth/presentation/pages/profile_page.dart';
import 'package:blicq/core/common/beacon/ibeacon_service.dart';
import 'package:blicq/init_dependencies.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  
  // Beacon State shared between Scan and Profile
  final IBeaconService _beaconService = serviceLocator<IBeaconService>();
  StreamSubscription? _beaconSubscription;
  List<BeaconModel> _detectedBeacons = [];
  int _strongestRSSI = -100;
  final Map<String, DateTime> _lastSeenTimes = {};
  final Duration _persistenceTimeout = const Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _checkBluetoothStatus();
    _startScanning();
  }

  Future<void> _checkBluetoothStatus() async {
    final isEnabled = await _beaconService.isBluetoothEnabled();
    if (!isEnabled && mounted) {
      _showBluetoothDialog();
    }
  }

  void _showBluetoothDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Bluetooth Required'),
        content: const Text('Bluetooth is required to scan for nearby beacons. Please enable it to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('MAYBE LATER'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _beaconService.openBluetoothSettings();
            },
            child: const Text('ENABLE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _startScanning() {
    _beaconSubscription?.cancel();
    _beaconSubscription = _beaconService.startScanning().listen((newBeacons) {
      if (!mounted) return;

      setState(() {
        final now = DateTime.now();
        for (final beacon in newBeacons) {
          final key = '${beacon.uuid}_${beacon.major}_${beacon.minor}';
          _lastSeenTimes[key] = now;
          final index = _detectedBeacons.indexWhere((e) => '${e.uuid}_${e.major}_${e.minor}' == key);
          if (index != -1) {
            _detectedBeacons[index] = beacon;
          } else {
            _detectedBeacons.add(beacon);
          }
        }

        _detectedBeacons.removeWhere((beacon) {
          final key = '${beacon.uuid}_${beacon.major}_${beacon.minor}';
          final lastSeen = _lastSeenTimes[key];
          return lastSeen == null || now.difference(lastSeen) > _persistenceTimeout;
        });

        if (_detectedBeacons.isNotEmpty) {
          _strongestRSSI = _detectedBeacons.map((e) => e.rssi).reduce((a, b) => a > b ? a : b);
        } else {
          _strongestRSSI = -100;
        }
      });
    });
  }

  void _onRefresh() {
    setState(() {
      _detectedBeacons.clear();
      _lastSeenTimes.clear();
    });
    _startScanning();
  }

  @override
  void dispose() {
    _beaconSubscription?.cancel();
    _beaconService.stopScanning();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      ScanPage(
        detectedBeacons: _detectedBeacons,
        strongestRSSI: _strongestRSSI,
        onRefresh: _onRefresh,
      ),
      AlertsPage(
        activeScans: 12,
        nearbyBeacons: _detectedBeacons.length,
      ),
      ProfilePage(
        activeNodes: _detectedBeacons.length,
        signalHealth: _calculateSignalHealth(_strongestRSSI),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: _buildAppBar(context),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      floatingActionButton: _currentIndex == 0 
        ? FloatingActionButton(
            onPressed: _checkBluetoothStatus,
            backgroundColor: AppTheme.primaryBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.add, color: Colors.white),
          )
        : null,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  String _calculateSignalHealth(int rssi) {
    if (rssi == -100) return '0%';
    // Mapping RSSI (-100 to -30) to percentage (0 to 100)
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
            onPressed: _checkBluetoothStatus,
            icon: const Icon(Icons.bluetooth, color: AppTheme.primaryBlue),
          ),
        if (_currentIndex == 1)
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune, color: AppTheme.textDark, size: 20),
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
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'ALERTS'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'PROFILE'),
        ],
      ),
    );
  }
}
