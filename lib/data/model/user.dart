class UserFields {
  static const String id = "\$id";
  static const String name = "name";
  static const String email = "email";
  static const String registratioDate = "registration";
  static const String roles = "roles";
}

class AppUser {
  String? id;
  late String email;
  int? registration;
  String? name;
  List<String>? roles;

  AppUser({this.id, required this.email, this.registration, this.name});

  AppUser.fromJson(Map<String, dynamic> json) {
    id = json[UserFields.id];
    email = json[UserFields.email];
    registration = json[UserFields.registratioDate];
    name = json[UserFields.name];
    roles = json[UserFields.roles].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['$id'] = id;
    data['email'] = email;
    data['registration'] = registration;
    data['name'] = name;
    // data['roles'] = this.roles;
    return data;
  }
}
