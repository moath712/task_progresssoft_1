import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  RegisterBloc({required FirebaseAuth firebaseAuth, required FirebaseFirestore firestore})
      : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        super(RegisterInitial()) {
    on<RegisterButtonPressed>(_onRegisterButtonPressed);
  }

  Future<void> _onRegisterButtonPressed(RegisterButtonPressed event, Emitter<RegisterState> emit) async {
    emit(RegisterLoading());
    try {
      // Assuming OTP verification is done
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: '${event.mobileNumber}@example.com', // Using mobile number as email
        password: event.password,
      );

      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'uid': userCredential.user?.uid, // Save the user's UID
        'mobile':event.mobileNumber,
        'fullName': event.fullName,
        'mobileNumber': event.mobileNumber,
        'age': event.age,
        'gender': event.gender,
      });

      emit(RegisterSuccess());
    } on FirebaseAuthException catch (e) {
      emit(RegisterFailure(error: e.message ?? 'Registration failed'));
    }
  }
}
