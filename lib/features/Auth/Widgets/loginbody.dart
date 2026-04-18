import 'package:elbess_store/core/constants/button.dart';
import 'package:elbess_store/core/constants/colors.dart';
import 'package:elbess_store/core/constants/textfield.dart';
import 'package:elbess_store/core/utils/size_config.dart';
import 'package:elbess_store/features/Auth/Presentation/Pages/signup_view.dart';
import 'package:elbess_store/features/Auth/data/auth_repo.dart';
import 'package:elbess_store/root.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Loginbody extends StatefulWidget {
  const Loginbody({super.key});

  @override
  State<Loginbody> createState() => _LoginbodyState();
}

class _LoginbodyState extends State<Loginbody> {
  final _formKey = GlobalKey<FormState>();
  final _authRepo = AuthRepo();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authRepo.login(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const Root(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('ApiError: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sh = SizeConfig.screenHeight!;
    final sw = SizeConfig.screenWidth!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(sh * 0.02),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 24,
                      color: Color(0xFF9A9A9A),
                    ),
                  ),
                ),
                Gap(sh * 0.05),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Login to your',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: sw * 0.085,
                          fontFamily: 'semi',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Store',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: sw * 0.085,
                          fontFamily: 'semi',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(sh * 0.03),
                CustomTextField(
                  title: 'Email',
                  hinttext: 'enter your email',
                  prefixIcon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => _required(value, 'Email'),
                ),
                Gap(sh * 0.02),
                CustomTextField(
                  title: 'Password',
                  hinttext: 'enter your password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) => _required(value, 'Password'),
                ),
                Gap(sh * 0.04),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.025),
                  child: CustomButton(
                    text: _isLoading ? 'Logging in...' : 'Log in',
                    onPressed: () {
                      if (_isLoading) {
                        return;
                      }
                      _submitLogin();
                    },
                  ),
                ),
                Gap(sh * 0.04),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Color(0xFFD4D4D4),
                        thickness: 1,
                      ),
                    ),
                    Gap(12),
                    Text(
                      'Or',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'semi',
                      ),
                    ),
                    Gap(12),
                    Expanded(
                      child: Divider(
                        color: Color(0xFFD4D4D4),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                Gap(sh * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(fontSize: sw * 0.03, fontFamily: 'medium', color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const SignupView(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return SlideTransition(
                                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                                    .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 400),
                          ),
                        );
                      },
                      child: Text(
                        'Sign up',
                        style: TextStyle(fontSize: sw * 0.03, fontFamily: 'semi', color: AppColors.primary),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}
