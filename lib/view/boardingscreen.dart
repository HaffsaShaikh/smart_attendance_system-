import 'package:flutter/material.dart';
import 'package:smart_attendance_system/view/introscreen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Boardingscreen extends StatefulWidget {
  const Boardingscreen({super.key});

  @override
  State<Boardingscreen> createState() => _BoardingscreenState();
}

class _BoardingscreenState extends State<Boardingscreen> {
  final PageController _controller = PageController();
  bool lastPage = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.page?.round() == 2 && !lastPage) {
        setState(() => lastPage = true);
      } else if (_controller.page?.round() != 2 && lastPage) {
        setState(() => lastPage = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 🔹 Page View
          PageView(
            controller: _controller,
            children: const [
              IntroScreenWidget(
                animationPath: 'images/1screen.JSON',
                title: "Easy way to confirm your attendance",
                description:
                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
              ),
              IntroScreenWidget(
                animationPath: 'images/2screen.JSON',
                title: "Disciplianry in your hand",
                description:
                    "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.",
              ),
              IntroScreenWidget(
                animationPath: 'images/3screen.JSON',
                title: "Your identity, your access",
                description:
                    "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.",
              ),
            ],
          ),

          // 🔹 Skip + Page Indicator
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _controller.jumpToPage(2),
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      color: Color(0xFF4682B4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: const ExpandingDotsEffect(
                    dotColor: Colors.grey,
                    activeDotColor: Color(0xFF4682B4),
                    dotHeight: 6,
                    dotWidth: 10,
                  ),
                )
              ],
            ),
          ),

          // 🔹 Bottom Button / Arrow
          Positioned(
            bottom: 40,
            right: 30,
            child: lastPage
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF4682B4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Color(0xFF4682B4)),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                    child: const Text(
                      "Get Started",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4682B4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward,
                          color: Colors.white, size: 28),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
