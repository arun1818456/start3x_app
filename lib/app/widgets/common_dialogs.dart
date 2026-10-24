import 'package:flutter/material.dart';
import 'package:start3x_app/app/constants/colors.dart';
import 'package:start3x_app/app/mixin/base_class.dart';
import 'package:start3x_app/app/widgets/button.dart';

class CommonDialogs with BaseClass {
  Future<void> showCustomDialog(
    BuildContext context, {
    required String title,
    required String description,
    required String yesButtonText,
    required String noButtonText,
    required VoidCallback onTapYes,
  }) async {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: title,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        if (noButtonText.isNotEmpty)
                          Expanded(
                            child: CustomButton(
                              isBorderEnable: true,
                              borderColor: AppColors.primaryBlue,
                              color: Colors.white,
                              textColor: AppColors.primaryBlue,
                              text: noButtonText,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        if (noButtonText.isNotEmpty) const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: yesButtonText,
                            onPressed: () {
                              Navigator.of(context).pop();
                              onTapYes();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
