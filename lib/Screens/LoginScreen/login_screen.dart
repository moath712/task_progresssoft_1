import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:task_progresssoft/Screens/RegisterScreen/register_screen.dart';
import 'login_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';

// ignore: must_be_immutable
class LoginScreen extends StatelessWidget {
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String mobileNumber = '';

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(
        firebaseAuth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
      ),
      child: Scaffold(
     
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
             colors: [
              Color.fromARGB(255, 239, 239, 240),
              Color.fromARGB(255, 73, 80, 85)
            ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/Logo.png',
                  height: 150,
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all( ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) {
                            mobileNumber = number.phoneNumber!;
                          },
                          selectorConfig: SelectorConfig(
                            selectorType: PhoneInputSelectorType.DROPDOWN,
                          ),
                          ignoreBlank: false,
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          selectorTextStyle: TextStyle(color: Colors.black),
                          initialValue: PhoneNumber(isoCode: 'JO'),
                          textFieldController: mobileController,
                          formatInput: false,
                          inputDecoration: InputDecoration(
                            labelText: 'Mobile Number',
                            hintText: 'Enter your mobile number',
                           
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mobile number is required.';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 20),
                      BlocConsumer<LoginBloc, LoginState>(
                        listener: (context, state) {
                          if (state is LoginSuccess) {
                            Navigator.pushReplacementNamed(context, '/home');
                          } else if (state is LoginFailure) {
                            if (state.error == 'User not registered.') {
                              _showRegisterDialog(context);
                            } else {
                              _showErrorDialog(context, state.error);
                            }
                          }
                        },
                        builder: (context, state) {
                          if (state is LoginLoading) {
                            return CircularProgressIndicator();
                          }
                          return ElevatedButton(
                            onPressed: () {
                              if (_validateInputs(context)) {
                                BlocProvider.of<LoginBloc>(context).add(
                                  LoginButtonPressed(
                                    mobileNumber: mobileNumber,
                                    password: passwordController.text,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 19, 5, 71),
                              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: Text('Login', style: TextStyle(fontSize: 18,color: Colors.white)),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Register',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Color.fromARGB(255, 24, 2, 77),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateInputs(BuildContext context) {
    final mobilePattern = RegExp(r'^\+?[1-9]\d{1,14}$'); // E.164 format
    final passwordPattern = RegExp(r'^[a-zA-Z0-9]{6,}$');

    if (!mobilePattern.hasMatch(mobileNumber)) {
      _showErrorDialog(context, 'Invalid mobile number.');
      return false;
    }

    if (!passwordPattern.hasMatch(passwordController.text)) {
      _showErrorDialog(context, 'Password must be at least 6 characters.');
      return false;
    }

    return true;
  }

  void _showRegisterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('User not registered'),
          content: Text('The user is not registered. Would you like to register?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/register');
              },
              child: Text('Register'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
