import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  SplashBloc({required this.firestore, required this.firebaseAuth}) : super(SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
  }

  Future<void> _onSplashStarted(SplashStarted event, Emitter<SplashState> emit) async {
    emit(SplashLoading());
    try {
      // Load system configuration from Firestore
      DocumentSnapshot configDoc = await firestore.collection('config').doc('system').get();
      if (configDoc.exists) {
        Map<String, dynamic> config = configDoc.data() as Map<String, dynamic>;

        // Save configuration locally
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('mobile_regex', config['mobile_regex']);
        await prefs.setString('password_regex', config['password_regex']);
        // Add additional configuration as needed

        // Load user credentials
        String? mobile = prefs.getString('mobile');
        String? password = prefs.getString('password');

        // Simulate delay for splash screen
        await Future.delayed(Duration(seconds: 2));

        // If credentials exist, try to sign in
        if (mobile != null && password != null) {
          try {
            await firebaseAuth.signInWithEmailAndPassword(
              email: '${mobile}@example.com', // Adjust this if needed
              password: password,
            );
            emit(SplashLoaded(isLoggedIn: true));
          } catch (e) {
            // Clear invalid credentials
            await prefs.remove('mobile');
            await prefs.remove('password');
            emit(SplashLoaded(isLoggedIn: false));
          }
        } else {
          
          emit(SplashLoaded(isLoggedIn: false));
        }
      } else {
         emit(SplashLoaded(isLoggedIn: false));
        emit(SplashError(message: 'Configuration not found.'));
      }
    } catch (e) {
      emit(SplashError(message: e.toString()));
    }
  }
}
