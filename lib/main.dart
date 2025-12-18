import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tictactekber/firebase_options.dart';
import 'package:tictactekber/screens/game_screen.dart';
import 'package:tictactekber/screens/leaderboard_screen.dart';
import 'package:tictactekber/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: '/',

      routes: {
        '/': (context) => const LoginScreen(),
        '/game_screen': (context) => GameScreen(),
        '/leaderboard': (context) => LeaderboardScreen(),
      },
    );
  }
}