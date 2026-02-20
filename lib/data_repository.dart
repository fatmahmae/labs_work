import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

class DataRepository {
  static final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();


  static String loginName = "";
  static String password = "";

  static String firstName = "";
  static String lastName = "";
  static String phoneNumber = "";
  static String emailAddress = "";


  // loadData() - loads variables from EncryptedSharedPreferences
  static Future<bool> loadData() async {
    // login data
    final l = await _prefs.getString("login");
    final p = await _prefs.getString("password");

    if (l != null) loginName = l;
    if (p != null) password = p ?? "";

    // profile data
    firstName = (await _prefs.getString("firstName")) ?? "";
    lastName = (await _prefs.getString("lastName")) ?? "";
    phoneNumber = (await _prefs.getString("phoneNumber")) ?? "";
    emailAddress = (await _prefs.getString("emailAddress")) ?? "";

    return (l != null && p != null);
  }


  static Future<void> saveData() async {
    await _prefs.setString("firstName", firstName);
    await _prefs.setString("lastName", lastName);
    await _prefs.setString("phoneNumber", phoneNumber);
    await _prefs.setString("emailAddress", emailAddress);
  }


  static Future<void> saveLogin(String l, String p) async {
    loginName = l;
    password = p;
    await _prefs.setString("login", l);
    await _prefs.setString("password", p);
  }


  static Future<void> clearLogin() async {
    loginName = "";
    password = "";
    await _prefs.remove("login");
    await _prefs.remove("password");
  }
}
