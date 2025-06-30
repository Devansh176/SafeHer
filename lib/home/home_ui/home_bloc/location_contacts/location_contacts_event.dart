import 'package:equatable/equatable.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

abstract class LocationContactsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchSavedLocationContactsEvent extends LocationContactsEvent {}

class AddLocationContactEvent extends LocationContactsEvent {
  final Contact contact;
  AddLocationContactEvent({required this.contact});

  @override
  List<Object> get props => [contact];
}

class RemoveLocationContactEvent extends LocationContactsEvent {
  final Contact contact;
  RemoveLocationContactEvent({required this.contact});

  @override
  List<Object> get props => [contact];
}
