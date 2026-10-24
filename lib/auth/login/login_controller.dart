import 'package:start3x_app/exports.dart';

class LoginController extends GetxController with BaseClass {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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

    if (email == 'admin@gmail.com' && password == 'Admin@123') {
      Get.offAll(() => const AdminDashboardScreen());
    } else {
      showPasskeyDialog();
    }
  }

  Future<void> onTapGoogleLogin() async {
    showPasskeyDialog();
  }

  void showPasskeyDialog() {
    final passkeyController = TextEditingController();
    final email = emailController.text.trim();

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
                    if (passkeyController.text.trim().isEmpty) {
                      showMySnackBar('Please enter passkey', alert: true);
                      return;
                    }

                    try {
                      final userData = {
                        "_id": DateTime.now().millisecondsSinceEpoch.toString(),
                        "email": email.isNotEmpty ? email : "user@gmail.com",
                        "passkey": passkeyController.text.trim(),
                        "token":
                            "sample_token_${DateTime.now().millisecondsSinceEpoch}",
                        "createdAt": DateTime.now().toIso8601String(),
                      };

                      await storage.write(LocalKeys.userData, userData);

                      Get.back(); // Close Dialog
                      Get.offAllNamed(AppRoutes.mainScreen);
                      showMySnackBar(
                        'Passkey verified! Account created successfully',
                        success: true,
                      );
                    } catch (error) {
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
}
