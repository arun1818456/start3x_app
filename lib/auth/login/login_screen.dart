import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:start3x_app/widgets/responsive_layout.dart';
import 'package:start3x_app/exports.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: LoginController(),
      builder: (controller) => Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= Breakpoints.mobile;

            if (isWide && kIsWeb) {
              return _buildWebLayout(context, controller, constraints);
            }
            return _buildMobileLayout(context, controller);
          },
        ),
      ),
    );
  }

  /// Web/Desktop layout: side-by-side branding panel + login form
  Widget _buildWebLayout(
    BuildContext context,
    LoginController controller,
    BoxConstraints constraints,
  ) {
    final bool isDesktop = constraints.maxWidth >= Breakpoints.tablet;

    return Row(
      children: [
        // Left branding panel (only on desktop-sized screens)
        if (isDesktop)
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryBlue, AppColors.appColor],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          AppImages.logo,
                          height: 80,
                          width: 80,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 60,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "Start3x",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Manage your leads, tasks & team\nall in one place.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Right form panel
        Expanded(
          flex: 4,
          child: Container(
            color: Colors.white,
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _buildFormContent(controller, isWeb: true),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Mobile layout: original stacked design
  Widget _buildMobileLayout(
    BuildContext context,
    LoginController controller,
  ) {
    return Stack(
      children: [
        // Header Gradient Background
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
                    errorBuilder: (context, error, stackTrace) => const Icon(
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
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),

                const SizedBox(height: 20),

                // Modern Form Card
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
                    child: _buildFormContent(controller, isWeb: false),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Shared form content used by both mobile and web layouts
  Widget _buildFormContent(LoginController controller, {required bool isWeb}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isWeb) ...[
          // Top logo banner for web form
          Center(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Image.asset(
                AppImages.logo,
                height: 52,
                width: 52,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 40,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => Text(
              controller.isSignUp.value ? "Create Account" : "Welcome Back",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Obx(
            () => Text(
              controller.isSignUp.value
                  ? "Sign up for a new account"
                  : "Login to your account",
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 13.5),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Full Name Field (Visible in Sign Up Mode)
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

        // Email Field
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

        // Password Field
        MyTextFieldForm(
          keyboardType: TextInputType.visiblePassword,
          controller: controller.passwordController,
          label: controller.isSignUp.value ? "New Password" : "Password",
          hintText: controller.isSignUp.value
              ? "Enter new password"
              : "Enter your password",
          isPassword: true,
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.primaryBlue,
            size: 22,
          ),
          formRadius: 12,
        ),

        // Confirm Password Field (Visible in Sign Up Mode)
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

        // Action Button (LOGIN / SIGN UP)
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

        // OR Divider
        Row(
          children: [
            Expanded(
              child: Divider(
                color: Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
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

        // Google Login Button
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

        // Toggle Sign Up Mode Button
        Center(
          child: Obx(
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
        ),
      ],
    );
  }
}
