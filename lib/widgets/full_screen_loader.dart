import 'dart:async';
import 'package:flutter/material.dart';
import 'package:start3x_app/constants/colors.dart';

class LoadingDialog extends StatefulWidget {
  const LoadingDialog({super.key, this.message = "Please wait"});

  final String message;

  @override
  State<LoadingDialog> createState() => LoadingDialogState();
}

class LoadingDialogState extends State<LoadingDialog> {
  String _loadingText = "";
  String dotText = "\u00A0\u00A0\u00A0";
  late Timer _timer;

  void updateMessage({required String message}) {
    _timer.cancel();
    setState(() {
      _loadingText = message;
      dotText = "";
    });
  }

  void setTimer() {
    int dotCount = 0;
    dotText = "\u00A0\u00A0\u00A0";
    _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (mounted) {
        setState(() {
          if (dotCount == 0) {
            dotText = "\u00A0\u00A0\u00A0";
          } else if (dotCount == 1) {
            dotText = ".\u00A0\u00A0";
          } else if (dotCount == 2) {
            dotText = "..\u00A0";
          } else if (dotCount == 3) {
            dotText = "...";
            dotCount = -1;
          }
          dotCount++;
        });
      }
    });
  }

  @override
  void initState() {
    _loadingText = widget.message;
    setTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: PopScope(
        canPop: false,
        child: Stack(
          children: [
            const ModalBarrier(dismissible: false, color: Colors.black45),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                      strokeWidth: 2.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "$_loadingText$dotText",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
