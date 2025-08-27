import 'package:flutter/material.dart';
import 'package:oobat/pages/game_screen.dart';
import 'package:oobat/pages/card_swipe.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';

class TeamSet extends StatefulWidget {
  const TeamSet({super.key});

  @override
  TeamSetState createState() => TeamSetState();
}

class TeamSetState extends State<TeamSet> {
  final TextEditingController _team1Controller = TextEditingController();
  final TextEditingController _team2Controller = TextEditingController();
  int _roundDuration = 60;
  int _passCount = 3;

  // Ses çalar için AudioPlayer instance'ı
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    // AudioPlayer'ı temizle
    _audioPlayer.dispose();
    _team1Controller.dispose();
    _team2Controller.dispose();
    super.dispose();
  }

  Future<void> _startGame() async {
    // Ses çal
    await _playButtonSound();

    if (_team1Controller.text.trim() == _team2Controller.text.trim() &&
        !(_team1Controller.text.isEmpty && _team2Controller.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Takım isimleri aynı olamaz!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
      return;
    }
    String team1 = _team1Controller.text.trim().isEmpty ? "Takım 1" : _team1Controller.text.trim();
    String team2 = _team2Controller.text.trim().isEmpty ? "Takım 2" : _team2Controller.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          team1: {team1: {"score": 0, "pass": _passCount}},
          team2: {team2: {"score": 0, "pass": _passCount}},
          roundDuration: _roundDuration,
          passCount: _passCount,
        ),
      ),
    );
  }

  // Ses çalma fonksiyonu
  Future<void> _playButtonSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/keyboardsound.mp3'));
    } catch (e) {
      print('Ses çalınamadı: $e');
    }
  }

  Future<void> _goToMatrixScreen() async {
    // Önce ses çal
    await _playButtonSound();

    String team1 = _team1Controller.text.trim().isEmpty ? "Takım 1" : _team1Controller.text.trim();
    String team2 = _team2Controller.text.trim().isEmpty ? "Takım 2" : _team2Controller.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardSwipe(
          team1: {team1: {"score": 0, "pass": _passCount}},
          team2: {team2: {"score": 0, "pass": _passCount}},
          roundDuration: _roundDuration,
          passCount: _passCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Takım Seç',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        backgroundColor: Color(0xFF716098),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/sora_wp.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<int>(
                    value: _roundDuration,
                    items: [30, 60, 90, 120].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(
                          '$value saniye',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        _roundDuration = newValue!;
                      });
                    },
                  ),
                  DropdownButton<int>(
                    value: _passCount,
                    items: [1, 2, 3, 4, 5].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(
                          '$value pas',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        _passCount = newValue!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _team1Controller,
                decoration: InputDecoration(
                  labelText: 'Takım 1',
                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.5),
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _team2Controller,
                decoration: InputDecoration(
                  labelText: 'Takım 2',
                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.5),
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              // "Oyunu Başlat" butonu - "OYNA!" ile aynı stil
              Container(
                width: double.infinity,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF808080),
                      Color(0xFFBFBFBF),
                      Color(0xFFDFDFDF),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      offset: Offset(3, 3),
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.3),
                      offset: Offset(-1, -1),
                      blurRadius: 0,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(
                    color: Color(0xFFDFDFDF),
                    width: 2,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _startGame,
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/w95logo.svg',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Oyunu Başlat',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ],
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // "OYNA!" butonu
              Container(
                width: double.infinity,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF808080),
                      Color(0xFFBFBFBF),
                      Color(0xFFDFDFDF),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      offset: Offset(3, 3),
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.3),
                      offset: Offset(-1, -1),
                      blurRadius: 0,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(
                    color: Color(0xFFDFDFDF),
                    width: 2,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _goToMatrixScreen,
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/w95logo.svg',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'OYNA!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ],
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}