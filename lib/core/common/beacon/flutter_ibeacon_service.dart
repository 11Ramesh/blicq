import 'dart:async';
import 'dart:io';
import 'package:beacon_scanner/beacon_scanner.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ibeacon_service.dart';

/// Implementation of [IBeaconService] using the `beacon_scanner` package.
class FlutterIBeaconService implements IBeaconService {
  StreamSubscription<ScanResult>? _scanSubscription;
  StreamSubscription<MonitoringResult>? _monitoringSubscription;
  final StreamController<List<BeaconModel>> _beaconController = StreamController<List<BeaconModel>>.broadcast();
  final StreamController<MonitoringResultModel> _monitoringController = StreamController<MonitoringResultModel>.broadcast();

  @override
  Future<void> initialize() async {
    try {
      await BeaconScanner.instance.initialize();
    } catch (e) {
      print('Beacon initialization error: $e');
    }
  }

  @override
  Stream<List<BeaconModel>> startScanning() {
    stopScanning();

    const regions = <Region>[
      Region(identifier: 'AllBeacons'),
    ];

    _scanSubscription = BeaconScanner.instance.ranging(regions).listen(
      (ScanResult result) {
        final models = result.beacons.map((beacon) => BeaconModel(
          uuid: beacon.id.proximityUUID,
          major: beacon.id.majorId,
          minor: beacon.id.minorId,
          accuracy: beacon.accuracy,
          rssi: beacon.rssi,
          txPower: beacon.txPower,
          proximity: _mapProximity(beacon.proximity),
        )).toList();
        _beaconController.add(models);
      },
      onError: (error) {
        print('Scanning error: $error');
      },
    );

    return _beaconController.stream;
  }

  @override
  Future<void> stopScanning() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  @override
  Stream<MonitoringResultModel> startMonitoring() {
    stopMonitoring();

    const regions = <Region>[
      Region(identifier: 'AllBeaconsMonitor'),
    ];

    _monitoringSubscription = BeaconScanner.instance.monitoring(regions).listen(
      (MonitoringResult result) {
        _monitoringController.add(MonitoringResultModel(
          regionIdentifier: result.region.identifier,
          event: result.monitoringEventType.toString().split('.').last,
        ));
      },
      onError: (error) {
        print('Monitoring error: $error');
      },
    );

    return _monitoringController.stream;
  }

  @override
  Future<void> stopMonitoring() async {
    await _monitoringSubscription?.cancel();
    _monitoringSubscription = null;
  }

  @override
  Future<bool> checkPermissions() async {
    if (Platform.isAndroid) {
      final bluetoothScan = await Permission.bluetoothScan.status;
      final locationAlways = await Permission.locationAlways.status;
      return bluetoothScan.isGranted && locationAlways.isGranted;
    } else {
      final location = await Permission.locationAlways.status;
      final bluetooth = await Permission.bluetooth.status;
      return location.isGranted && bluetooth.isGranted;
    }
  }

  @override
  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationAlways,
        Permission.locationWhenInUse,
      ].request();
    } else {
      await [
        Permission.locationAlways,
        Permission.bluetooth,
      ].request();
    }
  }

  @override
  Future<bool> isBluetoothEnabled() async {
    final state = await BeaconScanner.instance.bluetoothState;
    return state == BluetoothState.stateOn;
  }

  @override
  Future<void> openBluetoothSettings() async {
    if (Platform.isAndroid) {
      const channel = MethodChannel('com.example.blicq/bluetooth');
      try {
        await channel.invokeMethod('enableBluetooth');
      } catch (e) {
        await openAppSettings();
      }
    } else {
      await openAppSettings();
    }
  }

  String _mapProximity(Proximity proximity) {
    switch (proximity) {
      case Proximity.immediate:
        return 'Immediate';
      case Proximity.near:
        return 'Near';
      case Proximity.far:
        return 'Far';
      case Proximity.unknown:
      default:
        return 'Unknown';
    }
  }
}
