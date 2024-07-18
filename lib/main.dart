import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_progresssoft/Screens/HomeScreen/homescreen.dart';
import 'package:task_progresssoft/Screens/LoginScreen/login_screen.dart';
import 'package:task_progresssoft/Screens/PostScreen/post_event.dart';
import 'package:task_progresssoft/Screens/RegisterScreen/register_screen.dart';
import 'package:task_progresssoft/Screens/SplashScreen/splash_Screen.dart';

import 'package:task_progresssoft/Screens/RegisterScreen/register_bloc.dart';
import 'package:task_progresssoft/Screens/PostScreen/post_bloc.dart';
import 'package:task_progresssoft/Screens/PostScreen/post_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final PostRepository postRepository = PostRepository();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RegisterBloc>(
          create: (context) => RegisterBloc(
            firebaseAuth: FirebaseAuth.instance,
            firestore: FirebaseFirestore.instance,
          ),
        ),
        BlocProvider<PostBloc>(
          create: (context) => PostBloc(postRepository: postRepository)..add(FetchPosts()),
        ),
      ],
      child: MaterialApp(
        title: 'ProgressSoftTask',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SplashScreen(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => HomeScreen(),
          
        },
      ),
    );
  }
}
