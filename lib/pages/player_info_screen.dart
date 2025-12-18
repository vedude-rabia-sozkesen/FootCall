import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/player_repository.dart';
import '../models/player_model.dart';
import '../widgets/app_bottom_nav.dart';
import '../providers/setting_provider.dart';

class PlayerInfoScreen extends StatefulWidget {
  const PlayerInfoScreen({super.key});

  @override
  State<PlayerInfoScreen> createState() => _PlayerInfoScreenState();
}

class _PlayerInfoScreenState extends State<PlayerInfoScreen> {
  final PlayerRepository _repository = PlayerRepository.instance;
  late String playerId;
  bool _hasLiked = false;
  bool _hasDisliked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      playerId = args;
    } else {
      // Default to first player if no ID provided
      playerId = '34731';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: context.watch<SettingsProvider>().isDarkMode
                ? [Colors.grey.shade900, Colors.black87] // Dark mode arka plan
                : [Color(0xFFB8C9E8), Color(0xFFD4D9E8)], // Light mode
          ),
        ),
        child: SafeArea(
          child: ValueListenableBuilder<List<PlayerModel>>(
            valueListenable: _repository.playersNotifier,
            builder: (context, players, _) {
              final player = _repository.findById(playerId);

              if (player == null) {
                return const Center(child: Text('Player not found'));
              }

              return Column(
                children: [
                  // 🔥 YENİ EKLENEN - ÜST BAR (Theme Butonu ile)
                  _PlayerInfoTopBar(),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),

                            // Player photo and info header
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Player Info card
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 60, left: 120),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4A5568),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Player Info',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                                // Player photo
                                Positioned(
                                  left: 10,
                                  top: 0,
                                  child: Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 68,
                                      backgroundImage:
                                      NetworkImage(player.photoUrl),
                                      backgroundColor: Colors.grey[300],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Player details card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A5568),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              player.name,
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Position: ${player.position}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                            'Age',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          Text(
                                            '${player.age}',
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'ID: ${player.id}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Previous Matches section
                            const Text(
                              'Previous Matches',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Match scores
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 20,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB8C9E8),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children:
                                player.previousMatches.map((match) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD4D9E8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          match.scoreDisplay,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: match.isWin
                                                ? Colors.green
                                                : Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Action buttons (like/dislike and add)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Like and Dislike buttons
                                Row(
                                  children: [
                                    _buildActionButton(
                                      icon: Icons.thumb_up_outlined,
                                      onPressed: () {
                                        if (!_hasLiked) {
                                          setState(() {
                                            _hasLiked = true;
                                            _hasDisliked = false;
                                          });
                                          _repository.likePlayer(playerId);
                                        }
                                      },
                                      isActive: _hasLiked,
                                    ),
                                    const SizedBox(width: 16),
                                    _buildActionButton(
                                      icon: Icons.thumb_down_outlined,
                                      onPressed: () {
                                        if (!_hasDisliked) {
                                          setState(() {
                                            _hasDisliked = true;
                                            _hasLiked = false;
                                          });
                                          _repository.dislikePlayer(playerId);
                                        }
                                      },
                                      isActive: _hasDisliked,
                                    ),
                                  ],
                                ),

                                // Add button
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8FBC6B),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      _showAddPlayerDialog(player);
                                    },
                                    icon: const Icon(
                                      Icons.add,
                                      size: 36,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                                // Likes and Dislikes count
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Row(
                                      children: [
                                        Text(
                                          'Likes',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Text(
                                          'Dislikes',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '${player.likes}',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                        const SizedBox(width: 32),
                                        Text(
                                          '${player.dislikes}',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(activeIndex: 2),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF6B8E4E) : const Color(0xFF4A5568),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  void _showAddPlayerDialog(PlayerModel player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Player'),
        content: Text('Do you want to add ${player.name} to your team?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B8E4E),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${player.name} added to your team!'),
                  backgroundColor: const Color(0xFF6B8E4E),
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// 🔥 YENİ EKLENEN WIDGET - ÜST BAR (Theme Butonu ile)
class _PlayerInfoTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;

    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.grey.shade900, Colors.grey.shade800]
              : [Color(0xFF6B8E4E), Color(0xFF8FBC6B)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Center(
            child: Text(
              'Player Information',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Sağ üst theme butonu
          Positioned(
            top: 20,
            right: 16,
            child: IconButton(
              onPressed: () {
                context.read<SettingsProvider>().toggleTheme();
              },
              icon: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: isDark ? Colors.black : Colors.white, // Icon rengi
              ),
            ),
          ),
        ],
      ),
    );
  }
}
