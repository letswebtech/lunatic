import 'package:chat/src/services/encryption/encryption_service_contract.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionService implements IEncryptionService {
  final Encrypter _encrypter;
  final _iv = IV.fromLength(16);

  EncryptionService(this._encrypter);

  @override
  String decrypt(String encryptedText) {
    //lets first convet it to base64
    final encrypted = Encrypted.fromBase64(encryptedText);

    //now decrypt
    return _encrypter.decrypt(encrypted, iv: _iv);
  }

  @override
  String encrypt(String text) {
    //encrypt and than return base64
    return _encrypter.encrypt(text, iv: _iv).base64;
  }
}
