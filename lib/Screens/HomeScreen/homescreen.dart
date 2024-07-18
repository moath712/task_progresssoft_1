import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_progresssoft/Screens/PostScreen/post_bloc.dart';
import 'package:task_progresssoft/Screens/PostScreen/post_event.dart';
import 'package:task_progresssoft/Screens/PostScreen/post_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    context.read<PostBloc>().add(FetchPosts());
    _fetchUserData();
  }

  void _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
           backgroundColor: const Color.fromARGB(255, 19, 5, 71),
        title: Text('Home',
          style: TextStyle(
            color: Color.fromARGB(255, 247, 247, 248),
          ),),
      ),
      body: _selectedIndex == 0 ? _buildPosts() : _buildProfile(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildPosts() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Posts',
              border: OutlineInputBorder(),
            ),
            onChanged: (query) {
              context.read<PostBloc>().add(FilterPosts(query));
            },
          ),
        ),
        Expanded(
          child: BlocBuilder<PostBloc, PostState>(
            builder: (context, state) {
              if (state is PostLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is PostLoaded) {
                return ListView.builder(
                  itemCount: state.posts.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(state.posts[index].title),
                      subtitle: Text(state.posts[index].body),
                    );
                  },
                );
              } else if (state is PostError) {
                return Center(child: Text(state.message));
              } else {
                return Center(child: Text('No posts available'));
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfile() {
    if (_userData == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Card(
        margin: EdgeInsets.all(16.0),
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 50),
              ),
              SizedBox(height: 20),
              Text(
                'Full Name: ${_userData!['fullName'] ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Mobile Number: ${_userData!['mobileNumber'] ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Age: ${_userData!['age'] ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Gender: ${_userData!['gender'] ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
