import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:blicq/core/common/beacon/ibeacon_service.dart';

part 'beacon_event.dart';
part 'beacon_state.dart';

class BeaconBloc extends Bloc<BeaconEvent, BeaconState> {
  final IBeaconService _beaconService;
  StreamSubscription? _beaconSubscription;

  final Map<String, DateTime> _lastSeenTimes = {};
  final List<BeaconModel> _detectedBeacons = [];
  final Duration _persistenceTimeout = const Duration(seconds: 10);

  BeaconBloc(this._beaconService) : super(BeaconInitial()) {
    on<BeaconStarted>(_onStarted);
    on<BeaconStopped>(_onStopped);
    on<BeaconUpdated>(_onUpdated);
    on<BeaconCheckBluetooth>(_onCheckBluetooth);
  }

  Future<void> _onStarted(BeaconStarted event, Emitter<BeaconState> emit) async {
    emit(BeaconLoading());
    
    final isBluetoothEnabled = await _beaconService.isBluetoothEnabled();
    if (!isBluetoothEnabled) {
      emit(BeaconScanning(
        detectedBeacons: [],
        strongestRSSI: -100,
        bluetoothEnabled: false,
      ));
    }

    _beaconSubscription?.cancel();
    _beaconSubscription = _beaconService.startScanning().listen((newBeacons) {
      add(BeaconUpdated(newBeacons));
    });
  }

  void _onStopped(BeaconStopped event, Emitter<BeaconState> emit) {
    _beaconSubscription?.cancel();
    _beaconService.stopScanning();
    _detectedBeacons.clear();
    _lastSeenTimes.clear();
    emit(BeaconInitial());
  }

  void _onUpdated(BeaconUpdated event, Emitter<BeaconState> emit) {
    final now = DateTime.now();
    
    // Update last seen times and sync list
    for (final beacon in event.beacons) {
      final key = '${beacon.uuid}_${beacon.major}_${beacon.minor}';
      _lastSeenTimes[key] = now;
      
      final index = _detectedBeacons.indexWhere(
        (e) => '${e.uuid}_${e.major}_${e.minor}' == key,
      );
      
      if (index != -1) {
        _detectedBeacons[index] = beacon;
      } else {
        _detectedBeacons.add(beacon);
      }
    }

    // Remove stale beacons
    _detectedBeacons.removeWhere((beacon) {
      final key = '${beacon.uuid}_${beacon.major}_${beacon.minor}';
      final lastSeen = _lastSeenTimes[key];
      return lastSeen == null || now.difference(lastSeen) > _persistenceTimeout;
    });

    int strongestRSSI = -100;
    if (_detectedBeacons.isNotEmpty) {
      strongestRSSI = _detectedBeacons
          .map((e) => e.rssi)
          .reduce((a, b) => a > b ? a : b);
    }

    emit(BeaconScanning(
      detectedBeacons: List.from(_detectedBeacons),
      strongestRSSI: strongestRSSI,
    ));
  }

  Future<void> _onCheckBluetooth(BeaconCheckBluetooth event, Emitter<BeaconState> emit) async {
    final isEnabled = await _beaconService.isBluetoothEnabled();
    if (state is BeaconScanning) {
      final currentState = state as BeaconScanning;
      emit(BeaconScanning(
        detectedBeacons: currentState.detectedBeacons,
        strongestRSSI: currentState.strongestRSSI,
        bluetoothEnabled: isEnabled,
      ));
    }
  }

  @override
  Future<void> close() {
    _beaconSubscription?.cancel();
    _beaconService.stopScanning();
    return super.close();
  }
}
