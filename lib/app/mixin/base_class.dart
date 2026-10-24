import 'package:get_storage/get_storage.dart';
import 'package:start3x_app/exports.dart';

mixin BaseClass {
  final GetStorage storage = GetStorage();

  UserDataModel getUserData() {
    if (storage.hasData(LocalKeys.userData)) {
      return UserDataModel.fromJson(storage.read(LocalKeys.userData));
    } else {
      return UserDataModel();
    }
  }

  bool isLoggedIn() {
    return storage.hasData(LocalKeys.userData);
  }
}
