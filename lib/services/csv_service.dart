import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import '../models/contact.dart';

Future<List<Contact>> importContactsFromCSV(File file) async {
  final input = file.openRead();
  final fields = await input
      .transform(utf8.decoder)
      .transform(CsvToListConverter())
      .toList();

  return fields.map((field) {
    return Contact(name: field[0], phoneNumber: field[1]);
  }).toList();
}
