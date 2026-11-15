import 'package:start3x_app/exports.dart';

class AppPages {
  static const init = AppRoutes.splashRoute;

  static final routes = [
    GetPage(
      name: AppRoutes.splashRoute,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.loginScreen,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.clientSetupScreen,
      page: () => const ClientSetupScreen(),
    ),
    GetPage(
      name: AppRoutes.adminDashboardScreen,
      page: () => const AdminDashboardScreen(),
    ),
    GetPage(
      name: AppRoutes.accessControlScreen,
      page: () => const AccessControlScreen(),
    ),
    GetPage(
      name: AppRoutes.clientsScreen,
      page: () => const ClientsScreen(),
    ),
    GetPage(
      name: AppRoutes.clientDetailScreen,
      page: () => const ClientDetailScreen(),
    ),
    GetPage(
      name: AppRoutes.mainScreen,
      page: () => BottomBar(),
    ),
    GetPage(
      name: AppRoutes.homeScreen,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: AppRoutes.callingScreen,
      page: () => const CallingScreen(),
    ),
    GetPage(
      name: AppRoutes.callResponseScreen,
      page: () => const CallResponseScreen(),
    ),
    GetPage(
      name: AppRoutes.addCallData,
      page: () => const FinalScreen(),
    ),
    GetPage(
      name: AppRoutes.groupScreen,
      page: () => const GroupScreen(),
    ),
    GetPage(
      name: AppRoutes.insightsScreen,
      page: () => const InsightsScreen(),
    ),
    GetPage(
      name: AppRoutes.toDoScreen,
      page: () => const ToDoScreen(),
    ),
    GetPage(
      name: AppRoutes.teamScreen,
      page: () => const TeamScreen(),
    ),
  ];
}
