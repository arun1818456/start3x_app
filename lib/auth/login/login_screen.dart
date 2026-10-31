import 'package:start3x_app/exports.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: LoginController(),
      builder: (controller) => Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // 🎨 Header Gradient Background
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryBlue, AppColors.appColor],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // Circular White Container around Logo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        AppImages.logo,
                        height: 60,
                        width: 60,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 45,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Welcome Text
                    Obx(
                      () => Text(
                        controller.isSignUp.value ? "Create Account" : "Welcome",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Obx(
                      () => Text(
                        controller.isSignUp.value
                            ? "Sign up for a new account"
                            : "Login to your account",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🗒️ Modern Form Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // 👤 Full Name Field (Visible in Sign Up Mode)
                            Obx(() {
                              if (controller.isSignUp.value) {
                                return Column(
                                  children: [
                                    MyTextFieldForm(
                                      keyboardType: TextInputType.name,
                                      controller: controller.nameController,
                                      label: "Your Full Name",
                                      hintText: "Enter your full name",
                                      prefixIcon: const Icon(
                                        Icons.person_outline_rounded,
                                        color: AppColors.primaryBlue,
                                        size: 22,
                                      ),
                                      formRadius: 12,
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            }),

                            // 📧 Email Field
                            MyTextFieldForm(
                              keyboardType: TextInputType.emailAddress,
                              controller: controller.emailController,
                              label: "Email",
                              hintText: "Enter your email",
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: AppColors.primaryBlue,
                                size: 22,
                              ),
                              formRadius: 12,
                            ),

                            const SizedBox(height: 10),

                            // 🔒 Password Field
                            MyTextFieldForm(
                              keyboardType: TextInputType.visiblePassword,
                              controller: controller.passwordController,
                              label: controller.isSignUp.value ? "New Password" : "Password",
                              hintText: controller.isSignUp.value ? "Enter new password" : "Enter your password",
                              isPassword: true,
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                color: AppColors.primaryBlue,
                                size: 22,
                              ),
                              formRadius: 12,
                            ),

                            // 🔒 Confirm Password Field (Visible in Sign Up Mode)
                            Obx(() {
                              if (controller.isSignUp.value) {
                                return Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    MyTextFieldForm(
                                      keyboardType: TextInputType.visiblePassword,
                                      controller: controller.confirmPasswordController,
                                      label: "Confirm Password",
                                      hintText: "Re-enter new password",
                                      isPassword: true,
                                      prefixIcon: const Icon(
                                        Icons.lock_reset_rounded,
                                        color: AppColors.primaryBlue,
                                        size: 22,
                                      ),
                                      formRadius: 12,
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            }),

                            const SizedBox(height: 15),

                            // 🚀 Custom Action Button (LOGIN / SIGN UP)
                            Obx(
                              () => CustomButton(
                                text: controller.isSignUp.value ? "SIGN UP" : "LOGIN",
                                color: AppColors.primaryBlue,
                                radius: 12,
                                buttonHeight: 52,
                                onPressed: controller.isSignUp.value
                                    ? controller.onTapSignUpButton
                                    : controller.onTapLoginButton,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // ➖ OR Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey.withValues(alpha: 0.3),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  child: Text(
                                    "OR",
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey.withValues(alpha: 0.3),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // 🌐 Google Login Button
                            OutlinedButton(
                              onPressed: controller.onTapGoogleLogin,
                              style: OutlinedButton.styleFrom(
                                fixedSize: const Size(double.maxFinite, 52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AppImages.googleLogo,
                                    height: 25,
                                    width: 25,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.g_mobiledata, size: 25),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Continue with Google",
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 🔄 New User / Toggle Sign Up Mode Button
                            Obx(
                              () => TextButton(
                                onPressed: controller.toggleSignUpMode,
                                child: Text(
                                  controller.isSignUp.value
                                      ? "Already have an account? Login"
                                      : "New User? Create Account",
                                  style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
