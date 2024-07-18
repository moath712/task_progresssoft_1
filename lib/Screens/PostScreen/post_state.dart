import 'package:equatable/equatable.dart';
import 'post_model.dart'; // Import the Post model

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object> get props => [];
}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<Post> posts;

  PostLoaded({required this.posts});

  @override
  List<Object> get props => [posts];
}

class PostError extends PostState {
  final String message;

  PostError({required this.message});

  @override
  List<Object> get props => [message];
}
