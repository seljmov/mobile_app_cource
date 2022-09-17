import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'contact_model.g.dart';

@HiveType(typeId: 0)
class ContactModel extends Equatable {
  @HiveField(0)
  final String phone;

  @HiveField(1)
  final String name;

  const ContactModel({
    required this.name,
    required this.phone,
  });

  @override
  List<Object?> get props => [phone, name];
}
