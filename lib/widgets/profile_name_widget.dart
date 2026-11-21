import 'package:start3x_app/exports.dart';

class ProfileNameWidget extends StatelessWidget {
  const ProfileNameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Arun Mehra",
          style: TextStyle(
            fontFamily: AppFonts.inter,
            fontSize: 16,
            color: AppColors.greyDarkColor,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFFF6B35),
            shape: BoxShape.circle,
          ),
          child: const Text("A", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
