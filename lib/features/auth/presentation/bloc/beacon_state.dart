part of 'beacon_bloc.dart';

@immutable
sealed class BeaconState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class BeaconInitial extends BeaconState {}

final class BeaconLoading extends BeaconState {}

final class BeaconScanning extends BeaconState {
  final List<BeaconModel> detectedBeacons;
  final int strongestRSSI;
  final bool bluetoothEnabled;

  BeaconScanning({
    required this.detectedBeacons,
    required this.strongestRSSI,
    this.bluetoothEnabled = true,
  });

  @override
  List<Object?> get props => [detectedBeacons, strongestRSSI, bluetoothEnabled];
}

final class BeaconError extends BeaconState {
  final String message;
  BeaconError(this.message);

  @override
  List<Object?> get props => [message];
}
