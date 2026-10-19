import 'dart:async';

import 'package:equatable/equatable.dart';

abstract class CustomSessionGetterEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CustomSessionGetterStateReset extends CustomSessionGetterEvent {}

class CustomSessionGetterPageFetched extends CustomSessionGetterEvent {}

class CustomSessionGetterRefresh extends CustomSessionGetterEvent {
  final Completer<void>? completer;

  CustomSessionGetterRefresh({required this.completer});

  @override
  List<Object?> get props => [completer];
}

class CustomSessionGetterReset extends CustomSessionGetterEvent {
  final String sessionId;

  CustomSessionGetterReset({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class CustomSessionGetterDelete extends CustomSessionGetterEvent {
  final String sessionId;

  CustomSessionGetterDelete({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class CustomSessionGetterRename extends CustomSessionGetterEvent {
  final String sessionId;
  final String name;

  CustomSessionGetterRename({required this.sessionId, required this.name});

  @override
  List<Object?> get props => [sessionId, name];
}
