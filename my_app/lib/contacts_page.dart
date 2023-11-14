import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:sqflite/sqflite.dart';
import './Backend/Database.dart';


class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    fetchContacts();
   
  }

 

  Future<List<MyContact>> getContactsFromDatabase() async {
    Database db = await DatabaseHelper().database;
    List<Map<String, dynamic>> maps = await db.query('contact');
    return List.generate(maps.length, (index) => MyContact.fromMap(maps[index]));
  }

  Future<void> fetchContacts() async {
    final contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts.toList();
    });
  }

  Future<bool> isContactInDatabase(Contact contact) async {
  Database db = await DatabaseHelper().database;
  List<Map<String, dynamic>> maps = await db.query(
    'contact',
    where: 'name = ? AND phone = ?',
    whereArgs: [contact.displayName, contact.phones?.first.value],
  );
  return maps.isNotEmpty;
}

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text(
          'Contacts',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];

          return FutureBuilder<bool>(
            future: isContactInDatabase(contact),
            builder: (context, snapshot) {
              final isDatabaseContact = snapshot.data ?? false;

              return ListTile(
                title: Text(
                  contact.displayName ?? '',
                  style: TextStyle(
                    color: isDatabaseContact ? Colors.blue : Colors.white,
                  ),
                ),
                subtitle: Text(
                  contact.phones?.first.value ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  if (!isDatabaseContact) {
                    MyContact newContact = MyContact(
                      name: contact.displayName ?? '',
                      phone: contact.phones?.first.value ?? '',
                    );
                    int insertedId = await DatabaseHelper().insertContact(newContact);
                    print('Contact inserted with ID: $insertedId');

                    // Refresh the contacts list
                    fetchContacts();
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}






