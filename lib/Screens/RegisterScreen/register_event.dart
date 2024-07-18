import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class RegisterButtonPressed extends RegisterEvent {
  final String mobileNumber;
  final String fullName;
  final int age;
  final String gender;
  final String password;

  RegisterButtonPressed({
    required this.mobileNumber,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.password,
  });

  @override
  List<Object> get props => [mobileNumber, fullName, age, gender, password];
}
