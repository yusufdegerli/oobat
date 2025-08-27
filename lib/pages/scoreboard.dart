import 'package:flutter/material.dart';
import 'package:oobat/pages/team_set.dart';
import 'package:oobat/pages/card_swipe.dart';

class Scoreboard extends StatelessWidget {
  final String team1Name;
  final String team2Name;
  final List<List<int>> scores;
  final Map<String, dynamic>? team1;
  final Map<String, dynamic>? team2;
  final int? roundDuration;
  final int? passCount;
  final bool? isGameActive; // Oyun aktif mi kontrol etmek için

  const Scoreboard({
    required this.team1Name,
    required this.team2Name,
    required this.scores,
    this.team1,
    this.team2,
    this.roundDuration,
    this.passCount,
    this.isGameActive,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Skor Tablosu',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Stack(
        children: [
          // Arka plan resmi - Tam ekran
          Positioned.fill(
            child: Image.asset(
              'assets/images/radio_wallpaper.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // İçerik
          Column(
            children: [
              // Üst kısım - Tablo ve scoreboard
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        color: Colors.black.withOpacity(0.7),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DataTable(
                            columns: [
                              DataColumn(
                                label: Text(
                                  'Tur',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  team1Name,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  team2Name,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                            rows: List<DataRow>.generate(
                              scores.length,
                                  (index) => DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      'Tur ${index + 1}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      scores[index][0].toString(),
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      scores[index][1].toString(),
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: SizedBox(
                          height: 220,
                          child: _buildVisualProgressPath(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Alt kısım - Butonlar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Oyun aktifse "Oyuna Devam Et" butonu göster
                    if (isGameActive == true &&
                        team1 != null &&
                        team2 != null &&
                        roundDuration != null &&
                        passCount != null)
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Oyuna Devam Et',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const TeamSet()),
                                (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Ana Menüye Dön',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisualProgressPath(BuildContext context) {
    int totalScoreTeam1 = scores.isNotEmpty
        ? scores.map((s) => s[0]).reduce((a, b) => a + b)
        : 0;
    int totalScoreTeam2 = scores.isNotEmpty
        ? scores.map((s) => s[1]).reduce((a, b) => a + b)
        : 0;

    int stepTeam1 = (totalScoreTeam1 / 2).floor().clamp(0, 20);
    int stepTeam2 = (totalScoreTeam2 / 2).floor().clamp(0, 20);

    final stepPositions = <Offset>[
      const Offset(40, 30),
      const Offset(90, 30),
      const Offset(140, 30),
      const Offset(190, 30),
      const Offset(240, 30),
      const Offset(290, 30),
      const Offset(340, 30),
      const Offset(390, 70),
      const Offset(360, 110),
      const Offset(310, 110),
      const Offset(260, 110),
      const Offset(210, 110),
      const Offset(160, 110),
      const Offset(110, 110),
      const Offset(60, 110),
      const Offset(10, 110),
      const Offset(10, 160),
      const Offset(60, 160),
      const Offset(110, 160),
      const Offset(160, 160),
    ];

    return Stack(
      children: [
        Image.asset('assets/images/scoreboard.png'),
        if (stepTeam1 > 0)
          Positioned(
            left: stepPositions[stepTeam1 - 1].dx,
            top: stepPositions[stepTeam1 - 1].dy,
            child: Text(
              team1Name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red,
              ),
            ),
          ),
        if (stepTeam2 > 0)
          Positioned(
            left: stepPositions[stepTeam2 - 1].dx,
            top: stepPositions[stepTeam2 - 1].dy + 10,
            child: Text(
              team2Name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }
}