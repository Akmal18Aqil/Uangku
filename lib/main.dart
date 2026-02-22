import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'features/main/presentation/pages/main_screen.dart';
import 'features/transactions/presentation/providers/transaction_provider.dart';

import 'features/settings/presentation/providers/theme_provider.dart';

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
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Uangku',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF10B981),
                primary: const Color(0xFF10B981),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.poppinsTextTheme(),
              scaffoldBackgroundColor: const Color(0xFFF3F4F6),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF10B981),
                primary: const Color(0xFF10B981),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.poppinsTextTheme(
                ThemeData(brightness: Brightness.dark).textTheme,
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
            ),
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
