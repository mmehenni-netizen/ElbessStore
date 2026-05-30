import 'package:elbess_store/features/Auth/Presentation/Pages/signup_view.dart';
import 'package:flutter/material.dart';

// Using local bundled fonts declared in pubspec.yaml
import '../../../core/models/plan_type.dart';


class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
  PlanType selectedPlan = PlanType.yearly;
  late AnimationController _badgeController;

  @override
  void initState() {
    super.initState();
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _badgeController.dispose();
    super.dispose();
  }

  void _selectPlan(PlanType plan) {
    setState(() {
      selectedPlan = plan;
    });
  }

  void _continue() {
    // Navigate to signup and pass selected plan via constructor
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SignupView(selectedPlan: selectedPlan),
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
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF8B4513);
    final bg = Colors.white;
    final cardAccent = const Color(0xFFF5EDE3);
    final heading = const Color(0xFF2C1A0E);
    final bodyText = const Color(0xFF6B4226);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ELBESS',
                      style: TextStyle(
                        fontFamily: 'bold',
                        color: heading,
                        fontWeight: FontWeight.w800,
                        fontSize: 28)),
                    Text('Cancel anytime',
                      style: TextStyle(
                        fontFamily: 'regular', color: bodyText, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Choose your plan to get started',
                  style: TextStyle(
                    fontFamily: 'semi',
                    color: heading,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
                const SizedBox(height: 24),

                // Toggle
                _buildToggle(primary),

                const SizedBox(height: 20),

                // Plans
                GestureDetector(
                  onTap: () => _selectPlan(PlanType.monthly),
                  child: _planCard(
                    title: 'Monthly',
                    price: '2,000 DA / month',
                    features: const [
                      'Full seller platform access',
                      '20 DA commission per delivered order',
                      'Product listing & management',
                      'Basic analytics',
                    ],
                    isSelected: selectedPlan == PlanType.monthly,
                    primary: primary,
                    cardAccent: cardAccent,
                    heading: heading,
                    bodyText: bodyText,
                    ctaText: 'Start Monthly',
                    outlined: true,
                    onPressed: _continue,
                  ),
                ),

                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () => _selectPlan(PlanType.yearly),
                  child: _planCard(
                    title: 'Yearly',
                    price: '20,000 DA / year',
                    priceSub: '1,667 DA / month',
                    features: const [
                      'Full seller platform access',
                      '20 DA commission per delivered order',
                      'Product listing & management',
                      'Basic analytics',
                      'Priority support',
                      'Featured product boosting',
                      'Advanced analytics tools',
                      'Store promotion visibility',
                    ],
                    isSelected: selectedPlan == PlanType.yearly,
                    primary: primary,
                    cardAccent: cardAccent,
                    heading: heading,
                    bodyText: bodyText,
                    ctaText: 'Start Yearly',
                    outlined: false,
                    recommended: true,
                    badgeAnimation: _badgeController,
                    onPressed: _continue,
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/login'),
                        child: Text('Already have a subscription? Log in',
                          style: TextStyle(
                            fontFamily: 'regular',
                            color: bodyText,
                            fontSize: 13,
                            decoration: TextDecoration.underline)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock, size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                            Text('Secure payment processing',
                              style: TextStyle(fontFamily: 'regular', color: Colors.grey, fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildToggle(Color primary) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3F0),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _selectPlan(PlanType.monthly),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: selectedPlan == PlanType.monthly
                    ? Alignment.center
                    : Alignment.centerLeft,
                child: Center(
                  child: Text('Monthly',
                    style: TextStyle(
                      fontFamily: 'regular',
                      color: selectedPlan == PlanType.monthly
                        ? Colors.white
                        : primary)),
                ),
                decoration: BoxDecoration(
                  color: selectedPlan == PlanType.monthly ? primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => _selectPlan(PlanType.yearly),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: selectedPlan == PlanType.yearly
                    ? Alignment.center
                    : Alignment.centerLeft,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text('Yearly',
                      style: TextStyle(
                        fontFamily: 'regular',
                        color: selectedPlan == PlanType.yearly ? Colors.white : primary)),
                    if (selectedPlan == PlanType.yearly)
                      Positioned(
                        right: 12,
                        top: -14,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD27A),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)]
                            ),
                            child: Text('Save 17%', style: TextStyle(fontFamily: 'regular', fontSize: 11)),
                          ),
                        ),
                      )
                  ],
                ),
                decoration: BoxDecoration(
                  color: selectedPlan == PlanType.yearly ? primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _planCard({
    required String title,
    required String price,
    String? priceSub,
    required List<String> features,
    required bool isSelected,
    required Color primary,
    required Color cardAccent,
    required Color heading,
    required Color bodyText,
    required String ctaText,
    required bool outlined,
    bool recommended = false,
    AnimationController? badgeAnimation,
    required VoidCallback onPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: recommended
            ? null
            : (isSelected ? Colors.white : Colors.white),
        border: isSelected ? Border.all(color: primary, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
        gradient: recommended
            ? const LinearGradient(colors: [Color(0xFFFDF6EE), Color(0xFFF0E0CC)])
            : null,
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'bold',
                  color: heading,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              if (recommended) ...[
                const SizedBox(height: 8),
                _mostPopularBadge(badgeAnimation),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      fontFamily: 'bold',
                      color: heading,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (priceSub != null)
                    Text(
                      '($priceSub)',
                      style: TextStyle(fontFamily: 'regular', color: bodyText),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                child: Column(
                  key: ValueKey(isSelected),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: features
                      .map((f) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedOpacity(
                                  opacity: isSelected ? 1 : 0.8,
                                  duration: const Duration(milliseconds: 400),
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 1),
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black.withOpacity(0.06), blurRadius: 4)
                                        ]),
                                    child: Icon(Icons.check, size: 12, color: primary),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    f,
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'regular',
                                      color: bodyText,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onPressed,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: outlined ? Colors.white : primary,
                        side: outlined ? BorderSide(color: primary) : BorderSide.none,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(ctaText,
                          style: TextStyle(
                            fontFamily: 'regular', color: outlined ? primary : Colors.white)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _mostPopularBadge(AnimationController? controller) {
    return AnimatedBuilder(
      animation: controller ?? const AlwaysStoppedAnimation(0),
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE1A8).withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Most Popular',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: 'regular', fontSize: 12),
              ),
              const SizedBox(width: 6),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.amber.withOpacity(0.9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, (controller?.value ?? 0.5)],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
  