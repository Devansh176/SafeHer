import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home_ui/home_bloc/contacts/contacts_bloc.dart';
import 'contact_selection_page.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<ContactsBloc>().add(FetchSavedContactsEvent());

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Contacts to Call",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF556B2F).withOpacity(0.85), // Olive app bar
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GenericContactSelectionPage(
                    title: 'Select Contacts to Call',
                    bloc: context.read<ContactsBloc>(),
                    onContactAdd: (contact) {
                      context.read<ContactsBloc>().add(SelectContactEvent(contact: contact));
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3B5323), Color(0xFF2E3A1F), Color(0xFF1F2815)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<ContactsBloc, ContactsState>(
            builder: (context, state) {
              if (state is ContactsLoading) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFB0C961)));
              } else if (state is ContactsLoaded) {
                if (state.selectedContacts.isEmpty) {
                  return Center(
                    child: Text(
                      "No contacts selected",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.selectedContacts.length,
                  itemBuilder: (context, index) {
                    final contact = state.selectedContacts[index];

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.05),
                            Colors.white.withOpacity(0.02),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.white24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFB0C961),
                              child: Icon(Icons.call, color: Colors.white, size: width * 0.06),
                            ),
                            title: Text(
                              contact.displayName,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: width * 0.045,
                              ),
                            ),
                            subtitle: Text(
                              contact.phones.isNotEmpty
                                  ? contact.phones[0].number
                                  : "No Number",
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: width * 0.036,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                              onPressed: () {
                                context.read<ContactsBloc>().add(RemoveContactEvent(contact: contact));
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else if (state is ContactsError) {
                return Center(
                  child: Text(
                    state.message,
                    style: GoogleFonts.poppins(
                        color: Colors.redAccent, fontWeight: FontWeight.w500),
                  ),
                );
              } else {
                return const Center(
                    child: Text("Unexpected error occurred",
                        style: TextStyle(color: Colors.white70)));
              }
            },
          ),
        ),
      ),
    );
  }
}
