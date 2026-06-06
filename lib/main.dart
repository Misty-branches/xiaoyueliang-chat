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
    // 使用 Selector 监听主题版本号，只在主题变化时重建 MaterialApp
    // 不会因为发消息/切换会话等操作触发全局重绘
    return Selector<ChatProvider, int>(
      selector: (_, provider) => provider.themeVersion,
      builder: (context, _, provider) {
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
        backgroundColor: scheme.cardBgColorObj,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.grey.shade800,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: scheme.cardBgColorObj,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.primaryColorObj.withValues(alpha: 0.2), width: 0.5),
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
        backgroundColor: scheme.darkCardBgColorObj,
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
        backgroundColor: scheme.darkCardBgColorObj,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.primaryColorObj.withValues(alpha: 0.3), width: 0.5),
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
