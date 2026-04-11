import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blicq/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blicq/core/constants/size_config.dart';
import 'package:blicq/core/utils/theme.dart';
import 'package:blicq/core/common/beacon/ibeacon_service.dart';
import 'package:blicq/init_dependencies.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final IBeaconService _beaconService = serviceLocator<IBeaconService>();
  StreamSubscription? _beaconSubscription;
  List<BeaconModel> _detectedBeacons = [];
  int _strongestRSSI = -100;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  final Map<String, DateTime> _lastSeenTimes = {};
  final Duration _persistenceTimeout = const Duration(seconds: 10);

  void _startScanning() {
    _beaconSubscription?.cancel();
    _beaconSubscription = _beaconService.startScanning().listen((newBeacons) {
      if (!mounted) return;

      setState(() {
        final now = DateTime.now();
        
        // 1. Update/Add new beacons
        for (final beacon in newBeacons) {
          final key = '${beacon.uuid}_${beacon.major}_${beacon.minor}';
          _lastSeenTimes[key] = now;
          
          final index = _detectedBeacons.indexWhere((e) => '${e.uuid}_${e.major}_${e.minor}' == key);
          if (index != -1) {
            _detectedBeacons[index] = beacon; // Update existing
          } else {
            _detectedBeacons.add(beacon); // Add new
          }
        }

        // 2. Prune beacons not seen within timeout
        _detectedBeacons.removeWhere((beacon) {
          final key = '${beacon.uuid}_${beacon.major}_${beacon.minor}';
          final lastSeen = _lastSeenTimes[key];
          return lastSeen == null || now.difference(lastSeen) > _persistenceTimeout;
        });

        // 3. Update Stats
        if (_detectedBeacons.isNotEmpty) {
          _strongestRSSI = _detectedBeacons.map((e) => e.rssi).reduce((a, b) => a > b ? a : b);
        } else {
          _strongestRSSI = -100;
        }
      });
    });
  }

  @override
  void dispose() {
    _beaconSubscription?.cancel();
    _beaconService.stopScanning();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.widthPercentage(5)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: SizeConfig.heightPercentage(2)),
              _buildScanningHeader(),
              SizedBox(height: SizeConfig.heightPercentage(3)),
              _buildStatsRow(),
              SizedBox(height: SizeConfig.heightPercentage(4)),
              _buildBeaconsHeader(),
              SizedBox(height: SizeConfig.heightPercentage(2)),
              _buildBeaconsList(),
              SizedBox(height: SizeConfig.heightPercentage(10)), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            String? photoUrl;
            if (state is AuthAuthenticated) photoUrl = state.user.photoUrl;
            return CircleAvatar(
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null ? const Icon(Icons.person, size: 20) : null,
            );
          },
        ),
      ),
      title: Text(
        'Proximity Aware',
        style: TextStyle(
          color: AppTheme.textDark,
          fontWeight: FontWeight.bold,
          fontSize: SizeConfig.widthPercentage(4.5),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _startScanning(),
          icon: const Icon(Icons.sensors, color: AppTheme.primaryBlue),
        ),
        IconButton(
          onPressed: () {
            context.read<AuthBloc>().add(AuthBackRequested());
          },
          icon: const Icon(Icons.logout, color: AppTheme.textDark),
        ),
      ],
    );
  }

  Widget _buildScanningHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.radar, color: Colors.white, size: 30),
            ),
          ),
          SizedBox(height: SizeConfig.heightPercentage(2)),
          Text(
            'STATUS: ACTIVE',
            style: TextStyle(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: SizeConfig.widthPercentage(3),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Precision Scanning',
            style: TextStyle(
              color: AppTheme.textDark,
              fontWeight: FontWeight.bold,
              fontSize: SizeConfig.widthPercentage(6),
            ),
          ),
          SizedBox(height: SizeConfig.heightPercentage(1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.widthPercentage(10)),
            child: Text(
              'Actively monitoring Bluetooth Low Energy signals in your immediate perimeter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textLight,
                fontSize: SizeConfig.widthPercentage(3.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'ACTIVE NODES',
            _detectedBeacons.length.toString(),
            Colors.white,
            AppTheme.textDark,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            'STRONGEST RSSI',
            '$_strongestRSSI dBm',
            AppTheme.primaryBlue,
            Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: SizeConfig.widthPercentage(2.5),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: SizeConfig.widthPercentage(5.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeaconsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detected Beacons',
              style: TextStyle(
                color: AppTheme.textDark,
                fontWeight: FontWeight.bold,
                fontSize: SizeConfig.widthPercentage(4.5),
              ),
            ),
            Text(
              'Nearby localized identifiers',
              style: TextStyle(
                color: AppTheme.textLight,
                fontSize: SizeConfig.widthPercentage(3),
              ),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _detectedBeacons.clear();
              _lastSeenTimes.clear();
            });
            _startScanning();
          },
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('REFRESH'),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primaryBlue,
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildBeaconsList() {
    if (_detectedBeacons.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Icon(Icons.bluetooth_searching, size: 50, color: Colors.grey[300]),
              const SizedBox(height: 10),
              Text('No beacons detected nearby', style: TextStyle(color: Colors.grey[400])),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _detectedBeacons.length,
      separatorBuilder: (_, __) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        return _buildBeaconCard(_detectedBeacons[index]);
      },
    );
  }

  Widget _buildBeaconCard(BeaconModel beacon) {
    final proximityColor = _getProximityColor(beacon.proximity);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Node: ${beacon.uuid.substring(0, 8)}...',
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.widthPercentage(4),
                    ),
                  ),
                  _buildProximityTag(beacon.proximity, proximityColor),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'UUID: ${beacon.uuid}',
                style: TextStyle(color: Colors.grey, fontSize: SizeConfig.widthPercentage(2.5)),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  _buildSubInfo('MAJOR ID', beacon.major.toString()),
                  const SizedBox(width: 30),
                  _buildSubInfo('MINOR ID', beacon.minor.toString()),
                ],
              ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'DISTANCE',
                  style: TextStyle(color: Colors.grey, fontSize: SizeConfig.widthPercentage(2.5), fontWeight: FontWeight.bold),
                ),
                Text(
                  '${beacon.accuracy.toStringAsFixed(1)} m',
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: SizeConfig.widthPercentage(5),
                  ),
                ),
                const SizedBox(height: 5),
                Icon(Icons.location_on, color: proximityColor, size: 18),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProximityTag(String proximity, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        proximity.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSubInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: SizeConfig.widthPercentage(3.5)),
        ),
      ],
    );
  }

  Color _getProximityColor(String proximity) {
    switch (proximity.toLowerCase()) {
      case 'immediate':
        return Colors.redAccent;
      case 'near':
        return Colors.orangeAccent;
      case 'far':
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
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
