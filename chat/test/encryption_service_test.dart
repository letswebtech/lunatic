import 'package:chat/src/services/encryption/encryption_service_impl.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late EncryptionService sut;

  setUp(() async {
    final encypter = Encrypter(AES(Key.fromLength(32)));
    sut = EncryptionService(encypter);
  });

  test('its encrypt the plain text', () async {
    final base64Reg = RegExp(
        r'^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$');

    String plainText = "Hello World";
    String encryptedText = sut.encrypt(plainText);

    expect(base64Reg.hasMatch(encryptedText), true);
  });

  test('its decrypt the encrypted text', () async {
    String plainText = "Hello World";
    String encryptedText = sut.encrypt(plainText);

    String decryptedText = sut.decrypt(encryptedText);

    expect(plainText, decryptedText);
  });
}
