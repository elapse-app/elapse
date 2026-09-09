import 'package:elapse_app/classes/Filters/season.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/classes/Tournament/tournament_preview.dart';
import 'package:elapse_app/main.dart';
import 'package:elapse_app/screens/tournament/tournament.dart';
import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/screens/widgets/big_error_message.dart';
import 'package:elapse_app/screens/widgets/long_button.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:elapse_app/screens/widgets/settings_button.dart';
import 'package:elapse_app/screens/widgets/tournament_preview_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<TournamentPreview>> _tournaments;

  @override
  void initState() {
    super.initState();
    _tournaments = _requestTournaments();
  }

  Future<List<TournamentPreview>> _requestTournaments({
    bool forceRefresh = false,
  }) {
    final savedTeam = tryLoadTeamPreview(prefs.getString('savedTeam'));
    if (savedTeam == null) {
      return Future.value(const []);
    }

    return fetchTeamTournaments(
      savedTeam.teamID,
      seasons[0].vrcId,
      forceRefresh: forceRefresh,
    ).then((events) => upcomingTournaments(events, DateTime.now()));
  }

  Future<void> _reload({bool forceRefresh = false}) async {
    final request = _requestTournaments(forceRefresh: forceRefresh);
    setState(() => _tournaments = request);
    try {
      await request;
    } catch (_) {
      // The FutureBuilder owns the visible error state.
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final imageString = Theme.of(context).brightness == Brightness.dark
        ? 'assets/dg4x.png'
        : 'assets/lg4x.png';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () => _reload(forceRefresh: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            ElapseAppBar(
              title: Text(
                _welcomeMessage(now.hour),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 12,
                    bottom: 20,
                    top: 10,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 5),
                      Image(image: AssetImage(imageString), height: 25),
                      const Spacer(),
                      SettingsButton(
                        callback: () => _reload(forceRefresh: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const RoundedTop(),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(18)),
                  ),
                  child: FutureBuilder<List<TournamentPreview>>(
                    future: _tournaments,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return Center(
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        debugPrint(
                          'Failed to load team events: ${snapshot.error}',
                        );
                        return const BigErrorMessage(
                          icon: Icons.cloud_off_outlined,
                          message: 'Failed to load upcoming tournaments.',
                        );
                      }

                      final events = snapshot.data ?? const [];
                      if (events.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(10),
                          child: BigErrorMessage(
                            icon: Icons.emoji_events_outlined,
                            message: 'No upcoming tournaments',
                            topPadding: 0,
                          ),
                        );
                      }
                      return _UpcomingTournamentCard(
                        tournament: events.first,
                        now: now,
                      );
                    },
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              sliver: SliverToBoxAdapter(
                child: FutureBuilder<List<TournamentPreview>>(
                  future: _tournaments,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      debugPrint(
                        'Failed to load upcoming events: ${snapshot.error}',
                      );
                    }
                    final events = snapshot.data ?? const [];
                    if (events.length < 2) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Upcoming',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        for (final event in events.skip(1))
                          TournamentPreviewWidget(tournamentPreview: event),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingTournamentCard extends StatelessWidget {
  const _UpcomingTournamentCard({
    required this.tournament,
    required this.now,
  });

  final TournamentPreview tournament;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final location = [
      tournament.location?.city,
      tournament.location?.region,
    ].whereType<String>().where((value) => value.isNotEmpty).join(', ');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => TournamentScreen(
              tournamentID: tournament.id,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  tournament.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward),
            ],
          ),
          const SizedBox(height: 25),
          if (location.isNotEmpty)
            Text(
              location,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),
          _EventDates(tournament: tournament),
          if (isTournamentActive(tournament, now))
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: LongButton(
                onPressed: () => _confirmTournamentMode(context),
                text: 'Tournament Mode',
                icon: Icons.emoji_events,
                gradient: true,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmTournamentMode(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Are you sure you want to enter Tournament Mode?',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await Future.wait([
      prefs.setBool('isTournamentMode', true),
      prefs.setInt('tournamentID', tournament.id),
    ]);
    myAppKey.currentState?.reloadApp();
  }
}

class _EventDates extends StatelessWidget {
  const _EventDates({required this.tournament});

  final TournamentPreview tournament;

  @override
  Widget build(BuildContext context) {
    final start = tournament.startDate;
    if (start == null) return const SizedBox.shrink();

    final end = tournament.endDate;
    final dateFormat = DateFormat('EEE, MMM d, y');
    final dateText = end != null && end != start
        ? '${dateFormat.format(start)} - ${dateFormat.format(end)}'
        : dateFormat.format(start);

    return Text(
      dateText,
      style: TextStyle(
        fontSize: 16,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }
}

String _welcomeMessage(int hour) {
  if (hour < 12) return 'Good Morning';
  if (hour < 18) return 'Good Afternoon';
  return 'Good Evening';
}
