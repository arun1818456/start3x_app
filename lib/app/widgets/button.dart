import 'package:start3x_app/exports.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final bool? isBorderEnable;
  final Color? color;
  final bool? loading;
  final double? width;
  final Color? textColor;
  final Color? borderColor;
  final Function() onPressed;
  final Widget? buttonCenter;
  final double? buttonHeight;
  final TextStyle? textStyle;
  final EdgeInsets? margin;
  final double? radius;

  const CustomButton({
    super.key,
    this.color,
    this.width,
    this.isBorderEnable = false,
    this.textColor,
    this.buttonCenter,
    this.buttonHeight,
    required this.text,
    this.loading = false,
    this.borderColor,
    required this.onPressed,
    this.textStyle,
    this.margin,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primaryBlue;

    return Container(
      margin: margin ?? EdgeInsets.zero,
      width: width ?? double.infinity,
      height: buttonHeight ?? 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 12),
        boxShadow: loading == true
            ? []
            : [
                BoxShadow(
                  color: effectiveColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: loading == true ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveColor,
          disabledBackgroundColor: effectiveColor.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius ?? 12),
            side: isBorderEnable == true
                ? BorderSide(color: borderColor ?? Colors.white, width: 1.5)
                : BorderSide.none,
          ),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: loading == true
            ? const Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            : buttonCenter ??
                  Text(
                    text,
                    style:
                        textStyle ??
                        TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                          color: textColor ?? Colors.white,
                        ),
                  ),
      ),
    );
  }
}
