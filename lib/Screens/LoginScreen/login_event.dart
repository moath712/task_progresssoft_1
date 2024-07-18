import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginButtonPressed extends LoginEvent {
  final String mobileNumber;
  final String password;

  LoginButtonPressed({required this.mobileNumber, required this.password});

  @override
  List<Object> get props => [mobileNumber, password];
}
