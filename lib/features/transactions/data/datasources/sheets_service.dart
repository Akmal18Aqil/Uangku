import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/transaction.dart';
import '../models/transaction_model.dart';

class SheetsService {
  // TODO: GANTI URL INI DENGAN URL DEPLOYMENT GOOGLE APPS SCRIPT ANDA
  static const String apiUrl = 'isi';
  Future<List<Transaction>> getTransactions() async {
    try {
      var response = await http.get(Uri.parse(apiUrl));

      // Handle Redirects manually just in case
      if (response.statusCode == 302) {
        final location = response.headers['location'];
        if (location != null) {
          response = await http.get(Uri.parse(location));
        }
      }

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        List<dynamic> data = [];

        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map) {
          // Check common keys for wrapped data
          if (decoded.containsKey('data')) {
            data = decoded['data'];
          } else if (decoded.containsKey('items')) {
            data = decoded['items'];
          } else if (decoded.containsKey('transactions')) {
            data = decoded['transactions'];
          }
        }

        return data.map((json) => TransactionModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  Future<bool> addTransaction(Transaction transaction) async {
    try {
      // Convert User Entity to Model to get access to toJson()
      final model = TransactionModel.fromEntity(transaction);

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(model.toJson()),
      );

      // Handle Google Apps Script Redirect (302)
      if (response.statusCode == 302) {
        final location = response.headers['location'];
        if (location != null) {
          response = await http.get(Uri.parse(location));
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        // Handle GAS failure
        print('Failed to add transaction: Status ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding transaction: $e');
      return false;
    }
  }
}
