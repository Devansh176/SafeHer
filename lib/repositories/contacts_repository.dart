import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ContactsRepository {
  static const _callContactsKey = 'selected_call_contacts';
  static const _locationContactsKey = 'selected_location_contacts';

  /// 🔁 Fetch all contacts from device
  Future<List<Contact>> fetchAllContacts() async {
    if (await FlutterContacts.requestPermission()) {
      return await FlutterContacts.getContacts(withProperties: true);
    }
    throw Exception("Permission denied");
  }

  /// 📞 Save Call Contacts
  Future<void> saveCallContacts(List<Contact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = contacts.map((c) => _contactToJson(c)).toList();
    await prefs.setString(_callContactsKey, jsonEncode(jsonList));
  }

  /// 📞 Load Call Contacts
  Future<List<Contact>> loadCallContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_callContactsKey);
    if (jsonString == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => contactFromJson(item)).toList();
    } catch (e) {
      await prefs.remove(_callContactsKey);
      return [];
    }
  }

  /// 📍 Save Location Contacts
  Future<void> saveLocationContacts(List<Contact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = contacts.map((c) => _contactToJson(c)).toList();
    await prefs.setString(_locationContactsKey, jsonEncode(jsonList));
  }

  /// 📍 Load Location Contacts
  Future<List<Contact>> loadLocationContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_locationContactsKey);
    if (jsonString == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => contactFromJson(item)).toList();
    } catch (e) {
      await prefs.remove(_locationContactsKey);
      return [];
    }
  }

  /// 🔁 Serialize Contact
  Map<String, dynamic> _contactToJson(Contact contact) {
    return {
      'id': contact.id,
      'displayName': contact.displayName,
      'phones': contact.phones.map((p) => p.number).toList(),
    };
  }

  /// 🔁 Deserialize Contact
  Contact contactFromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      displayName: json['displayName'],
      phones: (json['phones'] as List<dynamic>)
          .map((p) => Phone(p as String))
          .toList(),
    );
  }
}
