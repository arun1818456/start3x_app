import 'package:start3x_app/exports.dart';

class ClientSetupController extends GetxController with BaseClass {
  // 1. CLIENT INFO
  final legalNameController = TextEditingController();
  final companyNameController = TextEditingController();
  final gstNameController = TextEditingController();
  final gstNumberController = TextEditingController();
  final phoneController = TextEditingController();
  final targetedLocationController = TextEditingController();
  final fullAddressController = TextEditingController();

  // 2. ON-GRID PRICES
  final onGrid3kWController = TextEditingController();
  final onGrid4kWController = TextEditingController();
  final onGrid5kWController = TextEditingController();

  // 3. HYBRID PRICES
  final hybrid3kWController = TextEditingController();
  final hybrid4kWController = TextEditingController();
  final hybrid5kWController = TextEditingController();

  // 4. HARDWARE SPECS
  final inverterSpecController = TextEditingController();
  final batterySpecController = TextEditingController();


  Future<void> submitClientInfo() async {
    final legalName = legalNameController.text.trim();
    final companyName = companyNameController.text.trim();
    final gstName = gstNameController.text.trim();
    final gstNumber = gstNumberController.text.trim();
    final phone = phoneController.text.trim();
    final targetedLocation = targetedLocationController.text.trim();
    final fullAddress = fullAddressController.text.trim();

    final onGrid3kW = onGrid3kWController.text.trim();
    final onGrid4kW = onGrid4kWController.text.trim();
    final onGrid5kW = onGrid5kWController.text.trim();

    final hybrid3kW = hybrid3kWController.text.trim();
    final hybrid4kW = hybrid4kWController.text.trim();
    final hybrid5kW = hybrid5kWController.text.trim();

    final inverterSpec = inverterSpecController.text.trim();
    final batterySpec = batterySpecController.text.trim();

    // Enforce ALL fields as compulsory
    if (legalName.isEmpty ||
        companyName.isEmpty ||
        gstName.isEmpty ||
        gstNumber.isEmpty ||
        phone.isEmpty ||
        targetedLocation.isEmpty ||
        fullAddress.isEmpty ||
        onGrid3kW.isEmpty ||
        onGrid4kW.isEmpty ||
        onGrid5kW.isEmpty ||
        hybrid3kW.isEmpty ||
        hybrid4kW.isEmpty ||
        hybrid5kW.isEmpty ||
        inverterSpec.isEmpty ||
        batterySpec.isEmpty) {
      showMySnackBar('All client detail fields are compulsory', alert: true);
      return;
    }

    final body = {
      "legalName": legalName,
      "companyName": companyName,
      "gstName": gstName,
      "gstNumber": gstNumber,
      "phone": phone,
      "targetedLocation": targetedLocation,
      "fullAddress": fullAddress,
      "onGrid3kW": onGrid3kW,
      "onGrid4kW": onGrid4kW,
      "onGrid5kW": onGrid5kW,
      "hybrid3kW": hybrid3kW,
      "hybrid4kW": hybrid4kW,
      "hybrid5kW": hybrid5kW,
      "inverterSpec": inverterSpec,
      "batterySpec": batterySpec,
      "inverterName": inverterSpec,
      "batteryName": batterySpec,
    };

    try {
      showCircularLoader();
      final userData = getUserData();
      var res = await httpRequest(
        REQUEST.put,
        updateClientInfoApiEndPoint,
        body,
        token: userData.token ?? "",
      );
      hideCircularLoader();

      if (res != null && res["success"] == true && res["data"] != null) {
        final Map<String, dynamic> updatedData = Map<String, dynamic>.from(res["data"]);
        if (userData.token != null) {
          updatedData['token'] = userData.token;
        }
        if ((updatedData['name'] == null || updatedData['name'].toString().isEmpty) &&
            userData.name != null &&
            userData.name!.isNotEmpty) {
          updatedData['name'] = userData.name;
        }
        await storage.write(LocalKeys.userData, updatedData);
        showMySnackBar("Client setup completed successfully!", success: true);
        Get.offAllNamed(AppRoutes.mainScreen);
      } else {
        showMySnackBar(res?["message"] ?? "Failed to save client details", alert: true);
      }
    } catch (e) {
      hideCircularLoader();
      showMySnackBar(e.toString(), error: true);
    }
  }

  @override
  void onClose() {
    legalNameController.dispose();
    companyNameController.dispose();
    gstNameController.dispose();
    gstNumberController.dispose();
    phoneController.dispose();
    targetedLocationController.dispose();
    fullAddressController.dispose();
    onGrid3kWController.dispose();
    onGrid4kWController.dispose();
    onGrid5kWController.dispose();
    hybrid3kWController.dispose();
    hybrid4kWController.dispose();
    hybrid5kWController.dispose();
    inverterSpecController.dispose();
    batterySpecController.dispose();
    super.onClose();
  }
}
