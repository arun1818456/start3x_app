import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:start3x_app/app/constants/local_keys.dart';
import 'package:start3x_app/app/models/user_model.dart';
import 'package:start3x_app/app/widgets/full_screen_loader.dart';

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

  void showCircularLoader({String message = "Please wait"}) {
    Get.dialog(LoadingDialog(message: message), barrierDismissible: false);
  }

  void hideCircularLoader() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  void showMySnackBar(
    String message, {
    bool error = false,
    int? second = 2,
    bool success = false,
    bool alert = false,
  }) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        backgroundColor: success
            ? Colors.green.shade800
            : alert
                ? Colors.orange.shade800
                : Colors.red,
        duration: Duration(seconds: second ?? 3),
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
        snackPosition: SnackPosition.TOP,
      ),
    );
  }
}
