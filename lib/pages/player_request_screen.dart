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

class PlayerRequestsScreen extends StatelessWidget {
  const PlayerRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top green header with "Requests"
            Container(
              color: kAppGreen,
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 24,
              ),
              child: Row(
                children: [
                  // Back button removed
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
                        'Requests',
                        style: kHeaderTextStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _SectionTitle('Team Requests'),
                    SizedBox(height: 8),
                    _TeamRequestCard(),
                    SizedBox(height: 8),
                    _TeamRequestCard(),
                    SizedBox(height: 24),
                    _SectionTitle('Team Responses'),
                    SizedBox(height: 8),
                    _TeamResponseCard(
                      statusText: 'Rejected',
                      statusColor: kAppRed,
                    ),
                    SizedBox(height: 8),
                    _TeamResponseCard(
                      statusText: 'Accepted',
                      statusColor: kAppGreenBright,
                    ),
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

/// Team Requests card – logo + "Eagles" + red X & green ✓
class _TeamRequestCard extends StatelessWidget {
  const _TeamRequestCard();

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
          _TeamLogo(),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Eagles',
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

/// Team Responses card – logo + "Eagles" + pill "Rejected"/"Accepted"
class _TeamResponseCard extends StatelessWidget {
  final String statusText;
  final Color statusColor;

  const _TeamResponseCard({
    required this.statusText,
    required this.statusColor,
  });

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
          _TeamLogo(),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Eagles',
              style: kCardTitleStyle,
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: kPillTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage('lib/images/team_logo.png'), // Updated path
          fit: BoxFit.cover,
        ),
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

// BOTTOM NAV BAR – Home goes back to main using named route
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
    required VoidCallback onTap,
  }) {
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
