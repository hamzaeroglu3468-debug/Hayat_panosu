import 'package:equatable/equatable.dart';
import '../models/countdown_model.dart';

abstract class CountdownState extends Equatable {
  const CountdownState();

  @override
  List<Object?> get props => [];
}

class CountdownInitialState extends CountdownState {}

class CountdownLoadingState extends CountdownState {}

class CountdownLoadedState extends CountdownState {
  final List<CountdownModel> countdowns;

  const CountdownLoadedState(this.countdowns);

  // Return upcoming countdowns sorted by days remaining
  List<CountdownModel> get upcomingCountdowns {
    final list = [...countdowns];
    list.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    return list;
  }

  @override
  List<Object?> get props => [countdowns];
}

class CountdownErrorState extends CountdownState {
  final String message;
  const CountdownErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
