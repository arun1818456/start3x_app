import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:start3x_app/exports.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus!.unfocus();
        }
      },
      child: GetMaterialApp(
        title: 'Start3x App',
        initialRoute: kIsWeb ? AppRoutes.webHomeScreen : AppRoutes.splashRoute,
        getPages: AppPages.routes,
        defaultTransition: Transition.fade,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryBlue,
            primary: AppColors.primaryBlue,
          ),
          scrollbarTheme: ScrollbarThemeData(
            thumbVisibility: WidgetStateProperty.all(true),
            thickness: WidgetStateProperty.all(6),
            radius: const Radius.circular(8),
          ),
        ),
      ),
    );
  }
}
