import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transactionToEdit;

  const AddTransactionScreen({super.key, this.transactionToEdit});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;

  late String _selectedType;
  late String _selectedCategory;
  late DateTime _selectedDate;

  // Example categories
  final List<String> _categories = [
    'Makanan',
    'Transport',
    'Belanja',
    'Hiburan',
    'Kesehatan',
    'Gaji',
    'Bonus',
    'Lainnya',
  ];

  bool get isEditing => widget.transactionToEdit != null;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: isEditing ? widget.transactionToEdit!.description : '',
    );
    _amountController = TextEditingController(
      text: isEditing
          ? widget.transactionToEdit!.amount.toStringAsFixed(0)
          : '',
    );
    _selectedType = isEditing ? widget.transactionToEdit!.type : 'Expense';

    // Ensure category exists in list or default to arbitrary existing
    final initialCat = isEditing
        ? widget.transactionToEdit!.category
        : 'Makanan';
    _selectedCategory = _categories.contains(initialCat)
        ? initialCat
        : 'Lainnya';

    _selectedDate = isEditing ? widget.transactionToEdit!.date : DateTime.now();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      final description = _descriptionController.text;
      final amount = double.parse(_amountController.text);

      final newTransaction = Transaction(
        id: isEditing ? widget.transactionToEdit!.id : null,
        date: _selectedDate,
        description: description,
        category: _selectedCategory,
        type: _selectedType,
        amount: amount,
      );

      // Call Provider
      final provider = Provider.of<TransactionProvider>(context, listen: false);

      if (isEditing) {
        await provider.updateTransaction(newTransaction);
      } else {
        await provider.addTransaction(newTransaction);
      }

      if (mounted) {
        if (provider.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${provider.error}')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing
                    ? 'Transaksi berhasil diubah!'
                    : 'Transaksi berhasil disimpan!',
              ),
            ),
          );
          Navigator.of(context).pop(); // Back to Home
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF10B981);
    final expenseColor = const Color(0xFFEF4444);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Ubah Transaksi' : 'Tambah Transaksi',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Type Selection (Income / Expense)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedType = 'Income'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedType == 'Income'
                                        ? primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Pemasukan',
                                    style: TextStyle(
                                      color: _selectedType == 'Income'
                                          ? Colors.white
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedType = 'Expense'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedType == 'Expense'
                                        ? expenseColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Pengeluaran',
                                    style: TextStyle(
                                      color: _selectedType == 'Expense'
                                          ? Colors.white
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Amount Input
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Jumlah (Rp)',
                          prefixText: 'Rp ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan jumlah';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Masukkan angka valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description Input
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Keterangan',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan keterangan';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Date Picker
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Tanggal',
                              hintText: DateFormat(
                                'dd MMM yyyy',
                              ).format(_selectedDate),
                              suffixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            controller: TextEditingController(
                              text: DateFormat(
                                'dd MMM yyyy',
                              ).format(_selectedDate),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : _submitData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Simpan Transaksi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Loading Overlay
              if (provider.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
