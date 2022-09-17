import 'dart:convert';

class ContactModel {
  final String phone;
  final String name;

  const ContactModel({
    required this.name,
    required this.phone,
  });

  factory ContactModel.fronRawJson(String raw) =>
      ContactModel.fromJson(json.decode(raw));

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
        name: json["name"] ?? '',
        phone: json["phone"] ?? '',
      );

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        "name": name,
        "phone": phone,
      };
}
