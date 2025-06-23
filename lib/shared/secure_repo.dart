import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

class MyStore {

  static void writeToStore(tokenVal) async {
    await storage.write(key: 'token', value: tokenVal);
  }
  
  static Future<String?> readFromStore() async {
    var value = await storage.read(key: 'token');
    return value;
  }
}