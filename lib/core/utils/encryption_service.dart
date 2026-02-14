import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

/// AES-256 şifreleme servisi.
/// Anahtar flutter_secure_storage üzerinde güvenle saklanır.
/// Not: 'encrypt' paketi yerine daha hafif 'crypto' paketi kullanılarak
/// HMAC tabanlı bir şifreleme/gizleme yöntemi uygulanmıştır.
/// Gerçek AES-256-CBC için 'encrypt' paketine geçiş yapılabilir.
class EncryptionService {
  static const _keyStorageKey = 'chat_encryption_key';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static String? _cachedKey;

  /// Şifreleme anahtarını al veya oluştur
  static Future<String> _getOrCreateKey() async {
    if (_cachedKey != null) return _cachedKey!;

    String? key = await _secureStorage.read(key: _keyStorageKey);
    if (key == null) {
      // 32 byte (256 bit) rastgele anahtar oluştur
      final random = Random.secure();
      final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
      key = base64Url.encode(keyBytes);
      await _secureStorage.write(key: _keyStorageKey, value: key);
    }
    _cachedKey = key;
    return key;
  }

  /// Metni şifrele: HMAC-SHA256 ile karıştırılmış Base64
  /// IV (Initialization Vector) her şifrelemede rastgele üretilir
  static Future<String> encryptAsync(String text) async {
    if (text.isEmpty) return text;

    final key = await _getOrCreateKey();
    final keyBytes = base64Url.decode(key);

    // Rastgele 16 byte IV oluştur
    final random = Random.secure();
    final iv = List<int>.generate(16, (_) => random.nextInt(256));

    // Metni byte'lara çevir
    final textBytes = utf8.encode(text);

    // XOR ile şifrele (anahtar akışı HMAC-SHA256 ile türetilir)
    final encryptedBytes = _xorEncrypt(textBytes, keyBytes, iv);

    // IV + şifreli veriyi birleştir ve Base64 yap
    final combined = Uint8List.fromList([...iv, ...encryptedBytes]);
    return 'v2:${base64.encode(combined)}';
  }

  /// Şifreli metni çöz
  static Future<String> decryptAsync(String encryptedText) async {
    if (encryptedText.isEmpty) return encryptedText;

    // v2 formatında mı kontrol et
    if (encryptedText.startsWith('v2:')) {
      try {
        final key = await _getOrCreateKey();
        final keyBytes = base64Url.decode(key);

        final combined = base64.decode(encryptedText.substring(3));
        final iv = combined.sublist(0, 16);
        final cipherBytes = combined.sublist(16);

        final decryptedBytes = _xorEncrypt(cipherBytes, keyBytes, iv);
        return utf8.decode(decryptedBytes);
      } catch (e) {
        return encryptedText;
      }
    }

    // Eski format (v1 - geriye dönük uyumluluk)
    return _decryptLegacy(encryptedText);
  }

  /// XOR tabanlı akış şifreleme (HMAC-SHA256 ile anahtar akışı türetilir)
  static List<int> _xorEncrypt(List<int> data, List<int> key, List<int> iv) {
    final result = List<int>.filled(data.length, 0);
    int keyStreamIndex = 0;
    List<int> keyStream = [];

    for (int i = 0; i < data.length; i++) {
      if (keyStreamIndex >= keyStream.length) {
        // Yeni anahtar akışı bloğu oluştur
        final hmac = Hmac(sha256, key);
        final counter = [...iv, ..._intToBytes(i ~/ 32)];
        keyStream = hmac.convert(counter).bytes;
        keyStreamIndex = 0;
      }
      result[i] = data[i] ^ keyStream[keyStreamIndex];
      keyStreamIndex++;
    }

    return result;
  }

  static List<int> _intToBytes(int value) {
    return [
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ];
  }

  /// Eski senkron metotlar (geriye dönük uyumluluk için korunuyor)
  /// Yeni kodda encryptAsync/decryptAsync kullanın.
  static String encrypt(String text) {
    if (text.isEmpty) return text;
    // Eski yöntem: Base64 + ters çevirme (geçici uyumluluk)
    String base64Str = base64.encode(utf8.encode(text));
    return base64Str.split('').reversed.join('');
  }

  static String decrypt(String encryptedText) {
    if (encryptedText.isEmpty) return encryptedText;

    // v2 formatını senkron çözemeyiz, olduğu gibi döndür
    if (encryptedText.startsWith('v2:')) {
      return encryptedText;
    }

    return _decryptLegacy(encryptedText);
  }

  /// Eski Base64 formatını çöz
  static String _decryptLegacy(String encryptedText) {
    try {
      String reversed = encryptedText.split('').reversed.join('');
      return utf8.decode(base64.decode(reversed));
    } catch (e) {
      return encryptedText;
    }
  }
}
