import 'package:flutter/material.dart';
import 'package:smart_home_system/Screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SizeTransitionExampleApp());
}

class SizeTransitionExampleApp extends StatelessWidget {
  const SizeTransitionExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SizeTransitionExample(),
    );
  }
}

class SizeTransitionExample extends StatefulWidget {
  const SizeTransitionExample({super.key});

  @override
  State<SizeTransitionExample> createState() => _SizeTransitionExampleState();
}

class _SizeTransitionExampleState extends State<SizeTransitionExample>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late final Animation<double> _zoomAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );

    _zoomAnimation = Tween<double>(begin: 1, end: 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.2, curve: Curves.elasticOut),
      ),
    );

    _controller.forward().whenComplete(() {
      // After the combined animation, navigate to HomePage with a custom route.
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Slide transition: HomePage comes from the top with a bounce.
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(0, -2),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.bounceOut));
              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
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
      body: Center(
        child: SizeTransition(
          sizeFactor: _animation,
          axis: Axis.horizontal,
          axisAlignment: -1,
          child: const Center(
            child: Image(
              image: AssetImage('assets/images/logo.png'),
              width: 200.0,
              height: 200.0,
            ),
          ),
        ),
      ),
    );
  }
}