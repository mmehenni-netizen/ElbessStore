import 'package:elbess_store/core/models/plan_type.dart';
import 'package:elbess_store/features/Auth/Widgets/signupbody.dart';
import 'package:flutter/material.dart';


class SignupView extends StatelessWidget {
  final PlanType? selectedPlan;
  const SignupView({super.key, this.selectedPlan});

  @override
  Widget build(BuildContext context) {
    return Signupbody(selectedPlan: selectedPlan);
  }
}
