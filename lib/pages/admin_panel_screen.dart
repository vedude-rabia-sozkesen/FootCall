import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';

void _showNotImplemented(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Not implemented'),
      content: const Text('This feature is not implemented yet.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top green header with pill "Admin Panel"
            Container(
              color: kAppGreen,
              padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: kAppGreenLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Text(
                        'Admin Panel',
                        style: kHeaderTextStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Player Requests'),
                    const SizedBox(height: 8),
                    const _PlayerRequestCard(),
                    const SizedBox(height: 24),
                    const _SectionTitle('Player Responses'),
                    const SizedBox(height: 8),
                    const _PlayerResponsesCard(),
                    const SizedBox(height: 24),
                    const _SectionTitle('Manage Team'),
                    const SizedBox(height: 8),
                    const _ManageTeamCard(highlighted: true),
                    const SizedBox(height: 8),
                    const _ManageTeamCard(highlighted: false),
                  ],
                ),
              ),
            ),

            const _BottomNavBar(),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: kSectionTitleStyle,
    );
  }
}

/// Player Requests card – avatar + name + red X + green ✓
class _PlayerRequestCard extends StatelessWidget {
  const _PlayerRequestCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: kAppBlueCard,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Avatar
          const CircleAvatar(
            radius: 28,
            backgroundImage: AssetImage(
              'assets/sample_player.png', // or use NetworkImage / placeholder
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Ahmet',
              style: kCardTitleStyle,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CircleIconButton(
                background: kAppRed,
                icon: Icons.close,
                onPressed: () => _showNotImplemented(context),
              ),
              const SizedBox(width: 8),
              _CircleIconButton(
                background: kAppGreenBright,
                icon: Icons.check,
                onPressed: () => _showNotImplemented(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Player Responses card – avatar + name + red pill "Rejected"
class _PlayerResponsesCard extends StatelessWidget {
  const _PlayerResponsesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: kAppBlueCard,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundImage: AssetImage('assets/sample_player.png'),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Ahmet',
              style: kCardTitleStyle,
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: kAppRed,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Rejected',
              style: kPillTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}

/// Manage Team card – highlighted (green border) and normal version
class _ManageTeamCard extends StatelessWidget {
  final bool highlighted;

  const _ManageTeamCard({required this.highlighted});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: kAppBlueCard,
        borderRadius: BorderRadius.circular(8),
        border: highlighted
            ? Border.all(color: kAppGreenBright, width: 3)
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundImage: AssetImage('assets/sample_player.png'),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Ahmet',
              style: kCardTitleStyle,
            ),
          ),
          GestureDetector(
            onTap: () => _showNotImplemented(context),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: kAppRed,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Remove',
                style: kPillTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final Color background;
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleIconButton({
    required this.background,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

// BOTTOM NAV BAR – Fixed to have named routes like PlayerRequestsScreen
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  void _goHome(BuildContext context) {
    // Navigate to Home using named route '/'
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  Widget _buildItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: kBottomNavTextStyle,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: kAppGreen,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildItem(
            context: context,
            icon: Icons.home_outlined,
            label: 'Home',
            onTap: () => _goHome(context),
          ),
          _buildItem(
            context: context,
            icon: Icons.group_outlined,
            label: 'My Team',
            onTap: () => _showNotImplemented(context),
          ),
          _buildItem(
            context: context,
            icon: Icons.search,
            label: 'Search',
            onTap: () => _showNotImplemented(context),
          ),
          _buildItem(
            context: context,
            icon: Icons.person_outline,
            label: 'MyProfile',
            onTap: () => _showNotImplemented(context),
          ),
        ],
      ),
    );
  }
}
