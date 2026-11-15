import 'package:start3x_app/exports.dart';

class ClientSetupController extends GetxController with BaseClass {
  bool isFromMenu = false;
  String targetPasskeyStr = '';
  String targetPasskeyId = '';

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

  @override
  void onInit() {
    super.onInit();
    initializeWithArguments(Get.arguments);
  }

  void initializeWithArguments([dynamic args]) {
    final arguments = args ?? Get.arguments;
    if (arguments != null && arguments is Map) {
      isFromMenu = arguments['fromMenu'] == true;
    }
    loadExistingClientInfo();
    fetchClientInfoFromApi();
  }

  String resolveTargetPasskey() {
    String passkey = '';
    if (Get.arguments != null) {
      if (Get.arguments is Map) {
        if (Get.arguments['passkey'] != null) {
          passkey = Get.arguments['passkey'].toString();
        } else if (Get.arguments['client'] != null) {
          final clientObj = Get.arguments['client'];
          if (clientObj is ClientModel) passkey = clientObj.passkey;
          if (clientObj is AccessClientModel) passkey = clientObj.id;
        }
      } else if (Get.arguments is ClientModel) {
        passkey = (Get.arguments as ClientModel).passkey;
      } else if (Get.arguments is AccessClientModel) {
        passkey = (Get.arguments as AccessClientModel).id;
      } else if (Get.arguments is String) {
        passkey = Get.arguments as String;
      }
    }

    if (passkey.isEmpty && Get.isRegistered<HomeController>()) {
      passkey = Get.find<HomeController>().clientPasskey;
    }

    if (passkey.isEmpty) {
      passkey = storage.read('clientPasskey')?.toString() ?? '';
    }

    if (passkey.isEmpty && getUserData().role != 'admin') {
      passkey = getUserData().passkey ?? '';
    }

    return passkey;
  }

  bool isViewingClient() {
    final user = getUserData();
    if (user.role == 'admin') {
      final targetKey = resolveTargetPasskey();
      if (targetKey.isNotEmpty && targetKey != user.passkey) {
        return true;
      }
      if (Get.arguments != null && Get.arguments is Map && Get.arguments['client'] != null) {
        return true;
      }
      if (Get.arguments is ClientModel || Get.arguments is AccessClientModel) {
        return true;
      }
    }
    return false;
  }

  void loadExistingClientInfo() {
    final List<Map<String, dynamic>> sources = [];
    final targetKey = resolveTargetPasskey();

    // Source 1: If client object passed in Get.arguments
    if (Get.arguments != null && Get.arguments is Map) {
      final clientObj = Get.arguments['client'];
      if (clientObj != null) {
        if (clientObj is ClientModel) {
          sources.add({
            'companyName': clientObj.name,
            'legalName': clientObj.name,
            'name': clientObj.name,
            'phone': clientObj.phone,
            'location': clientObj.location,
            'fullAddress': clientObj.location,
          });
        } else if (clientObj is AccessClientModel) {
          sources.add({
            'companyName': clientObj.company.isNotEmpty ? clientObj.company : clientObj.name,
            'legalName': clientObj.name,
            'name': clientObj.name,
            'phone': clientObj.phone,
            'location': clientObj.location,
            'fullAddress': clientObj.location,
          });
        }
      }
    }

    // Source 2: Passkey specific storage 'clientInfo_$targetKey'
    if (targetKey.isNotEmpty) {
      final passkeyClientInfo = storage.read('clientInfo_$targetKey');
      if (passkeyClientInfo != null && passkeyClientInfo is Map) {
        sources.add(Map<String, dynamic>.from(passkeyClientInfo));
      }
    }

    // Source 3: LocalStorage 'savedClientSetup'
    final savedSetup = storage.read('savedClientSetup');
    if (savedSetup != null && savedSetup is Map) {
      sources.add(Map<String, dynamic>.from(savedSetup));
    }

    // Source 4: LocalStorage 'clientInfo'
    final clientInfoStorage = storage.read('clientInfo');
    if (clientInfoStorage != null && clientInfoStorage is Map) {
      sources.add(Map<String, dynamic>.from(clientInfoStorage));
    }

    // Source 5: UserData ONLY IF NOT viewing a client as admin
    if (!isViewingClient()) {
      final rawUser = storage.read(LocalKeys.userData);
      if (rawUser != null && rawUser is Map) {
        final userMap = Map<String, dynamic>.from(rawUser);
        sources.add(userMap);
        if (userMap['clientInfo'] is Map) {
          sources.add(Map<String, dynamic>.from(userMap['clientInfo']));
        }
        if (userMap['passkey'] is Map) {
          sources.add(Map<String, dynamic>.from(userMap['passkey']));
        }
        if (userMap['client'] is Map) {
          sources.add(Map<String, dynamic>.from(userMap['client']));
        }
      }
    }

    legalNameController.text =
        _getValue(sources, ['legalName', 'legal_name', 'name']);
    companyNameController.text =
        _getValue(sources, ['companyName', 'company_name', 'company']);
    gstNameController.text =
        _getValue(sources, ['gstName', 'gst_name']);
    gstNumberController.text =
        _getValue(sources, ['gstNumber', 'gst_number', 'gstNo', 'gst']);
    phoneController.text =
        _getValue(sources, ['phone', 'phoneNumber', 'phone_number', 'mobile']);
    targetedLocationController.text = _getValue(
        sources, ['targetedLocation', 'target_location', 'location']);
    fullAddressController.text =
        _getValue(sources, ['fullAddress', 'full_address', 'address']);

    onGrid3kWController.text = _getValue(
        sources, ['onGrid3kW', 'onGrid3Kw', 'ongrid_3kw', 'on_grid_3kw', 'onGrid3']);
    onGrid4kWController.text = _getValue(
        sources, ['onGrid4kW', 'onGrid4Kw', 'ongrid_4kw', 'on_grid_4kw', 'onGrid4']);
    onGrid5kWController.text = _getValue(
        sources, ['onGrid5kW', 'onGrid5Kw', 'ongrid_5kw', 'on_grid_5kw', 'onGrid5']);

    hybrid3kWController.text = _getValue(
        sources, ['hybrid3kW', 'hybrid3Kw', 'hybrid_3kw', 'hybrid_3kW', 'hybrid3']);
    hybrid4kWController.text = _getValue(
        sources, ['hybrid4kW', 'hybrid4Kw', 'hybrid_4kw', 'hybrid_4kW', 'hybrid4']);
    hybrid5kWController.text = _getValue(
        sources, ['hybrid5kW', 'hybrid5Kw', 'hybrid_5kw', 'hybrid_5kW', 'hybrid5']);

    inverterSpecController.text = _getValue(
        sources, ['inverterName', 'inverterSpec', 'inverter_spec', 'inverter']);
    batterySpecController.text = _getValue(
        sources, ['batteryName', 'batterySpec', 'battery_spec', 'battery']);
  }

