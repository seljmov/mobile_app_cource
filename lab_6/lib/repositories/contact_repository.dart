import 'package:hive/hive.dart';
import 'package:lab_6/models/contact_model.dart';

class ContactRepository {
  static const String _contactBoxKey = "_contact_box_key";

  Future<List<ContactModel>> getContacts() async {
    final box = await Hive.openBox<ContactModel>(_contactBoxKey);
    final values = box.values;
    await box.close();

    return values.toList();
  }

  Future<void> addContact(ContactModel contact) async {
    final box = await Hive.openBox<ContactModel>(_contactBoxKey);
    await box.put(contact.phone, contact);
    await box.close();
  }

  Future<void> removeContact(String phone) async {
    final box = await Hive.openBox<ContactModel>(_contactBoxKey);
    await box.delete(phone);
    await box.close();
  }
}
