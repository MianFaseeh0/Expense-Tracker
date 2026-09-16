import 'dart:ui';

import 'package:email_validator/email_validator.dart';
import 'package:expensetracker/sign-login-screens/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _gotoLogin() async {
    try {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
        });
        final response = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        print(response);
        if (!mounted) {
          return;
        }
        setState(() {
          _isLoading = false;
        });
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (ctx) => SignIn()));

        Fluttertoast.showToast(
          msg: "Successfuly Signed Up",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: e.message ?? 'An error occurred',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: SizedBox(
        height: 900,
        width: double.infinity,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Hero(
                tag: 'hello',
                child: Lottie.asset('assets/json/gradient.json'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 150),

                      Text(
                        "Sign Up!",
                        style: GoogleFonts.spaceMono(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            width: double.infinity,
                            height: 280,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                60,
                                118,
                                118,
                                118,
                              ).withValues(alpha: .5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 69,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(13),
                                    border: Border.all(color: Colors.white),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        hintText: 'Email',
                                        hintStyle: Theme.of(
                                          context,
                                        ).textTheme.labelSmall,
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty ||
                                            !EmailValidator.validate(value)) {
                                          return 'Enter a valid Email';
                                        }

                                        return null;
                                      },
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white),
                                  ),
                                  height: 69,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      obscureText: true,
                                      controller: _passwordController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        hintText: 'Password',
                                        hintStyle: Theme.of(
                                          context,
                                        ).textTheme.labelSmall,
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty ||
                                            value.trim().length <= 6) {
                                          return 'Enter a password greater than 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                InkWell(
                                  splashColor: Colors.grey,
                                  onTap: () async {
                                    await _gotoLogin();
                                  },
                                  child: Container(
                                    height: 50,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: Center(
                                      child: Text(
                                        'Sign Up',
                                        style: GoogleFonts.spaceMono(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already Have An Account?',
                            style: GoogleFonts.spaceMono(),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (ctx) => SignIn()),
                              );
                            },
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.spaceMono(
                                color: Color.fromARGB(255, 42, 70, 255),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(95, 0, 0, 0),
                ),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
