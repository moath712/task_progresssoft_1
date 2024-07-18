import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'splash_bloc.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashBloc(
        firestore: FirebaseFirestore.instance,
        firebaseAuth: FirebaseAuth.instance,
      )..add(SplashStarted()),
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashLoaded) {
            if (state.isLoggedIn) {
              Navigator.pushReplacementNamed(context, '/home'); // Navigate to home screen
            } else {
              Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen
            }
          } else if (state is SplashError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: Image.asset('assets/images/Logo.png'), // Replace with your logo path
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '© 2024 ProgressSoft',
                    style: TextStyle(fontSize: 14.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
