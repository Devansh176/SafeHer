import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repositories/contacts_repository.dart';
import 'location_contacts_event.dart';
import 'location_contacts_state.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class LocationContactsBloc extends Bloc<LocationContactsEvent, LocationContactsState> {
  final ContactsRepository repository;

  LocationContactsBloc(this.repository) : super(LocationContactsLoading()) {
    on<FetchSavedLocationContactsEvent>((event, emit) async {
      emit(LocationContactsLoading());
      try {
        final contacts = await repository.loadLocationContacts(); // ✅ Correct method
        emit(LocationContactsLoaded(selectedLocationContacts: contacts));
      } catch (e) {
        emit(LocationContactsError(message: e.toString()));
      }
    });

    on<AddLocationContactEvent>((event, emit) async {
      if (state is LocationContactsLoaded) {
        final current = (state as LocationContactsLoaded).selectedLocationContacts;
        final exists = current.any((c) => c.id == event.contact.id);
        if (!exists) {
          final updated = List<Contact>.from(current)..add(event.contact);
          await repository.saveLocationContacts(updated);
          emit(LocationContactsLoaded(selectedLocationContacts: updated));
        }
      }
    });

    on<RemoveLocationContactEvent>((event, emit) async {
      if (state is LocationContactsLoaded) {
        final current = (state as LocationContactsLoaded).selectedLocationContacts;
        final updated = List<Contact>.from(current)..removeWhere((c) => c.id == event.contact.id);
        await repository.saveLocationContacts(updated);
        emit(LocationContactsLoaded(selectedLocationContacts: updated));
      }
    });
  }
}
