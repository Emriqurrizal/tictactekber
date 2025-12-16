import 'package:flutter/material.dart';

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
  String _currentPlayer = 'X';
  int _xScore = 0;
  int _oScore = 0;
  int _draws = 0;

  void _makeMove(int index) {
    if (_board[index].isNotEmpty) return;

    setState(() {
      _board[index] = _currentPlayer;
    });

    final winner = _checkWinner();
    if (winner != null) {
      if (winner == 'Draw') {
        _draws++;
        _showResultDialog('Draw');
      } else {
        winner == 'X' ? _xScore++ : _oScore++;
        _showResultDialog('Player $winner wins!');
      }
    } else {
      setState(() {
        _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
      });
    }
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

  void _resetScores() {
    setState(() {
      _xScore = 0;
      _oScore = 0;
      _draws = 0;
    });
  }

  Future<void> _showResultDialog(String title) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(
          'Scores\nX: $_xScore   O: $_oScore   Draws: $_draws',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetBoard();
            },
            child: const Text('Play again'),
          ),
          TextButton(
            onPressed: () {
              _resetBoard();
              _resetScores();
              Navigator.pop(context);
            },
            child: const Text('Reset scores'),
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
          border: Border.all(
            color: Colors.blue.shade700,
            width: 1.5,
          ),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 🔹 Board container
        Container(
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
        
        const SizedBox(height: 20),
        
        // 🔹 Bottom bar (leaderboard access)
        Container(
          width: double.infinity,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue.shade800,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: Icon(
              Icons.emoji_events_outlined,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
      ],
    );
  }
}
