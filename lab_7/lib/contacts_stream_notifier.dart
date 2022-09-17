import 'package:flutter/foundation.dart';

import 'models/contact_model.dart';
import 'repositories/contact_repository.dart';

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
