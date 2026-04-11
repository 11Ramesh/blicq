import 'dart:async';

/// A domain model for representing a Beacon, making the app agnostic of third-party implementations.
class BeaconModel {
  final String uuid;
  final int major;
  final int minor;
  final double accuracy;
  final int rssi;
  final String proximity;

  BeaconModel({
    required this.uuid,
    required this.major,
    required this.minor,
    required this.accuracy,
    required this.rssi,
    required this.proximity,
  });

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
