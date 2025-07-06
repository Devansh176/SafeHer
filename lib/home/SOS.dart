import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_ui/home_bloc/alert/alert.dart';
import 'home_ui/home_bloc/call/call_bloc.dart';
import 'home_ui/home_bloc/contacts/contacts_bloc.dart';
import 'home_ui/home_bloc/location/location_sharing_bloc.dart';
import 'home_ui/home_bloc/location_contacts/location_contacts_bloc.dart';
import 'home_ui/home_bloc/location_contacts/location_contacts_state.dart';

class SOSHandler {
  static Future<void> triggerSOS(BuildContext context, Function setAlertPlaying) async {
    // 1. Play alert sound
    await playAlertSound();
    setAlertPlaying(true);

    // 2. Call first emergency contact
    final callState = context.read<ContactsBloc>().state;
    if (callState is ContactsLoaded && callState.selectedContacts.isNotEmpty) {
      final firstContact = callState.selectedContacts.first;
      if (firstContact.phones.isNotEmpty) {
        final number = firstContact.phones.first.number;
        context.read<CallBloc>().add(CallRequest(phoneNumber: number));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No emergency call contacts found ❌")),
      );
    }

    // 3. Send emergency location
    final locationState = context.read<LocationContactsBloc>().state;
    if (locationState is LocationContactsLoaded &&
        locationState.selectedLocationContacts.isNotEmpty) {
      context.read<LocationSharingBloc>().add(
        ShareLocationEvent(selectedContacts: locationState.selectedLocationContacts),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No location contacts selected ❌")),
      );
    }
  }
}
