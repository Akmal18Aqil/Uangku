import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:uangku/features/transactions/presentation/providers/transaction_provider.dart';

class StatisticsTab extends StatelessWidget {
  const StatisticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF10B981);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Statistik',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final expenses = provider.filteredTransactions
              .where((t) => t.type.toLowerCase() == 'expense')
              .toList();

          // Map expenses by category
          final Map<String, double> categoryTotals = {};
          for (var t in expenses) {
            categoryTotals[t.category] =
                (categoryTotals[t.category] ?? 0) + t.amount;
          }

          final List<PieChartSectionData> pieChartSections = [];
          final List<Color> colors = [
            Colors.redAccent,
            Colors.blueAccent,
            Colors.greenAccent,
            Colors.orangeAccent,
            Colors.purpleAccent,
            Colors.yellowAccent.shade700,
            Colors.cyanAccent,
            Colors.pinkAccent,
          ];

          int colorIndex = 0;
          categoryTotals.forEach((category, total) {
            final percentage = (total / provider.totalExpense) * 100;
            pieChartSections.add(
              PieChartSectionData(
                color: colors[colorIndex % colors.length],
                value: percentage,
                title: '${percentage.toStringAsFixed(1)}%',
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            );
            colorIndex++;
          });

          return Column(
            children: [
              // MONTH PICKER
              Container(
                color: Theme.of(context).cardColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => provider.changeMonth(-1),
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(provider.selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => provider.changeMonth(1),
                    ),
                  ],
                ),
              ),
              if (expenses.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.network(
                          'https://lottie.host/5a22e86d-f42e-43cf-be61-e00f9aa0c2e3/xW42dG2jYw.json',
                          height: 150,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.pie_chart_outline,
                              size: 80,
                              color: isDark
                                  ? Colors.grey[800]
                                  : Colors.grey[300],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada pengeluaran di bulan ini',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      const Text(
                        'Pengeluaran per Kategori',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // PIE CHART
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: pieChartSections,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // LEGEND
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: categoryTotals.length,
                          itemBuilder: (context, index) {
                            final category = categoryTotals.keys.elementAt(
                              index,
                            );
                            final total = categoryTotals[category]!;
                            final percentage =
                                (total / provider.totalExpense) * 100;
                            final color = colors[index % colors.length];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      category,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        NumberFormat.currency(
                                          locale: 'id_ID',
                                          symbol: 'Rp ',
                                          decimalDigits: 0,
                                        ).format(total),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        '${percentage.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
