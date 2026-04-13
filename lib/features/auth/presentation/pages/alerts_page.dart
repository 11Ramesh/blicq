import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blicq/core/constants/size_config.dart';
import 'package:blicq/core/utils/theme.dart';
import 'package:blicq/core/common/models/alert_model.dart';
import 'package:blicq/core/common/widgets/stat_card_widget.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  List<AlertModel> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    try {
      final String response = await rootBundle.loadString('assets/data.json');
      final Map<String, dynamic> data = json.decode(response);
      final List alertsData = data['alerts'];
      setState(() {
        _alerts = alertsData.map((e) => AlertModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading alerts: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.widthPercentage(5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: SizeConfig.heightPercentage(2)),
              _buildStatsRow(),
              SizedBox(height: SizeConfig.heightPercentage(3)),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _alerts.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  return _buildAlertCard(_alerts[index]);
                },
              ),
              SizedBox(height: SizeConfig.heightPercentage(10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        const Expanded(
          child: StatCardWidget(
            label: 'ACTIVE SCANS',
            value: '12',
            indicatorColor: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: StatCardWidget(
            label: 'NEARBY BEACONS',
            value: '04',
            backgroundColor: Colors.white,
            textColor: AppTheme.textDark,
            indicatorColor: Colors.amber[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAlertCard(AlertModel alert) {
    final Color mainColor = _getColorFromStyle(alert.style);

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
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: mainColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIcon(alert.type),
                            color: mainColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alert.type.replaceAll('_', ' '),
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                letterSpacing: 1.1,
                              ),
                            ),
                            Text(
                              alert.title,
                              style: const TextStyle(
                                color: AppTheme.textDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      alert.body,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoSection(alert),
                    const SizedBox(height: 15),
                    _buildIdentifier(alert.uuid),
                    const SizedBox(height: 20),
                    _buildActionButton(_getActionText(alert.action), mainColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(AlertModel alert) {
    String label = 'CURRENT DISTANCE';
    String value = '${alert.currentDistance}m';
    bool isCritical = false;

    if (alert.currentDistance < 0) {
      label = 'LAST SEEN';
      value = '-';
    } else if (alert.type == 'HARDWARE_ERROR') {
      label = 'STATUS';
      value = 'OFF';
      isCritical = true;
    } else if (alert.type == 'PERMISSION_DENIED') {
      label = 'PERMISSION';
      value = 'DENIED';
      isCritical = true;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSmallInfo(
            label,
            value,
            isAccent: !isCritical,
            isCritical: isCritical,
          ),
          _buildSmallInfo('Threshold', '${alert.thresholdMeters}m'),
        ],
      ),
    );
  }

  Widget _buildSmallInfo(
    String label,
    String value, {
    bool isAccent = false,
    bool isCritical = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.grey,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isCritical
                ? Colors.red
                : (isAccent ? AppTheme.primaryBlue : AppTheme.textDark),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildIdentifier(String uuid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Text(
            'UUID: ',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              uuid,
              style: const TextStyle(color: Colors.grey, fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'BACKGROUND_DETECTION':
        return Icons.radar;
      case 'PROXIMITY_THRESHOLD':
        return Icons.warning_amber_rounded;
      case 'IMMEDIATE_PROXIMITY':
        return Icons.check_circle_outline;
      case 'SIGNAL_LOST':
        return Icons.signal_cellular_connected_no_internet_4_bar;
      case 'HARDWARE_ERROR':
        return Icons.bluetooth_disabled;
      case 'PERMISSION_DENIED':
        return Icons.location_on_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  Color _getColorFromStyle(String style) {
    if (style.contains('blue')) return AppTheme.primaryBlue;
    if (style.contains('amber')) return Colors.amber[600]!;
    if (style.contains('green')) return const Color(0xFF4CAF50);
    if (style.contains('red')) return const Color(0xFFD32F2F);
    return AppTheme.primaryBlue;
  }

  String _getActionText(String action) {
    switch (action) {
      case 'navigate_to_details':
        return 'Open App';
      case 'show_welcome_message':
        return 'View Details';
      case 'auto_checkin':
        return 'Auto Check-In';
      case 'mark_as_inactive':
        return 'Retry Connection';
      case 'open_settings':
        return 'Open Settings';
      case 'request_permission':
        return 'Grant Access';
      default:
        return 'Resolve';
    }
  }
}
