import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import '../models/contact.dart';

// Method that handles the csv file and returns contact information
Future<List<Contact>> importContactsFromCSV(File file) async {
  try {
    final input = file.openRead(); // Open the file as a stream
    final fields = await input
        .transform(utf8.decoder) // Decode the input to UTF8
        .transform(const CsvToListConverter()) // Convert CSV to List
        .toList();

    // Debugging statement to print out the parsed CSV data
    print('Parsed CSV fields: $fields');

    // Skip the header row and map the remaining rows to Contact objects
    return fields.skip(1).map((row) {
      // Read columns by index:
      // 1: First Name, 2: Last Name, 5: Mobile, 3: Contact Type
      final firstName = row[1];
      final lastName = row[2];
      final phoneNumber = row[5].toString();
      final memberType = row[3];

      // Print parsed contact details for debugging
      print('Parsed contact: $firstName $lastName, $phoneNumber, $memberType');

      return Contact(
        name: '$firstName $lastName',
        phoneNumber: phoneNumber,
        memberType: memberType,
      );
    }).toList();
  } catch (e) {
    // Log the error
    print('Error importing CSV: $e');
    return [];
  }
}
