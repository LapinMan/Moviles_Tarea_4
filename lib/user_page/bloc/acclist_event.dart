part of 'acclist_bloc.dart';

abstract class AcclistEvent extends Equatable {
  const AcclistEvent();

  @override
  List<Object?> get props => [];
}

class ListUpdateEvent extends AcclistEvent {}
