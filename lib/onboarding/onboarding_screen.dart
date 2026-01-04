import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/auth_gate.dart';
import 'onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C144B),
              Color(0xFF5A3A8C),
            ],
          ),
        ),
        child: Stack(
          children: [
            PageView(
              controller: controller,
              onPageChanged: (index) {
                setState(() => isLastPage = index == 2);
              },
              children: const [
                OnboardingPage(
                  title: "Textbooks Are Expensive",
                  description:
                      "Students spend thousands every semester on books and materials.",
                  imagePath: "assets/onboarding/books.png",
                ),
                OnboardingPage(
                  title: "Share Within Your Campus",
                  description:
                      "Borrow, lend, and share resources with fellow students.",
                  imagePath: "assets/onboarding/share.png",
                ),
                OnboardingPage(
                  title: "Smart & Sustainable",
                  description:
                      "Save money and reduce waste with a smarter sharing system.",
                  imagePath: "assets/onboarding/ai.png",
                ),
              ],
            ),

            // Bottom controls
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmoothPageIndicator(
                    controller: controller,
                    count: 3,
                    effect: WormEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      activeDotColor: Colors.white,
                      dotColor: Colors.white38,
                    ),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF3B1E5B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      isLastPage ? "Get Started" : "Next",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () async {
                      if (isLastPage) {
                        final user =
                            FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .update({'seenIntro': true});

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AuthGate(),
                            ),
                            (route) => false,
                          );
                        }
                      } else {
                        controller.nextPage(
                          duration:
                              const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 