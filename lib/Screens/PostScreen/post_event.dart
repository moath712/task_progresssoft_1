import 'package:equatable/equatable.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object> get props => [];
}

class FetchPosts extends PostEvent {}

class FilterPosts extends PostEvent {
  final String query;

  FilterPosts(this.query);

  @override
  List<Object> get props => [query];
}
