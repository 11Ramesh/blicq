part of 'beacon_bloc.dart';

@immutable
sealed class BeaconEvent {}

final class BeaconStarted extends BeaconEvent {}

final class BeaconStopped extends BeaconEvent {}

final class BeaconUpdated extends BeaconEvent {
  final List<BeaconModel> beacons;
  BeaconUpdated(this.beacons);
}

final class BeaconCheckBluetooth extends BeaconEvent {}
