import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'data/mock_data.dart';
import 'models/device.dart'; // Ensure this contains the HiveType annotated Device model
import 'screens/home.dart';
import 'utils/storage_service.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );

  // Hive initialization
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  await Hive.initFlutter();
  Hive.registerAdapter(DeviceAdapter());
  await Hive.openBox<Device>('devices');

  // Initialize StorageService
  await StorageService().init();

  // Load initial mock data if needed
  await MockData.loadInitialMockData();

  runApp(const SizeTransitionExampleApp());
}

class SizeTransitionExampleApp extends StatelessWidget {
  const SizeTransitionExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
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
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
    );

    _zoomAnimation = Tween<double>(begin: 1, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward().whenComplete(() {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (context, animation, secondaryAnimation) =>
            const HomePage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(0, -1.5),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack));
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
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _zoomAnimation.value,
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
            );
          },
        ),
      ),
    );
  }
}
