import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'contacts_stream_notifier.dart';
import 'firebase_options.dart';
import 'models/contact_model.dart';
import 'repositories/contact_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ConfigureApp());
}

class ConfigureApp extends StatelessWidget {
  const ConfigureApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ContactStreamNotifier(),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StartApp(),
      ),
    );
  }
}

class StartApp extends StatelessWidget {
  const StartApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactStreamNotifier>(
      builder: (context, notifier, child) {
        final currentStream = notifier.getCurrentStream();
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
          ),
          body: StreamBuilder<List<ContactModel>>(
            stream: currentStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError || snapshot.error != null) {
                return const Center(
                  child: Text("Что-то пошло не так..."),
                );
              }

              final data = snapshot.data ?? [];
              return Visibility(
                visible: data.isEmpty,
                child: const Center(
                  child: Text("Нет контактов"),
                ),
                replacement: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: List.generate(
                      data.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                data[index].name[0],
                              ),
                            ),
                            title: Text(data[index].name),
                            subtitle: Text(data[index].phone),
                            trailing: GestureDetector(
                              onTap: () async {
                                await ContactRepository()
                                    .removeContact(data[index].phone)
                                    .whenComplete(() => notifier.changeState());
                              },
                              child: const DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.redAccent,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child: Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async => await ContactAddDialog.show(
              context: context,
              onDone: () => notifier.changeState(),
            ),
            child: const Icon(Icons.add_call),
          ),
        );
      },
    );
  }
}

class ContactAddDialog {
  static Future<void> show({
    required BuildContext context,
    void Function()? onDone,
  }) async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Добавить контакт"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Имя",
                  labelStyle: TextStyle(
                    color: Color(0xFF727272),
                  ),
                  hintText: "Введите имя",
                ),
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: "Номер телефона",
                  labelStyle: TextStyle(
                    color: Color(0xFF727272),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            MaterialButton(
              color: Colors.redAccent,
              textColor: Colors.white,
              child: const Text("Отменить"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            MaterialButton(
              color: Colors.green,
              textColor: Colors.white,
              child: const Text("Добавить"),
              onPressed: () async {
                final contact = ContactModel(
                  name: nameController.text,
                  phone: phoneController.text,
                );
                await ContactRepository().addContact(contact).whenComplete(() {
                  Navigator.of(context).pop();
                  onDone?.call();
                });
              },
            ),
          ],
        );
      },
    );
  }
}
