import 'dart:convert';

import 'package:encrypt/encrypt.dart';

String encryptMap(Map<String, dynamic> map) {
  final key = Key.fromUtf8(encryptKey); // 16-byte key
  final iv = IV.fromUtf8(encryptIV);  // 16-byte IV
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

  final jsonMap = json.encode(map);
  final encrypted = encrypter.encrypt(jsonMap, iv: iv);

  // Convert to URL-safe Base64
  return base64Url.encode(encrypted.bytes);
}

const encryptKey = 'a8B3fK6mP9rS2vYz';
const encryptIV = 'g4H8jQ1vX5lN0cW2';