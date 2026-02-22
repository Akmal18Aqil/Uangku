import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/transaction.dart';
import '../models/transaction_model.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class SheetsService {
  static String get apiUrl => dotenv.env['SHEETS_API_URL'] ?? '';

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
      final model = TransactionModel.fromEntity(transaction);
      final payload = model.toJson();
      payload['action'] = 'create'; // Add action for new script

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      return _handlePostResponse(response);
    } catch (e) {
      print('Error adding transaction: $e');
      return false;
    }
  }

  Future<bool> updateTransaction(Transaction transaction) async {
    try {
      if (transaction.id == null) return false;

      final model = TransactionModel.fromEntity(transaction);
      final payload = model.toJson();
      payload['action'] = 'update';

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      return _handlePostResponse(response);
    } catch (e) {
      print('Error updating transaction: $e');
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      final payload = {'action': 'delete', 'id': id};

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      return _handlePostResponse(response);
    } catch (e) {
      print('Error deleting transaction: $e');
      return false;
    }
  }

  Future<bool> _handlePostResponse(http.Response response) async {
    if (response.statusCode == 302) {
      final location = response.headers['location'];
      if (location != null) {
        response = await http.get(Uri.parse(location));
      }
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dynamic decoded = json.decode(response.body);
      if (decoded is Map && decoded['status'] == 'success') {
        return true;
      }
      print('GAS returned error: ${response.body}');
      return false;
    } else {
      print('HTTP Request failed with status: ${response.statusCode}');
      return false;
    }
  }
}
