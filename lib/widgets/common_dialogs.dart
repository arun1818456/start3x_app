import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:start3x_app/constants/colors.dart';
import 'package:start3x_app/constants/image_constants.dart';
import 'package:start3x_app/mixin/base_class.dart';
import 'package:start3x_app/web/view/home/home_screen_controller.dart';
import 'package:start3x_app/widgets/button.dart';
import 'package:start3x_app/widgets/text_field.dart';

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
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 420,
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(
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
        ),
      ),
    );
      },
    );
  }

  static void showScalePlanDialog(
    BuildContext context, {
    required String planName,
    required String price,
    required HomeScreenController controller,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Scale Plan",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, a1, a2, child) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(opacity: a1.value, child: child),
        );
      },
      pageBuilder: (context1, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                width: MediaQuery.of(context1).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              "$planName plan (₹$price)",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color(0xFF555555),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(Icons.close, color: Colors.grey),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    _buildDialogTextField(
                      textController: controller.planBusinessController,
                      hint: "Legal Business Name (Required)",
                    ),
                    const SizedBox(height: 14),
                    _buildDialogTextField(
                      textController: controller.planNameController,
                      hint: "Your Name (Required)",
                    ),
                    const SizedBox(height: 14),
                    _buildDialogTextField(
                      textController: controller.planPhoneController,
                      hint: "Contact Number (Required)",
                      keyboardType: TextInputType.phone,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(AppImages.flag, width: 24),
                            const SizedBox(width: 4),
                            const Text(
                              "+91 ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF0D1B3E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildDialogTextField(
                      textController: controller.planDateController,
                      hint: "When would you like to start? (Required)",
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (pickedDate != null) {
                          controller.planDateController.text =
                              "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                        }
                      },
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(height: 24, width: 1, color: Colors.grey.shade400),
                          const SizedBox(width: 12),
                          const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.calendar_month_outlined, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildDialogTextField(
                      textController: controller.planAddressController,
                      hint: "Business Address",
                    ),
                    const SizedBox(height: 14),
                    _buildDialogTextField(
                      textController: controller.planGstController,
                      hint: "GST Number",
                    ),
                    const SizedBox(height: 24),
                    GetBuilder<HomeScreenController>(
                      builder: (cnt) {
                        return cnt.isSubmittingPlan
                            ? const CircularProgressIndicator(color: AppColors.appColorOrange)
                            : CustomButton(
                                text: "Start Now",
                                onPressed: () {
                                  cnt.submitScalePlanForm(planAmount: price);
                                },
                                width: 200,
                                buttonHeight: 45,
                                radius: 12,
                                color: AppColors.appColorOrange,
                              );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      },
    );
  }

  static Widget _buildDialogTextField({
    required String hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    required TextEditingController textController,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
  }) {
    return MyTextFieldForm(
      controller: textController,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      fillColor: const Color(0xFFDCDCDC),
      borderColor: Colors.transparent,
      formRadius: 12,
      hintStyle: const TextStyle(color: Color(0xFF666666), fontSize: 14),
    );
  }

  static void common2ButtonsPopUp(
    BuildContext context, {
    VoidCallback? onClose,
    bool showSecondButton = true,
    required VoidCallback onButtonTap,
    required VoidCallback onButton2Tap,
    required String button1Image,
    required String button2Image,
  }) async {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black12,
      transitionDuration: const Duration(milliseconds: 150),
      transitionBuilder:
          (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(animation),
          child: child,
        );
      },
      pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, StateSetter setStateDialog) {
            return Container(
              alignment: Alignment.bottomCenter,
              child: Wrap(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: Container(
                      width: MediaQuery.of(context).size.width - 40,
                      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Column(
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Upload",
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Get.back();
                                        onButtonTap();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.whiteColor,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.black),
                                        ),
                                        child: Image.asset(
                                          button1Image,
                                          height: 30,
                                          width: 30,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    InkWell(
                                      onTap: () {
                                        Get.back();
                                        onButton2Tap();
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(vertical: 16),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.whiteColor,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.black),
                                        ),
                                        child: Image.asset(
                                          button2Image,
                                          height: 30,
                                          width: 30,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({this.color = Colors.black, this.strokeWidth = 1.0, this.gap = 5.0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double radius = 12.0;
    RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    Path path = Path()..addRRect(rrect);

    for (final measure in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < measure.length) {
        final double nextDistance = distance + gap;
        canvas.drawPath(
          measure.extractPath(distance, nextDistance),
          dashedPaint,
        );
        distance = nextDistance + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.gap != gap;
  }
}
