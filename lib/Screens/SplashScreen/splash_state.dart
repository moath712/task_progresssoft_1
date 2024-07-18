import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashLoaded extends SplashState {
  final bool isLoggedIn;

  SplashLoaded({required this.isLoggedIn});

  @override
  List<Object> get props => [isLoggedIn];
}

class SplashError extends SplashState {
  final String message;

  SplashError({required this.message});

  @override
  List<Object> get props => [message];
}
