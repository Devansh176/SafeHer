import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../home_ui/home_bloc/location_contacts/location_contacts_bloc.dart';
import '../home_ui/home_bloc/location_contacts/location_contacts_event.dart';
import '../home_ui/home_bloc/location_contacts/location_contacts_state.dart';
import 'contact_selection_page.dart';


class LocationContactsPage extends StatelessWidget {
  const LocationContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<LocationContactsBloc>().add(FetchSavedLocationContactsEvent());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacts to Send Location"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GenericContactSelectionPage(
                    title: 'Select Contacts for Location Sharing',
                    bloc: context.read<LocationContactsBloc>(),
                    onContactAdd: (contact) {
                      context.read<LocationContactsBloc>().add(AddLocationContactEvent(contact: contact));
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<LocationContactsBloc, LocationContactsState>(
        builder: (context, state) {
          if (state is LocationContactsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LocationContactsLoaded) {
            if (state.selectedLocationContacts.isEmpty) {
              return const Center(child: Text("No location contacts selected"));
            }
            return ListView.builder(
              itemCount: state.selectedLocationContacts.length,
              itemBuilder: (context, index) {
                final contact = state.selectedLocationContacts[index];
                return ListTile(
                  title: Text(contact.displayName),
                  subtitle: Text(contact.phones.isNotEmpty ? contact.phones[0].number : "No Number"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      context.read<LocationContactsBloc>().add(RemoveLocationContactEvent(contact: contact));
                    },
                  ),
                );
              },
            );
          } else if (state is LocationContactsError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text("Unexpected error occurred"));
        },
      ),
    );
  }
}
