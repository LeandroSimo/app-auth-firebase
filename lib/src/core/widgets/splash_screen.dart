import 'package:app_test/src/core/utils/extensions.dart';
import 'package:flutter/material.dart';

import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  @override
  void initState() {
    super.initState();

    // Inicializa o controller da animação de pulo
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Cria a animação de pulo vertical mais realista
    _bounceAnimation =
        Tween<double>(
          begin: 10.0, // Começa um pouco abaixo
          end: -50.0, // Vai mais alto
        ).animate(
          CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
        );

    // Inicia a animação em loop
    _bounceController.repeat(reverse: true);

    // Inicializa o controller da animação de progresso
    _progressController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Cria a animação de progresso de 0 a 1
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Inicia a animação de progresso
    _progressController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 3600), () {
        if (!mounted) return;

        Navigator.pushReplacementNamed(context, AppRoutes.home);
      });
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            TweenAnimationBuilder(
              duration: const Duration(seconds: 2),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Opacity(opacity: value, child: child);
              },
              child: AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _bounceAnimation.value),
                    child: Icon(
                      Icons.flutter_dash,
                      size: context.mediaQuery.width * 0.45,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: context.mediaQuery.height * 0.06),

            TweenAnimationBuilder(
              duration: const Duration(seconds: 2),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Opacity(opacity: value, child: child);
              },
              child: SizedBox(
                width: context.mediaQuery.width * 0.6,
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressAnimation.value,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      backgroundColor: Colors.white.withAlpha(
                        (0.2 * 255).round(),
                      ),
                      minHeight: 6.0,
                      borderRadius: BorderRadius.circular(10),
                    );
                  },
                ),
              ),
            ),

            const Spacer(),
            TweenAnimationBuilder(
              duration: const Duration(seconds: 2),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Opacity(opacity: value, child: child);
              },

              child: Text(
                'Powered by Leandro',
                style: TextStyle(
                  fontSize: context.mediaQuery.width * 0.03,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: context.mediaQuery.height * 0.02),
          ],
        ),
      ),
    );
  }
}
