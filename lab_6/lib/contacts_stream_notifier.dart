import 'package:flutter/material.dart';
import 'package:lab_6/models/contact_model.dart';
import 'package:lab_6/repositories/contact_repository.dart';

class ContactStreamNotifier with ChangeNotifier {
  final _streamNotifier = ValueNotifier<Stream<List<ContactModel>>?>(null);

  Stream<List<ContactModel>> getCurrentStream() {
    if (_streamNotifier.value == null) {
      _updateStream();
    }
    return _streamNotifier.value!;
  }

  void changeState() {
    _updateStream();
    notifyListeners();
  }

  void _updateStream() {
    _streamNotifier.value = ContactRepository().getContacts().asStream();
  }
}
