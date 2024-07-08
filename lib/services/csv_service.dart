import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import '../models/contact.dart';

//Method that handles the csv file and returns contact information
Future<List<Contact>> importContactsFromCSV(File file) async {
  final input = file.openRead();
  final fields = await input
      .transform(utf8.decoder)
      .transform(const CsvToListConverter())
      .toList();

//Set specific to Stakeholder CSV format for now
  return fields.skip(1).map((row) {
    final firstName = row[1];
    final lastName = row[2];
    final phoneNumber = row[5].toString();
    final memberType = row[3];

    return Contact(
      name: '$firstName $lastName',
      phoneNumber: phoneNumber,
      memberType: memberType,
    );
  }).toList();
}
