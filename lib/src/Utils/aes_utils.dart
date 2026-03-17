/* 
@autor    : karthick.d  18/07/2025
@desc     : encapsualtes utility methods of AES encryption and decryption

 */
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import 'dart:convert';
import 'dart:typed_data';

import 'package:sysmo_verification/src/core/api/app_constant.dart';

String _normalizeBase64(String input) {
  var normalized = input.replaceAll('-', '+').replaceAll('_', '/');
  final padding = normalized.length % 4;
  if (padding > 0) {
    normalized += '=' * (4 - padding);
  }
  return normalized;
}

// Decryption by OpenSSL/CryptoJS salted format
// Returns key+iv derived via EVP_BytesToKey (OpenSSL/CryptoJS compatible)
Map<String, Uint8List> _evpBytesToKey({
  required Uint8List password,
  required Uint8List salt,
  required int keyLen,
  required int ivLen,
}) {
  final targetLen = keyLen + ivLen;
  final List<int> derived = [];
  List<int> block = [];

  // You must keep MD5 if the backend encryption uses OpenSSL’s salted format.
  while (derived.length < targetLen) {
    final input = <int>[...block, ...password, ...salt];
    block = md5.convert(input).bytes; // OpenSSL default for this format
    derived.addAll(block);
  }

  return {
    'key': Uint8List.fromList(derived.sublist(0, keyLen)),
    'iv': Uint8List.fromList(derived.sublist(keyLen, keyLen + ivLen)),
  };
}

bool _isOpenSslSalted(Uint8List bytes) {
  if (bytes.length < 16) return false;
  const sig = 'Salted__';
  final sigBytes = ascii.encode(sig);
  for (var i = 0; i < sigBytes.length; i++) {
    if (bytes[i] != sigBytes[i]) return false;
  }
  return true;
}

String decryptString({required String encryptedText}) {
  try {
    final raw = encryptedText.trim();
    final parts = raw.split(':');

    // Existing app format: iv:cipher
    if (parts.length == 2) {
      final key = encrypt.Key.fromUtf8(AppConstant.encKey);
      final iv = encrypt.IV.fromBase64(_normalizeBase64(parts[0]));
      final cipherText = _normalizeBase64(parts[1]);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );
      return encrypter.decrypt64(cipherText, iv: iv);
    }

    // Try OpenSSL/CryptoJS salted format
    final decoded = base64.decode(_normalizeBase64(raw));
    if (_isOpenSslSalted(decoded)) {
      final salt = decoded.sublist(8, 16);
      final cipherBytes = decoded.sublist(16);

      // Most likely AES-256-CBC with passphrase
      final pass = Uint8List.fromList(utf8.encode(AppConstant.encKey));
      final dk = _evpBytesToKey(
        password: pass,
        salt: Uint8List.fromList(salt),
        keyLen: 32,
        ivLen: 16,
      );

      final key = encrypt.Key(dk['key']!);
      final iv = encrypt.IV(dk['iv']!);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );
      var res = encrypter.decrypt(
        encrypt.Encrypted(Uint8List.fromList(cipherBytes)),
        iv: iv,
      );

      return res;
    }

    // Existing legacy fallback
    final key = encrypt.Key.fromUtf8(AppConstant.encKey);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );
    return encrypter.decrypt64(_normalizeBase64(raw), iv: iv);
  } catch (e) {
    print('Decryption failed: $e');
    return '';
  }
}

// Encryption by OpenSSL/CryptoJS salted format
Uint8List _secureRandomBytes(int length) {
  final rnd = Random.secure();
  return Uint8List.fromList(
    List<int>.generate(length, (_) => rnd.nextInt(256)),
  );
}

String encryptString({required String inputText}) {
  // 1) OpenSSL salted format uses 8-byte random salt
  final salt = _secureRandomBytes(8);

  // 2) Derive key+iv exactly like decryptString2 (_evpBytesToKey)
  final pass = Uint8List.fromList(utf8.encode(AppConstant.encKey));
  final dk = _evpBytesToKey(
    password: pass,
    salt: salt,
    keyLen: 32, // AES-256 key
    ivLen: 16, // AES block-size IV
  );

  final key = encrypt.Key(dk['key']!);
  final iv = encrypt.IV(dk['iv']!);

  // 3) Encrypt plaintext bytes with AES-CBC PKCS7
  final encrypter = encrypt.Encrypter(
    encrypt.AES(key, mode: encrypt.AESMode.cbc),
  );
  final encrypted = encrypter.encryptBytes(utf8.encode(inputText), iv: iv);

  // 4) Build OpenSSL payload: "Salted__" + salt + ciphertext
  final saltedPrefix = ascii.encode('Salted__');
  final out = Uint8List(
    saltedPrefix.length + salt.length + encrypted.bytes.length,
  );
  out.setRange(0, saltedPrefix.length, saltedPrefix);
  out.setRange(saltedPrefix.length, saltedPrefix.length + salt.length, salt);
  out.setRange(saltedPrefix.length + salt.length, out.length, encrypted.bytes);

  // 5) Base64 string (starts with U2FsdGVkX1...)
  final result = base64.encode(out);
  print('AES OpenSSL salted encrypted base64 => $result');
  return result;
}
 