import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  static const List<List<int>> _winningLines = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X'; // Player is always X
  int _playerScore = 0;
  int _draws = 0;

  void _setScore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Update score in users collection (increment by 1)
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'score': FieldValue.increment(1),
        });
        print('Score updated successfully for user: ${user.uid}');
      } catch (e) {
        print('Error updating score: $e');
      }
    }
  }

  Future<int> _getScore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final score = doc.data()?['score'] ?? 0;
        print('Retrieved score: $score for user: ${user.uid}');
        return score;
      } catch (e) {
        print('Error getting score: $e');
        return 0;
      }
    }
    return 0;
  }

  void _makeMove(int index) {
    if (_board[index].isNotEmpty || _currentPlayer != 'X') return;

    setState(() {
      _board[index] = 'X';
    });

    _handleGameState();

    // Bot move
    if (_currentPlayer == 'O') {
      Future.delayed(const Duration(milliseconds: 400), _botMove);
    }
  }

  void _botMove() {
    final move = _findBestMove();
    if (move == -1) return;

    setState(() {
      _board[move] = 'O';
    });

    _handleGameState();
  }

  void _handleGameState() {
    final winner = _checkWinner();
    if (winner != null) {
      if (winner == 'X') {
        _playerScore++;
        _setScore();
        _showResultDialog('You win!');
      } else if (winner == 'O') {
        _showResultDialog('Bot wins!');
      } else {
        _draws++;
        _showResultDialog('Draw');
      }
    } else {
      _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
    }
  }

  int _findBestMove() {
    // 1️⃣ Win if possible
    for (final line in _winningLines) {
      final move = _checkLine(line, 'O');
      if (move != -1) return move;
    }

    // 2️⃣ Block player
    for (final line in _winningLines) {
      final move = _checkLine(line, 'X');
      if (move != -1) return move;
    }

    // 3️⃣ Random move
    final empty = <int>[];
    for (int i = 0; i < 9; i++) {
      if (_board[i].isEmpty) empty.add(i);
    }
    return empty.isEmpty ? -1 : empty[Random().nextInt(empty.length)];
  }

  int _checkLine(List<int> line, String player) {
    final values = line.map((i) => _board[i]).toList();
    if (values.where((v) => v == player).length == 2 &&
        values.contains('')) {
      return line[values.indexOf('')];
    }
    return -1;
  }

  String? _checkWinner() {
    for (final line in _winningLines) {
      final a = _board[line[0]];
      final b = _board[line[1]];
      final c = _board[line[2]];
      if (a.isNotEmpty && a == b && b == c) return a;
    }
    if (_board.every((e) => e.isNotEmpty)) return 'Draw';
    return null;
  }

  void _resetBoard() {
    setState(() {
      _board = List.filled(9, '');
      _currentPlayer = 'X';
    });
  }

  Future<void> _showResultDialog(String title) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: FutureBuilder<int>(
          future: _getScore(),
          builder: (context, snapshot) {
            final score = snapshot.data ?? _playerScore;
            return Text('Score: $score     Draws: $_draws');
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetBoard();
            },
            child: const Text('Play again'),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(int index) {
    final value = _board[index];
    return GestureDetector(
      onTap: () => _makeMove(index),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.shade700, width: 1.5),
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.bold,
              color: value == 'X'
                  ? Colors.blue.shade900
                  : Colors.red.shade700,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<int>(
          future: _getScore(),
          builder: (context, snapshot) {
        final score = snapshot.data ?? _playerScore;
        return Text('Score: $score');
          },
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(24),
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 9,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (_, index) => _buildCell(index),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.blue.shade800,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.emoji_events_outlined,
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
    );
  }
  
}
