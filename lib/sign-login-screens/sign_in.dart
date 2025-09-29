import 'dart:ui';

import 'package:email_validator/email_validator.dart';
import 'package:expensetracker/provider/name_provider.dart';
import 'package:expensetracker/screens/TabScreen.dart';
import 'package:expensetracker/sign-login-screens/sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SignIn extends ConsumerStatefulWidget {
  const SignIn({super.key});

  @override
  ConsumerState<SignIn> createState() => _SignInState();
}

class _SignInState extends ConsumerState<SignIn> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  Future<void> _gotoHome() async {
    FocusScope.of(context).unfocus();

    try {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
        });
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
        });

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (ctx) => TabScreen()),
          (Route<dynamic> route) => false,
        );
        ref.read(stringProvider.notifier).state = _emailController.text.trim();
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });

      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        msg: e.message ?? 'An error occurred',
      );
    }
  }

  void _gotosignUp() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (ctx) => SignUp()));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // void _gotosignUp() {
  //   Navigator.push(context, MaterialPageRoute(builder: (ctx) => Signup()));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: SizedBox(
        height: 900,
        width: double.infinity,
        child: Stack(
          children: [
            Align(
              child: Hero(
                tag: 'hello',
                child: Lottie.asset(
                  'assets/json/gradient.json',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),

            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Image.asset(
                      'assets/bwink_bld_03_single_03-removebg-preview.png',
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                    Text(
                      "Welcome Back You've\nBeen Missed",
                      style: GoogleFonts.spaceMono(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
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

                                  onTap: _gotoHome,
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
                                        'Get Started',
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
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Dont Have An Account?',
                          style: GoogleFonts.spaceMono(),
                        ),
                        TextButton(
                          onPressed: _gotosignUp,
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.spaceMono(
                              color: Color.fromARGB(255, 42, 70, 255),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
