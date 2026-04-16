import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blicq/core/common/beacon/ibeacon_service.dart';

part 'setup_event.dart';
part 'setup_state.dart';

class SetupBloc extends Bloc<SetupEvent, SetupState> {
  final IBeaconService _beaconService;
  final SharedPreferences _sharedPreferences;

  SetupBloc({
    required IBeaconService beaconService,
    required SharedPreferences sharedPreferences,
  })  : _beaconService = beaconService,
        _sharedPreferences = sharedPreferences,
        super(SetupInitial()) {
    on<SetupStatusChecked>(_onStatusChecked);
    on<SetupPermissionsRequested>(_onPermissionsRequested);
  }

  Future<void> _onStatusChecked(SetupStatusChecked event, Emitter<SetupState> emit) async {
    emit(SetupLoading());
    final isLocationEnabled = await _beaconService.checkPermissions();
    final isBluetoothEnabled = await _beaconService.isBluetoothEnabled();
    emit(SetupPermissionsStatus(
      isLocationEnabled: isLocationEnabled,
      isBluetoothEnabled: isBluetoothEnabled,
    ));
  }

  Future<void> _onPermissionsRequested(SetupPermissionsRequested event, Emitter<SetupState> emit) async {
    await _beaconService.requestPermissions();
    final isLocationEnabled = await _beaconService.checkPermissions();
    final isBluetoothEnabled = await _beaconService.isBluetoothEnabled();
    
    if (isLocationEnabled && isBluetoothEnabled) {
      await _sharedPreferences.setBool('setup_completed', true);
      emit(SetupSuccess());
    } else {
      emit(SetupPermissionsStatus(
        isLocationEnabled: isLocationEnabled,
        isBluetoothEnabled: isBluetoothEnabled,
      ));
      emit(SetupFailure('Please grant all permissions to continue'));
    }
  }
}
