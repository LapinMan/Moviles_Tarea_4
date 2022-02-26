part of 'acclist_bloc.dart';

abstract class AcclistState extends Equatable {
  const AcclistState();

  @override
  List<Object?> get props => [];
}

class AcclistInitial extends AcclistState {}

class AcclistErrorState extends AcclistState {
  final String errorMsg;

  AcclistErrorState({required this.errorMsg});
  @override
  List<String?> get props => [errorMsg];
}

class AcclistSuccessState extends AcclistState {
  var data;

  AcclistSuccessState({required this.data});
  @override
  List<Object?> get props => [data];
}
