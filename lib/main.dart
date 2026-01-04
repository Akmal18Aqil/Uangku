import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'features/transactions/presentation/pages/home_screen.dart'; // Updated import
import 'features/transactions/presentation/providers/transaction_provider.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TransactionProvider())],
      child: MaterialApp(
        title: 'Uangku',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Set primary color to Emerald Green
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF10B981),
            primary: const Color(0xFF10B981),
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
          scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        ),
        home: const HomeScreen(), // Updated entry point
      ),
    );
  }
}
