import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mint_connection.dart';
import '../models/drop_transaction.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static const _activeMintKey = 'active_mint_url';
  static const _knownMintsKey = 'known_mints';
  static const _developerModeKey = 'developer_mode';
  static const _useMockWalletKey = 'use_mock_wallet';
  static const _transactionsKey = 'wallet_transactions';

  Future<void> setActiveMintUrl(String? url) async {
    if (url == null) {
      await _prefs.remove(_activeMintKey);
    } else {
      await _prefs.setString(_activeMintKey, url);
    }
  }

  String? getActiveMintUrl() {
    return _prefs.getString(_activeMintKey);
  }

  Future<void> saveKnownMints(List<MintConnection> mints) async {
    final list = mints.map((m) => jsonEncode(m.toJson())).toList();
    await _prefs.setStringList(_knownMintsKey, list);
  }

  List<MintConnection> getKnownMints() {
    final list = _prefs.getStringList(_knownMintsKey);
    if (list == null) return [];
    try {
      return list.map((item) => MintConnection.fromJson(jsonDecode(item))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> setDeveloperMode(bool enabled) async {
    await _prefs.setBool(_developerModeKey, enabled);
  }

  bool getDeveloperMode() {
    return _prefs.getBool(_developerModeKey) ?? false;
  }

  Future<void> setUseMockWallet(bool useMock) async {
    await _prefs.setBool(_useMockWalletKey, useMock);
  }

  bool getUseMockWallet() {
    return _prefs.getBool(_useMockWalletKey) ?? true;
  }

  Future<void> saveTransactions(List<DropTransaction> transactions) async {
    final list = transactions.map((t) => jsonEncode(t.toJson())).toList();
    await _prefs.setStringList(_transactionsKey, list);
  }

  List<DropTransaction> getTransactions() {
    final list = _prefs.getStringList(_transactionsKey);
    if (list == null) return [];
    try {
      return list.map((item) => DropTransaction.fromJson(jsonDecode(item))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
