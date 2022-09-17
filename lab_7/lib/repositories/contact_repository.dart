import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contact_model.dart';

class ContactRepository {
  final _firebase = FirebaseFirestore.instance;
  static const String _contactCollectionName = "contacts";

  Future<List<ContactModel>> getContacts() async {
    final contacts = await _firebase.collection(_contactCollectionName).get();
    final contactsDoc = contacts.docs;
    return List.from(contactsDoc.map((e) => ContactModel.fromJson(e.data())));
  }

  Future<void> addContact(ContactModel contact) async {
    await _firebase.collection(_contactCollectionName).add(contact.toJson());
  }

  Future<void> removeContact(String phone) async {
    final batch = _firebase.batch();
    final contact = await _firebase
        .collection(_contactCollectionName)
        .where("phone", isEqualTo: phone)
        .get();
    final contactDoc = contact.docs.first;
    batch.delete(contactDoc.reference);
    await batch.commit();
  }
}
