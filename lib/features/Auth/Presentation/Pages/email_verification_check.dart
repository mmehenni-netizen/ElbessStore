import 'dart:async';

import 'package:elbess_store/core/utils/size_config.dart';
import 'package:elbess_store/features/Auth/data/auth_repo.dart';
import 'package:elbess_store/root.dart';
import 'package:flutter/material.dart';

class EmailVerificationCheck extends StatefulWidget {
  final String email;

  const EmailVerificationCheck({
    required this.email,
    super.key,
  });

  @override
  State<EmailVerificationCheck> createState() => _EmailVerificationCheckState();
}

class _EmailVerificationCheckState extends State<EmailVerificationCheck> {
  final AuthRepo _authRepo = AuthRepo();
  Timer? _verificationTimer;
  bool _isVerified = false;
  int _secondsRemaining = 300; // 5 minutes timeout

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  void _startVerificationCheck() {
    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted) return;

      try {
        final isVerified = await _authRepo.checkEmailVerification(widget.email);

        if (isVerified && mounted) {
          setState(() {
            _isVerified = true;
          });

          _verificationTimer?.cancel();

          // Navigate to Root after a short delay
          await Future.delayed(const Duration(milliseconds: 800));

          if (mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const Root(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    )),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          }
        }
      } catch (e) {
        // Continue polling on error
      }

      // Update countdown
      if (mounted) {
        setState(() {
          _secondsRemaining--;
        });

        // Cancel after 5 minutes
        if (_secondsRemaining <= 0) {
          _verificationTimer?.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isVerified)
              Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Email Verified!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  const SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Verifying Your Email',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Check ${widget.email} for\nverification link',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (_secondsRemaining > 0)
                    Text(
                      'Auto-checking: ${(_secondsRemaining ~/ 60)}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  if (_secondsRemaining <= 0)
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Back to Sign In',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
