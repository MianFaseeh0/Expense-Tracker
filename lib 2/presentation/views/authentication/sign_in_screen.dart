import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/asset_paths.dart';
import '../../../core/mixins/disposable_controllers_mixin.dart';
import '../../../core/mixins/form_validation_mixin.dart';
import '../../../core/mixins/loading_state_mixin.dart';
import '../../providers/auth_controller.dart';
import '../../providers/repository_providers.dart';
import '../../providers/session_providers.dart';
import '../home/home_shell_screen.dart';
import 'sign_up_screen.dart';

/// Email/password sign-in screen.
///
/// Rebuilt on top of [LoadingStateMixin], [DisposableControllersMixin] and
/// [FormValidationMixin] so the busy-flag, controller-disposal and
/// validator boilerplate that used to be hand-written here (and duplicated
/// in `sign_up.dart`) now comes for free.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen>
    with
        LoadingStateMixin<SignInScreen>,
        DisposableControllersMixin<SignInScreen>,
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
        () => ref.read(authControllerProvider).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );

      if (!mounted) return;
      ref.read(currentUserEmailProvider.notifier).state = _emailController
          .text
          .trim();
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeShellScreen()),
        (route) => false,
      );
    } catch (error) {
      errorHandler.handle(error);
    }
  }

  void _goToSignUp() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const SignUpScreen()));
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
              child: Hero(
                tag: 'hello',
                child: Lottie.asset(
                  AssetPaths.gradientAnimation,
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
                      AssetPaths.brandLogo,
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
                                  label: 'Get Started',
                                  isLoading: isBusy,
                                  onTap: _submit,
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
                        Text("Don't Have An Account?", style: GoogleFonts.spaceMono()),
                        TextButton(
                          onPressed: _goToSignUp,
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.spaceMono(
                              color: const Color.fromARGB(255, 42, 70, 255),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
        borderRadius: BorderRadius.circular(13),
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
