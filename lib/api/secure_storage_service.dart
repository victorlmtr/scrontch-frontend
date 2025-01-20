import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  // Save a value with a key
  Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Retrieve a value by key
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // Delete a value by key
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // Clear all stored values
  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
