import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home_ui/home_bloc/location_contacts/location_contacts_bloc.dart';
import '../home_ui/home_bloc/location_contacts/location_contacts_event.dart';
import '../home_ui/home_bloc/location_contacts/location_contacts_state.dart';
import 'contact_selection_page.dart';

class LocationContactsPage extends StatelessWidget {
  const LocationContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<LocationContactsBloc>().add(FetchSavedLocationContactsEvent());

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Location Contacts",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF556B2F).withOpacity(0.85), // Dark olive
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GenericContactSelectionPage(
                    title: 'Select Contacts for Location Sharing',
                    bloc: context.read<LocationContactsBloc>(),
                    onContactAdd: (contact) {
                      context
                          .read<LocationContactsBloc>()
                          .add(AddLocationContactEvent(contact: contact));
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
          child: BlocBuilder<LocationContactsBloc, LocationContactsState>(
            builder: (context, state) {
              if (state is LocationContactsLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFB0C961)),
                );
              } else if (state is LocationContactsLoaded) {
                if (state.selectedLocationContacts.isEmpty) {
                  return Center(
                    child: Text(
                      "No location contacts selected",
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
                  itemCount: state.selectedLocationContacts.length,
                  itemBuilder: (context, index) {
                    final contact = state.selectedLocationContacts[index];

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
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
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
                              child: Icon(Icons.location_on, color: Colors.white, size: width * 0.06),
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
                                context
                                    .read<LocationContactsBloc>()
                                    .add(RemoveLocationContactEvent(contact: contact));
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else if (state is LocationContactsError) {
                return Center(
                  child: Text(
                    state.message,
                    style: GoogleFonts.poppins(
                        color: Colors.redAccent, fontWeight: FontWeight.w500),
                  ),
                );
              } else {
                return const Center(
                  child: Text(
                    "Unexpected error occurred",
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
