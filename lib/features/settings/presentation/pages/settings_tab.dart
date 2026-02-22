import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Tampilan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Card(
                elevation: 0,
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: const Text('System Default'),
                      value: ThemeMode.system,
                      groupValue: themeProvider.themeMode,
                      onChanged: (ThemeMode? value) {
                        if (value != null) {
                          themeProvider.setSystemTheme();
                        }
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<ThemeMode>(
                      title: const Text('Light'),
                      value: ThemeMode.light,
                      groupValue: themeProvider.themeMode,
                      onChanged: (ThemeMode? value) {
                        if (value != null) {
                          themeProvider.toggleTheme(false);
                        }
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<ThemeMode>(
                      title: const Text('Dark'),
                      value: ThemeMode.dark,
                      groupValue: themeProvider.themeMode,
                      onChanged: (ThemeMode? value) {
                        if (value != null) {
                          themeProvider.toggleTheme(true);
                        }
                      },
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
