import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

typedef ContactAddCallback = void Function(Contact contact);

class GenericContactSelectionPage<T extends StateStreamableSource<Object>> extends StatefulWidget {
  final String title;
  final ContactAddCallback onContactAdd;
  final T bloc;

  const GenericContactSelectionPage({
    super.key,
    required this.title,
    required this.onContactAdd,
    required this.bloc,
  });

  @override
  State<GenericContactSelectionPage<T>> createState() => _GenericContactSelectionPageState<T>();
}

class _GenericContactSelectionPageState<T extends StateStreamableSource<Object>> extends State<GenericContactSelectionPage<T>> {
  List<Contact> allContacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllContacts();
  }

  Future<void> _loadAllContacts() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        final contacts = await FlutterContacts.getContacts(withProperties: true);
        setState(() {
          allContacts = contacts;
          isLoading = false;
        });
      } else {
        throw Exception("Permission denied");
      }
    } catch (e) {
      setState(() {
        allContacts = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: allContacts.length,
          itemBuilder: (context, index) {
            final contact = allContacts[index];
            return ListTile(
              title: Text(contact.displayName),
              subtitle: Text(contact.phones.isNotEmpty ? contact.phones[0].number : "No Number"),
              onTap: () {
                widget.onContactAdd(contact);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${contact.displayName} added")),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
