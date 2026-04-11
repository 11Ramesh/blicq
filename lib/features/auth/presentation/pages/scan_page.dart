import 'dart:async';
import 'package:flutter/material.dart';
import 'package:blicq/core/constants/size_config.dart';
import 'package:blicq/core/utils/theme.dart';
import 'package:blicq/core/common/beacon/ibeacon_service.dart';
import 'package:blicq/init_dependencies.dart';
import 'package:blicq/core/common/widgets/stat_card_widget.dart';
import 'package:blicq/core/common/widgets/text_widget.dart';
import 'package:blicq/core/common/widgets/sub_text_widget.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final IBeaconService _beaconService = serviceLocator<IBeaconService>();
  StreamSubscription? _beaconSubscription;
  final List<BeaconModel> _detectedBeacons = [];
  int _strongestRSSI = -100;

  final Map<String, DateTime> _lastSeenTimes = {};
  final Duration _persistenceTimeout = const Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _startScanning();
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

  @override
  void dispose() {
    _beaconSubscription?.cancel();
    _beaconService.stopScanning();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            SizedBox(height: SizeConfig.heightPercentage(10)),
          ],
        ),
      ),
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
          const SubTextWidget(text: 'STATUS: ACTIVE'),
          const SizedBox(height: 5),
          const TextWidget(text: 'Precision Scanning'),
          SizedBox(height: SizeConfig.heightPercentage(1)),
          const SubTextWidget(text: 'Actively monitoring Bluetooth Low Energy signals in your immediate perimeter.'),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: StatCardWidget(
            label: 'ACTIVE NODES',
            value: _detectedBeacons.length.toString(),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: StatCardWidget(
            label: 'STRONGEST RSSI',
            value: '$_strongestRSSI dBm',
            backgroundColor: AppTheme.primaryBlue,
            textColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBeaconsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            TextWidget(text: 'Detected Beacons'),
            SubTextWidget(text: 'Nearby localized identifiers'),
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
}
