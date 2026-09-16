import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/asset_paths.dart';
import '../../../core/mixins/disposable_controllers_mixin.dart';
import '../../../core/mixins/form_validation_mixin.dart';
import '../../../core/mixins/loading_state_mixin.dart';
import '../../providers/auth_controller.dart';
import '../../providers/repository_providers.dart';
import 'sign_in_screen.dart';

/// Email/password sign-up screen.
///
/// Rebuilt on the same [LoadingStateMixin] / [DisposableControllersMixin] /
/// [FormValidationMixin] trio as [SignInScreen], eliminating the near
/// duplicate boilerplate the two screens used to carry independently.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>
    with
        LoadingStateMixin<SignUpScreen>,
        DisposableControllersMixin<SignUpScreen>,
        FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  late final _emailController = registerController();
  late final _passwordController = registerController();

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    final errorHandler = ref.read(errorHandlerServiceProvider);

    try {
      await withLoading(
        () => ref.read(authControllerProvider).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );

      if (!mounted) return;
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
      );
      Fluttertoast.showToast(
        msg: 'Successfully signed up',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (error) {
      errorHandler.handle(error);
    }
  }

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
              alignment: Alignment.topCenter,
              child: Hero(
                tag: 'hello',
                child: Lottie.asset(AssetPaths.gradientAnimation),
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
                        'Sign Up!',
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
                                _AuthTextField(
                                  controller: _emailController,
                                  hintText: 'Email',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: validateEmail,
                                ),
                                const SizedBox(height: 10),
                                _AuthTextField(
                                  controller: _passwordController,
                                  hintText: 'Password',
                                  obscureText: true,
                                  validator: validatePassword,
                                ),
                                const SizedBox(height: 20),
                                _SubmitButton(
                                  label: 'Sign Up',
                                  isLoading: isBusy,
                                  onTap: _submit,
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
                                MaterialPageRoute(
                                  builder: (_) => const SignInScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.spaceMono(
                                color: const Color.fromARGB(255, 42, 70, 255),
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
          ],
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.hintText,
    required this.validator,
    this.obscureText = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 69,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.labelSmall,
          ),
          validator: validator,
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.grey,
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black,
        ),
        clipBehavior: Clip.hardEdge,
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: GoogleFonts.spaceMono(color: Colors.white),
                ),
        ),
      ),
    );
  }
}
