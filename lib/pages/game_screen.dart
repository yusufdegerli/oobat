import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oobat/database_helper.dart';
import 'dart:math';

class GameScreen extends StatefulWidget {
  final Map<String, dynamic> team1;
  final Map<String, dynamic> team2;
  final int roundDuration;
  final int passCount;

  const GameScreen({required this.team1, required this.team2, required this.passCount, required this.roundDuration, super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  late Timer _timer;
  late int _start;
  late int _passCount;
  bool _isTeam1Turn = true;
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  String _mainWord = '';
  List<String> _forbiddenWords = [];
  List<Map<String, dynamic>> _wordPool = []; // Kelime havuzu
  int _currentWordIndex = 0; // Havuzdan kullanılan kelime indeksi

  @override
  void initState() {
    super.initState();
    _start = widget.roundDuration;
    _passCount = widget.passCount;
    _loadWordPool(); // Kelime havuzunu yükle
    setState(() {
      _mainWord = "Ana Kelime";
      _forbiddenWords = [
        "Yasak Kelime 1",
        "Yasak Kelime 2",
        "Yasak Kelime 3",
        "Yasak Kelime 4",
        "Yasak Kelime 5"
      ];
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _showReadyDialog());
  }

  Future<void> _loadWordPool() async {
    _wordPool = await _databaseHelper.getRandomWords(100); // 100 kelime önceden yükle
    if (_wordPool.isEmpty) {
      _wordPool = await _databaseHelper.getRandomWords(50); // Yedek plan
    }
    _currentWordIndex = 0;
    _nextWord(); // İlk kelimeyi ayarla
  }

  void _nextWord() {
    if (_wordPool.isEmpty) return;
    if (_currentWordIndex >= _wordPool.length) {
      _currentWordIndex = 0; // Havuzu sıfırla veya yeniden yükle (isteğe bağlı)
    }
    final word = _wordPool[_currentWordIndex];
    setState(() {
      _mainWord = word['kelime'] ?? '';
      _forbiddenWords = [
        word['yasak1'] ?? '',
        word['yasak2'] ?? '',
        word['yasak3'] ?? '',
        word['yasak4'] ?? '',
        word['yasak5'] ?? ''
      ];
    });
    _currentWordIndex++;
  }

  void startTimer() {
    _start = widget.roundDuration;
    _nextWord(); // Yeni kelime ayarla
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isTeam1Turn = !_isTeam1Turn;
        });
        _showReadyDialog();
        _timer.cancel();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void correctButtonPressed() {
    if (_isTeam1Turn) {
      widget.team1[widget.team1.keys.first]!['score'] += 1;
    } else {
      widget.team2[widget.team2.keys.first]!['score'] += 1;
    }
    _nextWord(); // Havuzdan yeni kelime
    _databaseHelper.incrementCounter(_mainWord);
  }

  void passButtonPressed() {
    if (_isTeam1Turn) {
      if (widget.team1[widget.team1.keys.first]!['pass'] == 0) {
        return;
      }
      widget.team1[widget.team1.keys.first]!['pass'] -= 1;
    } else {
      if (widget.team2[widget.team2.keys.first]!['pass'] == 0) {
        return;
      }
      widget.team2[widget.team2.keys.first]!['pass'] -= 1;
    }
    _nextWord(); // Havuzdan yeni kelime
    _databaseHelper.incrementCounter(_mainWord);
  }

  void tabooButtonPressed() {
    if (_isTeam1Turn) {
      widget.team1[widget.team1.keys.first]!['score'] -= 1;
    } else {
      widget.team2[widget.team2.keys.first]!['score'] -= 1;
    }
    _nextWord(); // Havuzdan yeni kelime
    _databaseHelper.incrementCounter(_mainWord);
  }

  void _showReadyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            _isTeam1Turn ? "${widget.team1.keys.first} adlı takımın sırası" : "${widget.team2.keys.first} adlı takımın sırası",
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
          content: Text(
            "${widget.team1.keys.first}:\t${widget.team1[widget.team1.keys.first]!['score']}\n${widget.team2.keys.first}:\t${widget.team2[widget.team2.keys.first]!['score']}",
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
          actions: <Widget>[
            OutlinedButton(
              child: const Text("Hazır", style: TextStyle(fontSize: 20, color: Colors.white)),
              onPressed: () {
                if (_isTeam1Turn) {
                  widget.team1[widget.team1.keys.first]!['pass'] = _passCount;
                } else {
                  widget.team2[widget.team2.keys.first]!['pass'] = _passCount;
                }
                Navigator.of(context).pop();
                startTimer();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double buttonBottomMargin = (((MediaQuery.sizeOf(context).height - 667.0) / 177.0) * 30.0).toInt().toDouble();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Süre: $_start',
              style: const TextStyle(fontSize: 24, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Divider(color: Colors.white54),
                Text(
                  _mainWord,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const Divider(color: Colors.white54),
                ..._forbiddenWords.map((word) => Column(
                  children: [
                    Text(
                      word,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const Divider(color: Colors.white54),
                  ],
                )),
                const SizedBox(height: 34),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                "Skor: ${_isTeam1Turn ? widget.team1[widget.team1.keys.first]!['score'] : widget.team2[widget.team2.keys.first]!['score']}",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.only(bottom: buttonBottomMargin),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          tabooButtonPressed();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const BeveledRectangleBorder(),
                          elevation: 0,
                          backgroundColor: const Color.fromARGB(255, 150, 50, 43),
                          overlayColor: Colors.black38,
                          minimumSize: const Size(0, 80),
                        ),
                        child: const Text(
                          'Taboo',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (_isTeam1Turn && widget.team1[widget.team1.keys.first]!['pass'] == 0) ||
                            (widget.team2[widget.team2.keys.first]!['pass'] == 0 && !_isTeam1Turn)
                            ? null
                            : () {
                          passButtonPressed();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const BeveledRectangleBorder(),
                          elevation: 0,
                          backgroundColor: const Color.fromARGB(255, 204, 183, 0),
                          overlayColor: Colors.black38,
                          minimumSize: const Size(0, 80),
                        ),
                        child: const Text(
                          'Pas',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          correctButtonPressed();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const BeveledRectangleBorder(),
                          elevation: 0,
                          backgroundColor: const Color.fromARGB(255, 69, 129, 71),
                          overlayColor: Colors.black38,
                          minimumSize: const Size(0, 80),
                        ),
                        child: const Text(
                          'Doğru',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}