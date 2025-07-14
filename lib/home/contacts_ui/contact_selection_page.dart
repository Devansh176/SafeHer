import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final width = MediaQuery.of(context).size.width;

    return BlocProvider.value(
      value: widget.bloc,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(widget.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFFA3B18A).withOpacity(0.85), // Lighter olive
          elevation: 0,
          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFDDE5B6), // Light olive
                Color(0xFFBFD8AF),
                Color(0xFFA3B18A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF52734D)))
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: allContacts.length,
              itemBuilder: (context, index) {
                final contact = allContacts[index];

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.03),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.black12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF52734D),
                          child: Icon(Icons.person, color: Colors.white, size: width * 0.05),
                        ),
                        title: Text(
                          contact.displayName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: width * 0.04,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          contact.phones.isNotEmpty ? contact.phones[0].number : "No Number",
                          style: GoogleFonts.poppins(
                            color: Colors.black54,
                            fontSize: width * 0.035,
                          ),
                        ),
                        onTap: () {
                          widget.onContactAdd(contact);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${contact.displayName} added",
                                  style: GoogleFonts.poppins()),
                              backgroundColor: const Color(0xFF52734D),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
