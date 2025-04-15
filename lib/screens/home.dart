import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:smart_home_system/utils/ui_helper/app_colors.dart';
import 'package:smart_home_system/screens/login_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "EcoHome",
          style: TextStyle(
              fontFamily: "Roboto",
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
          ),
        ),
        backgroundColor: AppColors.successColor,
      ),
      body: Stack(
        children: [
          // Full-Screen Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/Ecohome.jpg",
              fit: BoxFit.cover,
            ),
          ),

          // Elevated Button at the top-right corner below AppBar
          Positioned(
            top: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LogIn()),);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "SignIn/Login",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Centered Animated Welcome Text
          Center(
            child: AnimatedTextKit(
              repeatForever: false,
              // Runs the animation indefinitely
              animatedTexts: [
                TyperAnimatedText(
                  "Welcome To EcoHome",
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  speed: const Duration(
                      milliseconds: 2000), // Speed of text animation
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