  String _getValue(List<Map<String, dynamic>> sources, List<String> keys) {
    for (var source in sources) {
      for (var key in keys) {
        if (source.containsKey(key) &&
            source[key] != null &&
            source[key].toString().trim().isNotEmpty) {
          return source[key].toString().trim();
        }
      }
    }
    return '';
  }

  void populateFromMap(Map<String, dynamic> cInfo, [Map<String, dynamic>? passkeyData]) {
    final legalName = cInfo['legalName'] ?? cInfo['name'] ?? passkeyData?['name'] ?? '';
    final compName = cInfo['companyName'] ?? passkeyData?['name'] ?? '';
    final gstName = cInfo['gstName'] ?? '';
    final gstNumber = cInfo['gstNumber'] ?? '';
    final phone = cInfo['phone'] ?? cInfo['phoneNumber'] ?? '';
    final targetLoc = cInfo['targetedLocation'] ?? cInfo['location'] ?? '';
    final fullAddr = cInfo['fullAddress'] ?? cInfo['address'] ?? '';

    final onGrid3 = cInfo['onGrid3kW'] ?? cInfo['onGrid3Kw'] ?? '';
    final onGrid4 = cInfo['onGrid4kW'] ?? cInfo['onGrid4Kw'] ?? '';
    final onGrid5 = cInfo['onGrid5kW'] ?? cInfo['onGrid5Kw'] ?? '';

    final hybrid3 = cInfo['hybrid3kW'] ?? cInfo['hybrid3Kw'] ?? '';
    final hybrid4 = cInfo['hybrid4kW'] ?? cInfo['hybrid4Kw'] ?? '';
    final hybrid5 = cInfo['hybrid5kW'] ?? cInfo['hybrid5Kw'] ?? '';

    final inverter = cInfo['inverterName'] ?? cInfo['inverterSpec'] ?? '';
    final battery = cInfo['batteryName'] ?? cInfo['batterySpec'] ?? '';

    if (legalName.toString().isNotEmpty) legalNameController.text = legalName.toString();
    if (compName.toString().isNotEmpty) companyNameController.text = compName.toString();
    if (gstName.toString().isNotEmpty) gstNameController.text = gstName.toString();
    if (gstNumber.toString().isNotEmpty) gstNumberController.text = gstNumber.toString();
    if (phone.toString().isNotEmpty) phoneController.text = phone.toString();
    if (targetLoc.toString().isNotEmpty) targetedLocationController.text = targetLoc.toString();
    if (fullAddr.toString().isNotEmpty) fullAddressController.text = fullAddr.toString();

    if (onGrid3.toString().isNotEmpty) onGrid3kWController.text = onGrid3.toString();
    if (onGrid4.toString().isNotEmpty) onGrid4kWController.text = onGrid4.toString();
    if (onGrid5.toString().isNotEmpty) onGrid5kWController.text = onGrid5.toString();

    if (hybrid3.toString().isNotEmpty) hybrid3kWController.text = hybrid3.toString();
    if (hybrid4.toString().isNotEmpty) hybrid4kWController.text = hybrid4.toString();
    if (hybrid5.toString().isNotEmpty) hybrid5kWController.text = hybrid5.toString();

    if (inverter.toString().isNotEmpty) inverterSpecController.text = inverter.toString();
    if (battery.toString().isNotEmpty) batterySpecController.text = battery.toString();
  }

