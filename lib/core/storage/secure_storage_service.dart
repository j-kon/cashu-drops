import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _mnemonicKey = 'wallet_mnemonic';

  Future<void> saveMnemonic(String mnemonic) async {
    await _storage.write(key: _mnemonicKey, value: mnemonic);
  }

  Future<String?> getMnemonic() async {
    return await _storage.read(key: _mnemonicKey);
  }

  Future<void> deleteMnemonic() async {
    await _storage.delete(key: _mnemonicKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
