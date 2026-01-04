import 'package:flutter/foundation.dart';
import '../../domain/entities/transaction.dart';
import '../../data/datasources/sheets_service.dart';

class TransactionProvider with ChangeNotifier {
  final SheetsService _sheetsService = SheetsService();

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalIncome {
    return _transactions
        .where((t) => t.type.toLowerCase() == 'income')
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => t.type.toLowerCase() == 'expense')
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalBalance {
    return totalIncome - totalExpense;
  }

  Future<void> fetchTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _sheetsService.getTransactions();
      // Sort by date descending (newest first)
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      _error = e.toString();
      // Keep old data or clear it? Better to keep old data if refresh fails,
      // but here we assume initial load.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _sheetsService.addTransaction(transaction);
      if (success) {
        // Optimistic update or refresh?
        // Refreshing is safer to get the exact state from server including any ID generation
        await fetchTransactions();
      } else {
        _error = "Failed to add transaction";
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
