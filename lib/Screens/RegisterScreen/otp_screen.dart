import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:task_progresssoft/Screens/LoginScreen/login_screen.dart';
import 'register_bloc.dart';
import 'register_event.dart';
import 'register_state.dart';


class OTPScreen extends StatefulWidget {
  final String verificationId;
  final String mobileNumber;
  final String fullName;
  final int age;
  final String gender;
  final String password;

  OTPScreen({
    required this.verificationId,
    required this.mobileNumber,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.password,
  });

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              decoration: const InputDecoration(labelText: 'Enter OTP'),
              keyboardType: TextInputType.number,
            ),
            isLoading
                ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const CircularProgressIndicator(),
                )
                : ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        PhoneAuthCredential credential = PhoneAuthProvider.credential(
                          verificationId: widget.verificationId,
                          smsCode: otpController.text,
                        );

                        await _auth.signInWithCredential(credential);

                        // Access the RegisterBloc correctly
                        final registerBloc = BlocProvider.of<RegisterBloc>(context);

                        registerBloc.add(
                          RegisterButtonPressed(
                            mobileNumber: widget.mobileNumber,
                            fullName: widget.fullName,
                            age: widget.age,
                            gender: widget.gender,
                            password: widget.password,
                          ),
                        );

                        // Listen to the RegisterBloc state to handle registration success/failure
                        registerBloc.stream.listen((state) {
                          if (state is RegisterSuccess) {
                            setState(() {
                              isLoading = false;
                            });
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                              (Route<dynamic> route) => false,
                            );
                          } else if (state is RegisterFailure) {
                            setState(() {
                              isLoading = false;
                            });
                            _showErrorDialog(context, state.error);
                          }
                        });
                      } on FirebaseAuthException catch (e) {
                        setState(() {
                          isLoading = false;
                        });
                        _showErrorDialog(context, e.message ?? 'OTP verification failed.');
                      }
                    },
                    child: const Text('Verify OTP'),
                  ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