  Future<void> fetchClientInfoFromApi() async {
    try {
      final targetKey = resolveTargetPasskey();
      if (targetKey.isEmpty) return;

      var res = await httpRequest(
        REQUEST.get,
        "$getPasskeyDetailsApiEndPoint$targetKey",
        {},
      );

      if (res != null && res["success"] == true && res["data"] != null) {
        final Map<String, dynamic> passkeyData =
            Map<String, dynamic>.from(res["data"]);
        final Map<String, dynamic> cInfo = passkeyData['clientInfo'] is Map
            ? Map<String, dynamic>.from(passkeyData['clientInfo'])
            : {};

        if (passkeyData['name'] != null &&
            (cInfo['companyName'] == null || cInfo['companyName'].toString().isEmpty)) {
          cInfo['companyName'] = passkeyData['name'];
        }

        targetPasskeyStr = passkeyData['passkey']?.toString() ??
            passkeyData['_id']?.toString() ??
            targetKey;
        targetPasskeyId = passkeyData['_id']?.toString() ?? targetPasskeyStr;

        await storage.write('clientInfo_$targetKey', cInfo);
        await storage.write('clientInfo', cInfo);
        await storage.write('savedClientSetup', cInfo);

        populateFromMap(cInfo, passkeyData);
      }
    } catch (e) {
      debugPrint("fetchClientInfoFromApi error: $e");
    }
  }

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

    final targetKey = resolveTargetPasskey();

    final body = {
      if (targetKey.isNotEmpty) "passkey": targetKey,
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

      if (res != null && res["success"] == false) {
        showMySnackBar(res["message"] ?? "Failed to update business details", alert: true);
        return;
      }

      // 1. Update passkey-specific storage
      if (targetKey.isNotEmpty) {
        await storage.write('clientInfo_$targetKey', body);
      }
      await storage.write('savedClientSetup', body);
      await storage.write('clientInfo', body);

      // 2. If user is a client (not admin), update user data model
      if (!isViewingClient() && userData.role != 'admin') {
        final Map<String, dynamic> rawUser = Map<String, dynamic>.from(storage.read(LocalKeys.userData) ?? {});
        rawUser['isSetupComplete'] = true;
        rawUser['clientInfo'] = body;
        await storage.write(LocalKeys.userData, rawUser);
      }

      // 3. If Admin updated, sync with ClientManagementController and ClientDetailController
      if (Get.isRegistered<ClientManagementController>()) {
        final mgmt = Get.find<ClientManagementController>();
        final idx = mgmt.clients.indexWhere((c) => c.id == targetKey);
        if (idx != -1) {
          final old = mgmt.clients[idx];
          mgmt.clients[idx] = AccessClientModel(
            id: old.id,
            name: companyName,
            rank: old.rank,
            phone: phone,
            location: targetedLocation,
            company: companyName,
            createdAt: old.createdAt,
            active: old.isActive.value,
          );
        }
      }

      if (Get.isRegistered<ClientDetailController>()) {
        final detailCtrl = Get.find<ClientDetailController>();
        if (detailCtrl.client.passkey == targetKey) {
          detailCtrl.client = ClientModel(
            rank: detailCtrl.client.rank,
            name: companyName,
            company: companyName,
            phone: phone,
            location: targetedLocation,
            passkey: detailCtrl.client.passkey,
          );
          detailCtrl.update();
        }
      }

      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchLeads();
      }

      if (isFromMenu) {
        showMySnackBar("Business details updated successfully!", success: true);
        Get.back();
      } else {
        showMySnackBar("Client setup completed successfully!", success: true);
        Get.offAllNamed(AppRoutes.mainScreen);
      }
    } catch (e) {
      hideCircularLoader();
      if (targetKey.isNotEmpty) {
        await storage.write('clientInfo_$targetKey', body);
      }
      await storage.write('savedClientSetup', body);
      await storage.write('clientInfo', body);

      if (isFromMenu) {
        showMySnackBar("Business details updated successfully!", success: true);
        Get.back();
      } else {
        showMySnackBar(e.toString(), error: true);
      }
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
