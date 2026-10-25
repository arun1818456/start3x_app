import 'package:start3x_app/exports.dart';

class LoginController extends GetxController with BaseClass {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isSignUp = false.obs;

  void toggleSignUpMode() {
    isSignUp.value = !isSignUp.value;
    update();
  }

  // ✅ NORMAL LOGIN FLOW (NO PASSKEY DIALOG)
  Future<void> onTapLoginButton() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      showMySnackBar('Please enter email', alert: true);
      return;
    } else if (password.isEmpty) {
      showMySnackBar('Please enter password', alert: true);
      return;
    }

    Map<String, dynamic> data = {
      "email": email,
      "password": password,
    };

    try {
      showCircularLoader();
      var response = await httpRequest(REQUEST.post, loginApiEndPoint, data);
      hideCircularLoader();

      if (response != null && response["success"] == true) {
        final userData = response["data"];
        if (userData != null) {
          await storage.write(LocalKeys.userData, userData);
        }
        showMySnackBar("Login successful", success: true);
        if (userData != null && (userData["role"] == "admin" || email == "admin@gmail.com")) {
          Get.offAll(() => const AdminDashboardScreen());
        } else {
          Get.offAllNamed(AppRoutes.mainScreen);
        }
      } else {
        showMySnackBar(
          response?["message"] ?? "Login failed. Please check credentials",
          alert: true,
        );
      }
    } catch (e) {
      hideCircularLoader();
      showMySnackBar(e.toString(), error: true);
    }
  }

  // ✅ SIGN UP BUTTON CLICK -> OPENS PASSKEY DIALOG
  void onTapSignUpButton() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty) {
      showMySnackBar('Please enter email', alert: true);
      return;
    } else if (password.isEmpty) {
      showMySnackBar('Please enter password', alert: true);
      return;
    } else if (confirmPassword.isEmpty) {
      showMySnackBar('Please enter confirm password', alert: true);
      return;
    } else if (password != confirmPassword) {
      showMySnackBar('Passwords do not match', alert: true);
      return;
    }

    showPasskeyDialog();
  }

  Future<void> onTapGoogleLogin() async {
    showPasskeyDialog();
  }

  void showPasskeyDialog() {
    final passkeyController = TextEditingController();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Key Icon Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.vpn_key_rounded,
                    color: AppColors.primaryBlue,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                const Text(
                  'Enter Passkey',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle
                const Text(
                  'Enter your passkey to verify and create your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 20),

                // Passkey Field
                MyTextFieldForm(
                  controller: passkeyController,
                  label: 'Passkey',
                  hintText: 'Enter passkey',
                  isPassword: true,
                  prefixIcon: const Icon(
                    Icons.key_rounded,
                    color: AppColors.primaryBlue,
                    size: 22,
                  ),
                  formRadius: 12,
                ),
                const SizedBox(height: 24),

                // Verify & Create Account Button
                CustomButton(
                  text: 'Verify & Create Account',
                  color: AppColors.primaryBlue,
                  radius: 12,
                  buttonHeight: 50,
                  onPressed: () async {
                    final passkey = passkeyController.text.trim();
                    if (passkey.isEmpty) {
                      showMySnackBar('Please enter passkey', alert: true);
                      return;
                    }

                    try {
                      showCircularLoader();

                      // 1. Verify Passkey with backend
                      var verifyRes = await httpRequest(
                        REQUEST.post,
                        "verifyPasskeyApiEndPoint",
                        {"passkey": passkey},
                      );

                      if (verifyRes != null && verifyRes["success"] == true) {
                        // 2. Register user with this passkey
                        var regRes = await httpRequest(
                          REQUEST.post,
                          signUpApiEndPoint,
                          {
                            "name": email.isNotEmpty ? email.split('@').first : "User",
                            "email": email.isNotEmpty ? email : "user_${DateTime.now().millisecondsSinceEpoch}@gmail.com",
                            "password": password.isNotEmpty ? password : "User@1234",
                            "passkey": passkey,
                            "role": "user"
                          },
                        );

                        hideCircularLoader();

                        if (regRes != null && regRes["success"] == true) {
                          final userData = regRes["data"];
                          await storage.write(LocalKeys.userData, userData);
                          Get.back(); // Close Dialog
                          Get.offAllNamed(AppRoutes.mainScreen);
                          showMySnackBar(
                            'Passkey verified! Account created successfully',
                            success: true,
                          );
                        } else {
                          showMySnackBar(
                            regRes?["message"] ?? 'Registration failed',
                            alert: true,
                          );
                        }
                      } else {
                        hideCircularLoader();
                        showMySnackBar(
                          verifyRes?["message"] ?? 'Invalid Passkey. Please check with Admin',
                          alert: true,
                        );
                      }
                    } catch (error) {
                      hideCircularLoader();
                      showMySnackBar(error.toString(), error: true);
                    }
                  },
                ),
                const SizedBox(height: 10),

                // Cancel Button
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
