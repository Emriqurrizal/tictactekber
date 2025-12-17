import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tictactekber/firebase_options.dart';
import 'package:tictactekber/screens/leaderboard_screen.dart';
import 'package:tictactekber/screens/login_screen.dart';
import 'package:tictactekber/game.dart';

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

      // 👇 REQUIRED for web routing
      initialRoute: '/',

      routes: {
        '/': (context) => const LoginScreen(),
        '/game': (context) => const TicTacToeGame(),
        '/leaderboard': (context) => const LeaderboardScreen(),
      },
    );
  }
}