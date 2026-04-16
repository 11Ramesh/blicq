import 'dart:async';
import 'dart:math';

/// A domain model for representing a Beacon, making the app agnostic of third-party implementations.
class BeaconModel {
  final String uuid;
  final int major;
  final int minor;
  final double accuracy;
  final int rssi;
  final int? txPower;
  final String proximity;

  BeaconModel({
    required this.uuid,
    required this.major,
    required this.minor,
    required this.accuracy,
    required this.rssi,
    required this.proximity,
    this.txPower,
  });


  double get estimatedDistance {
    if (txPower == null || txPower == 0) return accuracy;
    
    final double ratio = rssi.toDouble() / txPower!.toDouble();
    double distance;
    
    if (ratio < 1.0) {
      distance = pow(ratio, 10).toDouble();
    } else {
      distance = (0.89976) * pow(ratio, 7.7095) + 0.111;
    }
    
    return double.parse(distance.toStringAsFixed(2));
  }

  @override
  String toString() {
    return 'Beacon(uuid: $uuid, major: $major, minor: $minor, accuracy: $accuracy, rssi: $rssi)';
  }
}

/// Abstract interface for iBeacon scanning functionality.
abstract class IBeaconService {
  /// Initializes the beacon scanning service.
  Future<void> initialize();

  /// Starts scanning for iBeacons and returns a stream of discovered beacons.
  Stream<List<BeaconModel>> startScanning();

  /// Stops the current beacon scanning process.
  Future<void> stopScanning();

  /// Starts monitoring specific regions for background entry/exit events.
  Stream<MonitoringResultModel> startMonitoring();

  /// Stops monitoring regions.
  Future<void> stopMonitoring();

  /// Checks if all necessary permissions (Bluetooth, Location) are granted.
  Future<bool> checkPermissions();

  /// Requests the necessary permissions for scanning.
  Future<void> requestPermissions();

  /// Returns true if Bluetooth is enabled and available for scanning.
  Future<bool> isBluetoothEnabled();

  /// Opens the device settings to enable Bluetooth.
  Future<void> openBluetoothSettings();
}

/// A model representing a monitoring event (entry/exit).
class MonitoringResultModel {
  final String regionIdentifier;
  final String event; // 'Entry' or 'Exit'

  MonitoringResultModel({
    required this.regionIdentifier,
    required this.event,
  });
}
