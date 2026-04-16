part of 'setup_bloc.dart';

@immutable
sealed class SetupEvent {}

final class SetupStatusChecked extends SetupEvent {}

final class SetupPermissionsRequested extends SetupEvent {}
