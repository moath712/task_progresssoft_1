import 'package:http/http.dart' as http;
import 'dart:convert';
import 'post_model.dart'; // Import the Post model

class PostRepository {
  Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));

    if (response.statusCode == 200) {
      final List<dynamic> postJson = json.decode(response.body);
      return postJson.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
}
