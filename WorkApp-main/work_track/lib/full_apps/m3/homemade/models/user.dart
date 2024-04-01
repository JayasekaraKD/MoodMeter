import 'dart:convert';

import 'package:flutter/services.dart';

enum UserRole { user, admin }

class Usr {
  String name;
  String email;
  UserRole role;

  Usr({required this.name, required this.email, required this.role});

  static Future<List<Usr>> getDummyList() async {
    dynamic data = json.decode(await getData());
    return getListFromJson(data);
  }

  static Future<Usr> getOne() async {
    return (await getDummyList())[0];
  }

  static Usr fromJson(Map<String, dynamic> jsonObject) {
    String name = jsonObject['name'].toString();
    String email = jsonObject['email'].toString();
    String role = jsonObject['role'].toString();

    return Usr(
        name: name,
        email: email,
        role: UserRole.values
            .firstWhere((e) => e.toString() == 'UserRole.$role'));
  }

  static List<Usr> getListFromJson(List<dynamic> jsonArray) {
    List<Usr> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(Usr.fromJson(jsonArray[i]));
    }
    return list;
  }

  static Future<String> getData() async {
    return await rootBundle
        .loadString('assets/full_apps/m3/homemade/data/users.json');
  }

  @override
  String toString() {
    return 'User{name: $name, email: $email, role: $role}';
  }
}
