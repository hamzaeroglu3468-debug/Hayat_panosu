import 'package:equatable/equatable.dart';
import '../models/countdown_model.dart';

abstract class CountdownEvent extends Equatable {
  const CountdownEvent();

  @override
  List<Object?> get props => [];
}

class LoadCountdownsEvent extends CountdownEvent {}

class AddCountdownEvent extends CountdownEvent {
  final CountdownModel countdown;
  const AddCountdownEvent(this.countdown);

  @override
  List<Object?> get props => [countdown];
}

class DeleteCountdownEvent extends CountdownEvent {
  final String countdownId;
  const DeleteCountdownEvent(this.countdownId);

  @override
  List<Object?> get props => [countdownId];
}
