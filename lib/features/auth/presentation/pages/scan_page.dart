import 'package:flutter/material.dart';
import 'package:blicq/core/constants/size_config.dart';
import 'package:blicq/core/utils/theme.dart';
import 'package:blicq/core/common/beacon/ibeacon_service.dart';
import 'package:blicq/core/common/widgets/stat_card_widget.dart';
import 'package:blicq/core/common/widgets/text_widget.dart';
import 'package:blicq/core/common/widgets/sub_text_widget.dart';

class ScanPage extends StatelessWidget {
  final List<BeaconModel> detectedBeacons;
  final int strongestRSSI;
  final VoidCallback onRefresh;

  const ScanPage({
    super.key,
    required this.detectedBeacons,
    required this.strongestRSSI,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.widthPercentage(5),
        ),
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
          const SubTextWidget(
            text:
                'Actively monitoring Bluetooth Low Energy signals in your immediate perimeter.',
          ),
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
            value: detectedBeacons.length.toString(),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: StatCardWidget(
            label: 'STRONGEST RSSI',
            value: '$strongestRSSI dBm',
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
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('REFRESH'),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primaryBlue,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBeaconsList() {
    if (detectedBeacons.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Icon(
                Icons.bluetooth_searching,
                size: 50,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 10),
              Text(
                'No beacons detected nearby',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: detectedBeacons.length,
      separatorBuilder: (_, __) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        return _buildBeaconCard(detectedBeacons[index]);
      },
    );
  }

  Widget _buildBeaconCard(BeaconModel beacon) {
    final bool isCritical = beacon.estimatedDistance <= 5.0;
    final proximityColor = _getProximityColor(beacon.proximity);
    const goldenColor = Color(0xFFEBB54A);
    const criticalBg = Color(0xFFFEF7E6);
    const criticalText = Color(0xFF7D5700);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            // Left Accent Bar
            Container(
              width: 6,
              height: 120,
              color: isCritical ? goldenColor : Colors.grey[300],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${beacon.uuid.substring(0, 8)}...',
                                style: TextStyle(
                                  color: AppTheme.textDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: SizeConfig.widthPercentage(4.5),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isCritical
                                    ? 'UUID: ${beacon.uuid.substring(0, 20)}...'
                                    : 'UUID: ${beacon.uuid}',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: SizeConfig.widthPercentage(2.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (isCritical)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: criticalBg,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'CRITICAL',
                                  style: TextStyle(
                                    color: criticalText,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 8,
                                  ),
                                ),
                                Text(
                                  'PROXIMITY',
                                  style: TextStyle(
                                    color: criticalText,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'DISTANCE',
                              style: TextStyle(
                                color: criticalText,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  beacon.estimatedDistance.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: goldenColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: SizeConfig.widthPercentage(6),
                                  ),
                                ),
                                const SizedBox(width: 1),
                                Text(
                                  'm',
                                  style: TextStyle(
                                    color: goldenColor,
                                    fontSize: SizeConfig.widthPercentage(3),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _buildSubInfo('MAJOR ID', beacon.major.toString()),
                            const SizedBox(width: 20),
                            _buildSubInfo('MINOR ID', beacon.minor.toString()),
                          ],
                        ),
                        Icon(
                          Icons.location_on,
                          color: isCritical ? goldenColor : proximityColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
          style: TextStyle(
            color: Colors.grey,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: SizeConfig.widthPercentage(3.5),
          ),
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
