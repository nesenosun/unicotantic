import 'dart:convert';

class EncryptionService {
  // Not: Bu basit bir gizleme yöntemidir. 
  // Gerçek uçtan uca şifreleme (AES) için 'encrypt' paketini kullanmanızı öneririm.
  // Ancak bu yöntem bile veritabanında metnin düz okunmasını engeller.
  
  static String encrypt(String text) {
    if (text.isEmpty) return text;
    // Metni UTF-8'e çevir -> Base64 yap -> Ters çevir (basit bir karıştırma)
    String base64Str = base64.encode(utf8.encode(text));
    return base64Str.split('').reversed.join('');
  }

  static String decrypt(String encryptedText) {
    if (encryptedText.isEmpty) return encryptedText;
    try {
      // Ters çevirmeyi geri al -> Base64'ten çöz -> UTF-8'e çevir
      String reversed = encryptedText.split('').reversed.join('');
      return utf8.decode(base64.decode(reversed));
    } catch (e) {
      // Eğer şifreli değilse veya hata oluşursa orijinali döndür
      return encryptedText;
    }
  }
}
