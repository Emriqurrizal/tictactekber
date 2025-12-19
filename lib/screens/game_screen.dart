import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tictactekber/game.dart';
import 'package:tictactekber/services/auth_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final AuthService _authService = AuthService();

  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  void _showLogoutSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.red),
          ),
          onTap: () {
            Navigator.pop(context);
            _handleLogout();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // Header
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        backgroundColor: const Color(0xFF2B5FA7),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 32),
            onPressed: _showLogoutSheet,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              _authService.currentUser?.displayName ?? 'Guest',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: TicTacToeGame(),
        ),
      ),

      // Footer
      bottomNavigationBar: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.blue.shade800,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Row(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                final score = snapshot.data?.get('score') ?? 0;
                return Text(
                  'Score: $score',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                );
              },
            ),
            const Spacer(),

            IconButton(
              icon: const Icon(Icons.emoji_events_outlined, size: 32),
              onPressed: () {
                Navigator.pushNamed(context, '/leaderboard');
              },
              color: Colors.white,
            ),
          ],
        ),
      ),

    );
  }
}
