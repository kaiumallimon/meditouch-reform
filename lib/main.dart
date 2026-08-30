import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meditouch/app/app.dart';
import 'package:meditouch/app/theme_provider.dart';
import 'package:meditouch/core/storage/secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ThemeMode initialTheme = ThemeMode.light;
  try {
    const secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
    final storage = SecureStorageService(secureStorage);
    final savedTheme = await storage.read('app_theme_mode');
    if (savedTheme == 'dark') {
      initialTheme = ThemeMode.dark;
    } else if (savedTheme == 'light') {
      initialTheme = ThemeMode.light;
    } else if (savedTheme == 'system') {
      initialTheme = ThemeMode.system;
    }
  } catch (_) {}

  runApp(
    ProviderScope(
      overrides: [
        initialThemeModeProvider.overrideWithValue(initialTheme),
      ],
      child: const MediTouchApp(),
    ),
  );
}
