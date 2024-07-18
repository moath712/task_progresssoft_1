import 'package:flutter_bloc/flutter_bloc.dart';
import 'post_event.dart';
import 'post_state.dart';
import 'package:task_progresssoft/Screens/PostScreen/post_repository.dart'; // Import your repository

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository postRepository;

  PostBloc({required this.postRepository}) : super(PostInitial()) {
    on<FetchPosts>(_onFetchPosts);
    on<FilterPosts>(_onFilterPosts);
  }

  void _onFetchPosts(FetchPosts event, Emitter<PostState> emit) async {
    emit(PostLoading());
    try {
      final posts = await postRepository.fetchPosts();
      emit(PostLoaded(posts: posts));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  void _onFilterPosts(FilterPosts event, Emitter<PostState> emit) async {
    if (state is PostLoaded) {
      final filteredPosts = (state as PostLoaded).posts.where((post) {
        return post.title.contains(event.query) || post.body.contains(event.query);
      }).toList();
      emit(PostLoaded(posts: filteredPosts));
    }
  }
}
