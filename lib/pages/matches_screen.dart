import 'package:flutter/material.dart';

import '../data/match_repository.dart';
import '../models/match_model.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/styles.dart';
import '../widgets/app_bottom_nav.dart';

class MatchesScreen extends StatelessWidget {
  MatchesScreen({super.key});

  final MatchRepository _repository = MatchRepository.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2235),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: _MatchesHeader(),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kDefaultPadding,
                        vertical: kDefaultPadding,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            'Filter',
                            style: TextStyle(
                              color: Color(0xFF4B5775),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // to be filled: add filters for matches
                            },
                            icon: const Icon(
                              Icons.filter_list,
                              color: Color(0xFF4B5775),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: const Color(0xFFCBD8FF),
                      padding: const EdgeInsets.symmetric(
                        horizontal: kDefaultPadding,
                        vertical: 12,
                      ),
                      child: Row(
                        children: const [
                          Expanded(
                            child: Text(
                              'city/district',
                              style: TextStyle(
                                color: Color(0xFF4B5775),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'team name(s)',
                              style: TextStyle(
                                color: Color(0xFF4B5775),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'time',
                              style: TextStyle(
                                color: Color(0xFF4B5775),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: kSmallPadding),
                    Expanded(
                      child: ValueListenableBuilder<List<MatchModel>>(
                        valueListenable: _repository.matchesNotifier,
                        builder: (context, matches, _) {
                          if (matches.isEmpty) {
                            return const Center(
                              child: Text(
                                'No matches available',
                                style: TextStyle(color: Colors.black87),
                              ),
                            );
                          }
                          return ListView.separated(
                            itemCount: matches.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: kSmallPadding),
                            itemBuilder: (context, index) {
                              final match = matches[index];
                              return Dismissible(
                                key: ValueKey(match.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  color: kAppRed,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (_) {
                                  _repository.removeMatch(match.id);
                                },
                                child: _MatchListTile(match: match),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: kDefaultPadding),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Create Match',
                        style: kCardTitleStyle.copyWith(
                          color: const Color(0xFF1E2235),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_repository.isAdmin)
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed('/create-match');
                          },
                          child: const CircleAvatar(
                            radius: 36,
                            backgroundColor: Color(0xFF87C56C),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    const SizedBox(height: kDefaultPadding),
                    const AppBottomNavBar(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchesHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF41465A), Color(0xFF2C3144)],
        ),
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
      child: Center(
        child: Text(
          'Matches',
          style: kCardTitleStyle.copyWith(
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

class _MatchListTile extends StatelessWidget {
  const _MatchListTile({required this.match});

  final MatchModel match;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/match-info',
          arguments: match,
        );
      },
      child: Container(
        width: double.infinity,
        color: const Color(0xFF2A3150),
        padding: const EdgeInsets.symmetric(
          horizontal: kDefaultPadding,
          vertical: 14,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                match.cityDistrict,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage(match.assetLogoPath),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      match.matchTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  match.timeRange,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
