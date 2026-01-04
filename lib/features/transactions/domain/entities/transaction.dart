class Transaction {
  final DateTime date;
  final String description;
  final String category;
  final String type; // 'Income' or 'Expense'
  final double amount;

  const Transaction({
    required this.date,
    required this.description,
    required this.category,
    required this.type,
    required this.amount,
  });
}
