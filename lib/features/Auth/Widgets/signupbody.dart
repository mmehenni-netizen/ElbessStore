import 'package:elbess_store/core/constants/button.dart';
import 'package:elbess_store/core/constants/colors.dart';
import 'package:elbess_store/core/constants/textfield.dart';
import 'package:elbess_store/core/utils/size_config.dart';
import 'package:elbess_store/features/Auth/Presentation/Pages/login_view.dart';
import 'package:elbess_store/features/Auth/data/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;

class Signupbody extends StatefulWidget {
  const Signupbody({super.key});

  @override
  State<Signupbody> createState() => _SignupbodyState();
}

class _SignupbodyState extends State<Signupbody> {
  final _formKey = GlobalKey<FormState>();
  final _authRepo = AuthRepo();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authRepo.signup(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        location: _locationController.text,
        description: _descriptionController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginView(),
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

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final sh = SizeConfig.screenHeight!;
    final sw = SizeConfig.screenWidth!;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new_outlined, size: 20),
                  ),
                  Gap(sh * 0.03),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(sw * 0.05),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F4F1),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFE7DAD2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create your store',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: sw * 0.085,
                            fontFamily: 'semi',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gap(sh * 0.01),
                        Text(
                          'All store details are required here. No extra profile step.',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.65),
                            fontSize: sw * 0.031,
                            fontFamily: 'regular',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(sh * 0.03),
                  CustomTextField(
                    title: 'Store name',
                    hinttext: 'Enter your store name',
                    prefixIcon: Icons.storefront_outlined,
                    controller: _nameController,
                    validator: (value) => _required(value, 'Store name'),
                  ),
                  Gap(sh * 0.012),
                  CustomTextField(
                    title: 'Location',
                    hinttext: 'Enter store location ,eg: sidi bel abbes,sidi yacine',
                    prefixIcon: Icons.location_on_outlined,
                    controller: _locationController,
                    validator: (value) => _required(value, 'Location'),
                  ),
                  Gap(sh * 0.012),
                  CustomTextField(
                    title: 'Email',
                    hinttext: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => _required(value, 'Email'),
                  ),
                  Gap(sh * 0.012),
                  CustomTextField(
                    title: 'Password',
                    hinttext: 'Enter your password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) => _required(value, 'Password'),
                  ),
                  Gap(sh * 0.012),
                  CustomTextField(
                    title: 'Description',
                    hinttext: 'Describe your store: must include style.',
                    prefixIcon: Icons.description_outlined,
                    controller: _descriptionController,
                    validator: (value) => _required(value, 'Description'),
                  ),
                  Gap(sh * 0.04),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.025),
                    child: CustomButton(
                      text: _isLoading ? 'Signing up...' : 'Sign up',
                      onPressed: () {
                        if (_isLoading) {
                          return;
                        }
                        _submitSignup();
                      },
                    ),
                  ),
                  Gap(sh * 0.04),
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          color: Color(0xFFD4D4D4),
                          thickness: 1,
                        ),
                      ),
                      const Gap(7),
                      const Text(
                        'Or',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'semi',
                        ),
                      ),
                      const Gap(12),
                      const Expanded(
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
                        'Already have an account? ',
                        style: TextStyle(
                          fontSize: sw * 0.03,
                          fontFamily: 'medium',
                          color: Colors.grey,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const LoginView(),
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
                          'Log in',
                          style: TextStyle(
                            fontSize: sw * 0.03,
                            fontFamily: 'semi',
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
