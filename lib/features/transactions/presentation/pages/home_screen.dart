import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).fetchTransactions(),
    );
  }

  // Helper for Currency Format
  String formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  // Helper for Icon based on Category
  IconData getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
      case 'food':
        return Icons.restaurant;
      case 'transport':
      case 'transportasi':
        return Icons.directions_car;
      case 'belanja':
      case 'shopping':
        return Icons.shopping_bag;
      case 'gaji':
      case 'salary':
        return Icons.attach_money;
      case 'hiburan':
      case 'entertainment':
        return Icons.movie;
      case 'kesehatan':
      case 'health':
        return Icons.local_hospital;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF10B981); // Emerald Green
    final expenseColor = const Color(0xFFEF4444); // Red
    final cardColor = Theme.of(context).cardColor;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // HEADER CARD SECTION
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Total Saldo',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0,
                          end: provider.totalBalance,
                        ),
                        duration: const Duration(milliseconds: 1000),
                        builder: (context, value, child) {
                          return Text(
                            formatRupiah(value),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem(
                            'Pemasukan',
                            provider.totalIncome,
                            primaryColor,
                            Icons.arrow_upward,
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                          ),
                          _buildSummaryItem(
                            'Pengeluaran',
                            provider.totalExpense,
                            expenseColor,
                            Icons.arrow_downward,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // RECENT TRANSACTIONS HEADER & MONTH PICKER
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () => provider.changeMonth(-1),
                          ),
                          Text(
                            DateFormat(
                              'MMM yyyy',
                            ).format(provider.selectedDate),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () => provider.changeMonth(1),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {}, // TODO: See All
                        child: Text(
                          'Semua',
                          style: TextStyle(color: primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),

                // LIST SECTION
                Expanded(
                  child: provider.isLoading
                      ? Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        )
                      : provider.filteredTransactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.network(
                                'https://lottie.host/5a22e86d-f42e-43cf-be61-e00f9aa0c2e3/xW42dG2jYw.json',
                                height: 150,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.receipt_long,
                                    size: 60,
                                    color: isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[300],
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada transaksi di bulan ini',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: provider.filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction =
                                provider.filteredTransactions[index];
                            final isExpense =
                                transaction.type.toLowerCase() == 'expense';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      isDark ? 0.3 : 0.05,
                                    ),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isExpense
                                      ? (isDark
                                            ? Colors.red.withOpacity(0.2)
                                            : const Color(
                                                0xFFFEE2E2,
                                              )) // Light Red
                                      : (isDark
                                            ? Colors.green.withOpacity(0.2)
                                            : const Color(
                                                0xFFD1FAE5,
                                              )), // Light Green
                                  child: Icon(
                                    getIconForCategory(transaction.category),
                                    color: isExpense
                                        ? expenseColor
                                        : primaryColor,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  transaction.description,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    DateFormat(
                                      'dd MMM yyyy',
                                    ).format(transaction.date),
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${isExpense ? '-' : '+'} ${formatRupiah(transaction.amount)}',
                                      style: TextStyle(
                                        color: isExpense
                                            ? expenseColor
                                            : primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        if (transaction.id == null ||
                                            transaction.id!.isEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Transaksi ini tidak memiliki ID (Refresh required)',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        if (value == 'edit') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddTransactionScreen(
                                                    transactionToEdit:
                                                        transaction,
                                                  ),
                                            ),
                                          );
                                        } else if (value == 'delete') {
                                          bool confirm =
                                              await showDialog(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text(
                                                    'Hapus Transaksi',
                                                  ),
                                                  content: const Text(
                                                    'Yakin ingin menghapus transaksi ini?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            ctx,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        'Batal',
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            ctx,
                                                            true,
                                                          ),
                                                      child: const Text(
                                                        'Hapus',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ) ??
                                              false;

                                          if (confirm && context.mounted) {
                                            await Provider.of<
                                                  TransactionProvider
                                                >(context, listen: false)
                                                .deleteTransaction(
                                                  transaction.id!,
                                                );
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Transaksi dihapus',
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                      itemBuilder: (BuildContext context) {
                                        return [
                                          const PopupMenuItem<String>(
                                            value: 'edit',
                                            child: Text('Edit'),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Text(
                                              'Hapus',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ];
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: amount),
          duration: const Duration(milliseconds: 1000),
          builder: (context, value, child) {
            return Text(
              formatRupiah(value),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            );
          },
        ),
      ],
    );
  }
}
