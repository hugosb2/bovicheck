import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icon.png', width: 120)
                .animate()
                .scale(
                  delay: 300.ms,
                  duration: 800.ms,
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 600.ms),

            const SizedBox(height: 24),

            Text(
              'BoviCheck',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
                .animate()
                .fadeIn(
                  delay: 900.ms,
                  duration: 800.ms,
                )
                .slideY(
                  begin: 0.5,
                  end: 0,
                  curve: Curves.easeOut,
                ),
          ],
        ),
      ),
    );
  }
}