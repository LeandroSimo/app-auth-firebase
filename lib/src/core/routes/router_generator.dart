import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/posts/presentation/screens/post_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../widgets/splash_screen.dart';
import 'app_routes.dart';

class RouterGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.postDetail:
        final postId = settings.arguments as int?;
        if (postId != null) {
          return MaterialPageRoute(
            builder: (_) => PostDetailScreen(postId: postId),
          );
        }
        return MaterialPageRoute(
          builder: (_) =>
              Scaffold(body: Center(child: Text('Post ID is required'))),
        );
      case AppRoutes.profile:
        final userId = settings.arguments as String? ?? 'current_user';
        return MaterialPageRoute(builder: (_) => ProfileScreen(userId: userId));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
