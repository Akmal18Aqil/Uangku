import 'package:intl/intl.dart';
import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  TransactionModel({
    required DateTime date,
    required String description,
    required String category,
    required String type,
    required double amount,
  }) : super(
         date: date,
         description: description,
         category: category,
         type: type,
         amount: amount,
       );

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // 1. Safe Amount Parsing
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        String cleaned = value.replaceAll(RegExp(r'[^0-9.-]'), '');
        return double.tryParse(cleaned) ?? 0.0;
      }
      return 0.0;
    }

    // 2. Safe Date Parsing
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          try {
            return DateFormat('yyyy-MM-dd').parse(value);
          } catch (e) {
            return DateTime.now();
          }
        }
      }
      return DateTime.now();
    }

    return TransactionModel(
      date: parseDate(json['date']),
      description: json['description']?.toString() ?? 'No Description',
      category: json['category']?.toString() ?? 'General',
      type: json['type']?.toString() ?? 'Expense',
      amount: parseDouble(json['amount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'description': description,
      'category': category,
      'type': type,
      'amount': amount,
    };
  }

  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      date: transaction.date,
      description: transaction.description,
      category: transaction.category,
      type: transaction.type,
      amount: transaction.amount,
    );
  }
}
