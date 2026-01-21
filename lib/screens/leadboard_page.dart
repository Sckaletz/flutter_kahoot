import 'package:flutter/material.dart';
import '../models/leaderboard.dart';
import '../services/api_service.dart';

// LeaderboardPage viser resultaterne efter quiz er færdig
class LeaderboardPage extends StatefulWidget {
  final int sessionId;
  final String quizTitle;

  const LeaderboardPage({
    super.key,
    required this.sessionId,
    required this.quizTitle,
  });

  @override
  // Opretter state objektet, der håndterer den faktiske tilstand
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Leaderboard>? _leaderboard;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final leaderboard = await fetchLeaderboard(widget.sessionId);
      if (mounted) {
        setState(() {
          _leaderboard = leaderboard;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resultater: ${widget.quizTitle}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Fejl ved indlæsning af resultater',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(_errorMessage!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _fetchLeaderboard,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Prøv igen'),
                  ),
                ],
              ),
            )
          : _buildLeaderboard(),
    );
  }

  Widget _buildLeaderboard() {
    if (_leaderboard == null || _leaderboard!.isEmpty) {
      return const Center(child: Text('Ingen resultater endnu'));
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Leaderboard',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ..._leaderboard!.asMap().entries.map((entry) {
          final index = entry.key;
          final leaderboardEntry = entry.value;
          final isTopThree = index < 3;

          return Card(
            margin: EdgeInsets.only(
              bottom: index < _leaderboard!.length - 1 ? 12 : 0,
            ),
            elevation: isTopThree ? 4 : 1,
            color: isTopThree
                ? _getRankColor(index)
                : Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Rank avatar
                  CircleAvatar(
                    backgroundColor: isTopThree
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary,
                    radius: 22,
                    child: isTopThree
                        ? Text(
                            _getRankEmoji(index),
                            style: const TextStyle(fontSize: 20),
                          )
                        : Text(
                            '${leaderboardEntry.rank}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  // Nickname
                  Expanded(
                    child: Text(
                      leaderboardEntry.nickname,
                      style: TextStyle(
                        fontWeight: isTopThree
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: isTopThree ? 18 : 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Points
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${leaderboardEntry.totalPoints}',
                        style: TextStyle(
                          fontSize: isTopThree ? 22 : 18,
                          fontWeight: FontWeight.bold,
                          color: isTopThree
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        'point',
                        style: TextStyle(
                          fontSize: 12,
                          color: isTopThree ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
      ],
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber.shade700; // Guld
      case 1:
        return Colors.grey.shade400; // Sølv
      case 2:
        return Colors.brown.shade400; // Bronze
      default:
        return Theme.of(context).cardColor;
    }
  }

  String _getRankEmoji(int index) {
    switch (index) {
      case 0:
        return '🥇';
      case 1:
        return '🥈';
      case 2:
        return '🥉';
      default:
        return '${index + 1}';
    }
  }
}
