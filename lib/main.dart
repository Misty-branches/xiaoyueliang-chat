import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'providers/book_provider.dart';
import 'providers/reading_provider.dart';
import 'pages/chat_page.dart';
import 'pages/settings_page.dart';
import 'pages/book_page.dart';
import 'models/theme_scheme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => ReadingProvider()),
      ],
      child: const XiayueChatApp(),
    ),
  );
}

class XiayueChatApp extends StatelessWidget {
  const XiayueChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        final isDark = provider.settings.darkMode;
        final scheme = provider.currentScheme;
        final accentColor = scheme.primaryColorObj;
        return MaterialApp(
          title: '遐悦聊天',
          debugShowCheckedModeBanner: false,
          theme: _buildLightTheme(accentColor, scheme),
          darkTheme: _buildDarkTheme(accentColor, scheme),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          routes: {
            '/': (context) => const ChatPage(),
            '/settings': (context) => const SettingsPage(),
            '/book': (context) => const BookPage(),
          },
        );
      },
    );
  }

  ThemeData _buildLightTheme(Color accent, ThemeScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: accent,
      scaffoldBackgroundColor: scheme.bgColorObj,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.grey.shade800,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.pink.shade100, width: 0.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme(Color accent, ThemeScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: accent,
      scaffoldBackgroundColor: scheme.darkBgColorObj,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.grey.shade200,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.grey.shade200,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: const Color(0xFF16213E),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.pink.shade900.withValues(alpha: 0.3), width: 0.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
