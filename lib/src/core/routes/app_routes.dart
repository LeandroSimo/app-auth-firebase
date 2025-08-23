import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/posts/presentation/screens/post_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../widgets/splash_screen.dart';

class AppRoutes {
  static const String splash = SplashScreen.routeName;
  static const String login = LoginScreen.routeName;
  static const String register = RegisterScreen.routeName;
  static const String home = HomeScreen.routeName;
  static const String postDetail = PostDetailScreen.routeName;
  static const String profile = ProfileScreen.routeName;
}
