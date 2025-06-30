import 'package:equatable/equatable.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

abstract class LocationContactsState extends Equatable {
  @override
  List<Object> get props => [];
}

class LocationContactsLoading extends LocationContactsState {}

class LocationContactsLoaded extends LocationContactsState {
  final List<Contact> selectedLocationContacts;
  LocationContactsLoaded({required this.selectedLocationContacts});

  @override
  List<Object> get props => [selectedLocationContacts];
}

class LocationContactsError extends LocationContactsState {
  final String message;
  LocationContactsError({required this.message});

  @override
  List<Object> get props => [message];
}
