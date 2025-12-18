import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tictactekber/services/auth_service.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  LeaderboardScreen({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Header
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: const Color(0xFF2B5FA7),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 32, color: Colors.white,),
            onPressed: null,
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('score', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return Column(
            children: [
              // 🟦 Table header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: Colors.blue.shade50,
                child: const Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Rank',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'User',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Score',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Leaderboard list
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final username = user['username'] ?? 'Unknown';
                    final score = user['score'] ?? 0;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      color: index.isEven
                          ? Colors.blue.shade100
                          : Colors.blue.shade50,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text('#${index + 1}'),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              username,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              score.toString(),
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      // Footer
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.blue.shade800,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Center(
          child: ElevatedButton(
            onPressed: () { Navigator.pushNamed(context, '/game_screen'); },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              shadowColor: Colors.transparent,
            ),
          child: const Icon(
            Icons.videogame_asset_outlined,
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
    )
    );
  }
}

