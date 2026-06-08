import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'providers/book_provider.dart';
import 'providers/reading_provider.dart';
import 'providers/windowsill_provider.dart';
import 'pages/chat_page.dart';
import 'pages/settings_page.dart';
import 'pages/book_page.dart';
import 'pages/windowsill_page.dart';
import 'pages/hub_page.dart';
import 'pages/diary_page.dart';
import 'pages/diary_detail_page.dart';
import 'pages/todo_page.dart';
import 'pages/echo_wall_page.dart';
import 'models/theme_scheme.dart';
import 'stores/diary_store.dart';
import 'stores/todo_store.dart';
import 'stores/echo_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => ReadingProvider()),
        ChangeNotifierProvider(create: (_) => DiaryStore()),
        ChangeNotifierProvider(create: (_) => TodoStore()),
        ChangeNotifierProvider(create: (_) => EchoStore()),
        ChangeNotifierProvider(create: (_) => WindowsillProvider()),
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
    return Selector<ChatProvider, int>(
      selector: (_, provider) => provider.themeVersion,
      builder: (context, _, __) {
        final chatProv = context.read<ChatProvider>();
        final isDark = chatProv.settings.darkMode;
        final scheme = chatProv.currentScheme;
        final accentColor = scheme.primaryColorObj;
        return MaterialApp(
          title: '遐悦',
          debugShowCheckedModeBanner: false,
          theme: _buildLightTheme(accentColor, scheme),
          darkTheme: _buildDarkTheme(accentColor, scheme),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            Widget page;
            switch (settings.name) {
              case '/':
                page = const WindowsillPage();
                break;
              case '/hub':
                page = const HubPage();
                break;
              case '/chat':
                page = const ChatPage();
                break;
              case '/settings':
                page = const SettingsPage();
                break;
              case '/book':
                page = const BookPage();
                break;
              case '/diary':
                page = const DiaryPage();
                break;
              case '/diary-detail':
                page = const DiaryDetailPage();
                break;
              case '/todo':
                page = const TodoPage();
                break;
              case '/echo':
                page = const EchoWallPage();
                break;
              default:
                page = const WindowsillPage();
            }
            return _buildPageRoute(page);
          },
        );
      },
    );
  }

  /// 页面切换动效
  static PageRouteBuilder _buildPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final slideTween = Tween<Offset>(
          begin: const Offset(0.08, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
          child: SlideTransition(
            position: animation.drive(slideTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
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
      cardTheme: CardThemeData(
        color: scheme.cardBgColorObj,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: const DividerThemeData(space: 1, thickness: 0.5),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      cardTheme: CardThemeData(
        color: scheme.darkCardBgColorObj,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: const DividerThemeData(space: 1, thickness: 0.5),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
