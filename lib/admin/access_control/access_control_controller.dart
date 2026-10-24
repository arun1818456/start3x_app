import 'dart:math';
import 'package:flutter/services.dart';
import 'package:start3x_app/exports.dart';

class AccessClientModel {
  final String id;
  String rank;
  final String name;
  final String passkey;

  AccessClientModel({
    required this.id,
    required this.rank,
    required this.name,
    required this.passkey,
  });
}

class AccessControlController extends GetxController with BaseClass {
  var generatedPasskey = '000000000000'.obs;
  var searchQuery = ''.obs;

  final RxList<AccessClientModel> clients = <AccessClientModel>[
    AccessClientModel(
        id: '1', rank: '#1', name: 'Ramanabda', passkey: '8dffbe67y3b'),
    AccessClientModel(
        id: '2', rank: '#2', name: 'Ramanabda', passkey: '8dffbe67y3b'),
    AccessClientModel(
        id: '3', rank: '#3', name: 'Ramanabda', passkey: '8dffbe67y3b'),
    AccessClientModel(
        id: '4', rank: '#4', name: 'Ramanabda', passkey: '8dffbe67y3b'),
    AccessClientModel(
        id: '5', rank: '#5', name: 'Ramanabda', passkey: '8dffbe67y3b'),
  ].obs;

  List<AccessClientModel> get filteredClients {
    if (searchQuery.value.trim().isEmpty) {
      return clients;
    }
    final q = searchQuery.value.toLowerCase().trim();
    return clients.where((c) {
      return c.rank.toLowerCase().contains(q) ||
          c.name.toLowerCase().contains(q) ||
          c.passkey.toLowerCase().contains(q);
    }).toList();
  }

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  void generatePasskey() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final newPasskey =
        List.generate(12, (index) => chars[random.nextInt(chars.length)]).join();

    generatedPasskey.value = newPasskey;

    final newClient = AccessClientModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      rank: '#${clients.length + 1}',
      name: 'Ramanabda',
      passkey: newPasskey,
    );

    clients.add(newClient);

    showMySnackBar('New Passkey: $newPasskey', success: true);
  }

  void copyPasskeyToClipboard() {
    if (generatedPasskey.value != '000000000000') {
      Clipboard.setData(ClipboardData(text: generatedPasskey.value));
      showMySnackBar('Passkey copied to clipboard!', success: true);
    }
  }

  void removeClient(AccessClientModel client) {
    clients.remove(client);
    _updateRanks();
    showMySnackBar(
      'Client ${client.rank} removed from access control',
      alert: true,
    );
  }

  void _updateRanks() {
    for (int i = 0; i < clients.length; i++) {
      clients[i].rank = '#${i + 1}';
    }
    clients.refresh();
  }
}
