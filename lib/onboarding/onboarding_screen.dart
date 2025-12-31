import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../home/home_screen.dart';
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
      body: Stack(
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
                    "Students spend thousands on books, notes, and gadgets for just one semester.",
                imagePath: "assets/onboarding/books.png",
              ),
              OnboardingPage(
                title: "Share Within Your Campus",
                description:
                    "Borrow, lend, or share textbooks, notes, and gadgets with fellow students.",
                imagePath: "assets/onboarding/share.png",
              ),
              OnboardingPage(
                title: "Smart & Sustainable",
                description:
                    "Upload a photo and we auto-categorize using AI. Save money. Reduce waste.",
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
                    activeDotColor: Colors.blue,
                  ),
                ),

                ElevatedButton(
                  onPressed: () async {
                  if (isLastPage) {
                    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  } else {
    controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
},

                  child: Text(isLastPage ? "Get Started" : "Next"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
