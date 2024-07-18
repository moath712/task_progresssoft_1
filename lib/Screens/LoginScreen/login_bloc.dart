import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  LoginBloc({required this.firebaseAuth, required this.firestore}) : super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }

  Future<void> _onLoginButtonPressed(LoginButtonPressed event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      // Fetch the user's UID based on the mobile number
      QuerySnapshot querySnapshot = await firestore
          .collection('users')
          .where('mobile', isEqualTo: event.mobileNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // User found, proceed to sign in
       

        // Attempt to sign in with the UID
        UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(
          email: '${event.mobileNumber}@example.com', // Using mobile number as email
          password: event.password,
        );

        DocumentSnapshot userDoc = await firestore.collection('users').doc(userCredential.user?.uid).get();
        if (userDoc.exists) {
          // Save credentials to shared preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('mobile', event.mobileNumber);
          await prefs.setString('password', event.password);

          emit(LoginSuccess());
        } else {
          emit(LoginFailure(error: 'User not registered.'));
        }
      } else {
        emit(LoginFailure(error: 'User not registered.'));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(LoginFailure(error: 'User not registered.'));
      } else if (e.code == 'wrong-password') {
        emit(LoginFailure(error: 'Incorrect password.'));
      } else {
        emit(LoginFailure(error: 'Login failed. Please try again.'));
      }
    } catch (e) {
      emit(LoginFailure(error: 'An unknown error occurred.'));
    }
  }
}
