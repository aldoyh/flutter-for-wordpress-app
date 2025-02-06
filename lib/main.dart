import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_wordpress_app/common/constants.dart';
import 'package:flutter_wordpress_app/services/auth_service.dart';
import 'package:flutter_wordpress_app/providers/posts_provider.dart';
import 'package:flutter_wordpress_app/providers/comment_provider.dart';
import 'package:flutter_wordpress_app/pages/articles.dart';
import 'package:flutter_wordpress_app/pages/local_articles.dart';
import 'package:flutter_wordpress_app/pages/search.dart';
import 'package:flutter_wordpress_app/pages/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final authService = AuthService();
  await authService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authService),
        ChangeNotifierProvider(create: (_) => PostsProvider()),
        ChangeNotifierProxyProvider<AuthService, CommentProvider>(
          create: (context) => CommentProvider(authService),
          update: (context, auth, previous) => CommentProvider(auth),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF385C7B),
        primaryColorLight: Colors.white,
        primaryColorDark: Colors.black,
        fontFamily: Constants.fontFamily,
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.w700,
            fontFamily: Constants.fontFamily,
            letterSpacing: -0.5,
          ),
          titleLarge: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w600,
            fontFamily: Constants.fontFamily,
            letterSpacing: -0.3,
          ),
          titleMedium: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
            fontFamily: Constants.fontFamily,
          ),
          titleSmall: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            fontFamily: Constants.fontFamily,
          ),
          bodyLarge: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w400,
            fontFamily: Constants.fontFamily,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
            fontFamily: Constants.fontFamily,
            height: 1.4,
          ),
          bodySmall: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            fontFamily: Constants.fontFamily,
            letterSpacing: 0.2,
          ),
          labelMedium: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            fontFamily: Constants.fontFamily,
            letterSpacing: 0.1,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF385C7B),
          brightness: Brightness.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const Articles(),
    const LocalArticles(),
    const Search(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        selectedLabelStyle: TextStyle(
          fontFamily: Constants.fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: Constants.fontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Local',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
