import 'package:start3x_app/exports.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      () => SplashController(),
    );
    Get.put<MySocketController>(
      MySocketController(),
      permanent: true,
    );
  }
}
