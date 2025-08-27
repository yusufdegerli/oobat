import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:oobat/database_helper.dart';
import 'dart:async';
import 'package:oobat/pages/team_set.dart';
import 'package:oobat/pages/scoreboard.dart';

class CardSwipe extends StatefulWidget {
  final Map<String, dynamic> team1;
  final Map<String, dynamic> team2;
  final int roundDuration;
  final int passCount;

  const CardSwipe({
    required this.team1,
    required this.team2,
    required this.roundDuration,
    required this.passCount,
    super.key,
  });

  @override
  _CardSwipeState createState() => _CardSwipeState();
}

class _CardSwipeState extends State<CardSwipe> {
  MatchEngine? _matchEngine;
  final List<SwipeItem> _swipeItems = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  int _remainingTime = 0;
  Timer? _timer;
  List<Map<String, dynamic>> _wordPool = [];
  int _currentWordIndex = 0;
  bool _isTeam1Turn = true;
  List<List<int>> roundScores = [];

  int _team1NopeCount = 0;
  int _team1LikeCount = 0;
  int _team1PassCount = 0;
  int _team2NopeCount = 0;
  int _team2LikeCount = 0;
  int _team2PassCount = 0;

  final List<int> _bonusPassScores = [3, 8, 14, 18];
  final List<int> _bonusTimeScores = [5, 6, 12, 17, 20];

  @override
  void initState() {
    super.initState();
    _loadWordPool();
    _startNewTurn();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadWordPool() async {
    _wordPool = await _databaseHelper.getRandomWords(100);
    if (_wordPool.isEmpty) {
      _wordPool = await _databaseHelper.getRandomWords(50);
    }
    _currentWordIndex = 0;
    _addInitialWordsToSwipeItems();
    setState(() {
      _matchEngine = MatchEngine(swipeItems: _swipeItems);
    });
  }

  void _checkGameEnd() {
    if (_team1LikeCount >= 20 || _team2LikeCount >= 20) {
      _timer?.cancel();
      String winner = _team1LikeCount >= 20 ? widget.team1.keys.first : widget.team2.keys.first;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              'Oyun Bitti!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
              ),
            ),
            content: Text(
              '$winner kazandı!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
              ),
            ),
            actions: <Widget>[
              OutlinedButton(
                child: Text(
                  "Tamam",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const TeamSet()),
                        (route) => false,
                  );
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _startNewTurn() {
    int roundDuration = widget.roundDuration;

    if (_isTeam1Turn && _bonusTimeScores.contains(_team1LikeCount)) {
      roundDuration += 30;
    } else if (!_isTeam1Turn && _bonusTimeScores.contains(_team2LikeCount)) {
      roundDuration += 30;
    }

    int passCount = widget.passCount;
    if (_isTeam1Turn && _bonusPassScores.contains(_team1LikeCount)) {
      passCount += 1;
    } else if (!_isTeam1Turn && _bonusPassScores.contains(_team2LikeCount)) {
      passCount += 1;
    }

    setState(() {
      _remainingTime = roundDuration;
      if (_isTeam1Turn) {
        _team1PassCount = passCount;
      } else {
        _team2PassCount = passCount;
      }
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
        roundScores.add([_team1LikeCount, _team2LikeCount]);
        _checkGameEnd();
        if (_team1LikeCount < 20 && _team2LikeCount < 20) {
          _showReadyDialog();
        }
      }
    });
  }

  void _addInitialWordsToSwipeItems() {
    for (int i = 0; i < 50 && i < _wordPool.length; i++) {
      final value = _wordPool[i];
      if (value.isNotEmpty) {
        _swipeItems.add(
          SwipeItem(
            content: {
              'mainWord': value['kelime'] ?? 'DİK',
              'forbiddenWords': [
                value['yasak1'] ?? 'Açı',
                value['yasak2'] ?? 'Eğik',
                value['yasak3'] ?? 'Yatık',
                value['yasak4'] ?? 'Sert',
                value['yasak5'] ?? 'Durmak',
              ],
            },
            likeAction: () {
              setState(() {
                if (_isTeam1Turn) {
                  _team1LikeCount++;
                } else {
                  _team2LikeCount++;
                }
              });
              _databaseHelper.incrementCounter(value['kelime'] ?? '');
              _checkAndAddMore();
              _checkGameEnd();
            },
            nopeAction: () {
              setState(() {
                if (_isTeam1Turn) {
                  _team1NopeCount++;
                  _team1LikeCount--;
                  if (_team1LikeCount < 0) _team1LikeCount = 0;
                } else {
                  _team2NopeCount++;
                  _team2LikeCount--;
                  if (_team2LikeCount < 0) _team2LikeCount = 0;
                }
              });
              _databaseHelper.incrementCounter(value['kelime'] ?? '');
              _checkAndAddMore();
              _checkGameEnd();
            },
            superlikeAction: () {
              if ((_isTeam1Turn && _team1PassCount > 0) || (!_isTeam1Turn && _team2PassCount > 0)) {
                setState(() {
                  if (_isTeam1Turn) {
                    _team1PassCount--;
                  } else {
                    _team2PassCount--;
                  }
                });
                _databaseHelper.incrementCounter(value['kelime'] ?? '');
                _checkAndAddMore();
              }
            },
          ),
        );
      }
    }
  }

  void _checkAndAddMore() {
    if (_swipeItems.length - _currentWordIndex <= 5 && _currentWordIndex < _wordPool.length) {
      _addMoreWordsToSwipeItems();
    }
  }

  void _addMoreWordsToSwipeItems() {
    for (int i = _currentWordIndex; i < _currentWordIndex + 10 && i < _wordPool.length; i++) {
      final value = _wordPool[i];
      if (value.isNotEmpty) {
        _swipeItems.add(
          SwipeItem(
            content: {
              'mainWord': value['kelime'] ?? 'DİK',
              'forbiddenWords': [
                value['yasak1'] ?? 'Açı',
                value['yasak2'] ?? 'Eğik',
                value['yasak3'] ?? 'Yatık',
                value['yasak4'] ?? 'Sert',
                value['yasak5'] ?? 'Durmak',
              ],
            },
            likeAction: () {
              setState(() {
                if (_isTeam1Turn) {
                  _team1LikeCount++;
                } else {
                  _team2LikeCount++;
                }
              });
              _databaseHelper.incrementCounter(value['kelime'] ?? '');
              _checkAndAddMore();
              _checkGameEnd();
            },
            nopeAction: () {
              setState(() {
                if (_isTeam1Turn) {
                  _team1NopeCount++;
                  _team1LikeCount--;
                  if (_team1LikeCount < 0) _team1LikeCount = 0;
                } else {
                  _team2NopeCount++;
                  _team2LikeCount--;
                  if (_team2LikeCount < 0) _team2LikeCount = 0;
                }
              });
              _databaseHelper.incrementCounter(value['kelime'] ?? '');
              _checkAndAddMore();
              _checkGameEnd();
            },
            superlikeAction: () {
              if ((_isTeam1Turn && _team1PassCount > 0) || (!_isTeam1Turn && _team2PassCount > 0)) {
                setState(() {
                  if (_isTeam1Turn) {
                    _team1PassCount--;
                  } else {
                    _team2PassCount--;
                  }
                });
                _databaseHelper.incrementCounter(value['kelime'] ?? '');
                _checkAndAddMore();
              }
            },
          ),
        );
      }
    }
  }

  // card_swipe.dart dosyasındaki _showReadyDialog fonksiyonunu güncelle:

  void _showReadyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            _isTeam1Turn
                ? "${widget.team2.keys.first} adlı takımın sırası"
                : "${widget.team1.keys.first} adlı takımın sırası",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          content: Text(
            "${widget.team1.keys.first}: $_team1LikeCount\n${widget.team2.keys.first}: $_team2LikeCount",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white,
            ),
          ),
          actions: <Widget>[
            OutlinedButton(
              child: Text(
                "Hazır",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _isTeam1Turn = !_isTeam1Turn;
                _startNewTurn();
              },
            ),
            OutlinedButton(
              child: Text(
                "Skorları Gör",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scoreboard(
                      team1Name: widget.team1.keys.first,
                      team2Name: widget.team2.keys.first,
                      scores: roundScores,
                      team1: widget.team1,
                      team2: widget.team2,
                      roundDuration: widget.roundDuration,
                      passCount: widget.passCount,
                      isGameActive: true, // Oyun hala devam ediyor
                    ),
                  ),
                ).then((_) {
                  // Scoreboard'dan geri döndüğünde bir sonraki takımın sırası
                  setState(() {
                    _isTeam1Turn = !_isTeam1Turn;
                    _startNewTurn();
                  });
                });
              },
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  Widget _buildSwipeCards() {
    return SwipeCards(
      matchEngine: _matchEngine!,
      itemBuilder: (BuildContext context, int index) {
        final Map<String, dynamic> data = _swipeItems[index].content;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/default_card_template.jpg',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey,
                    child: Center(
                      child: Text(
                        'Resim yüklenemedi: $error',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Text(
                    data['mainWord'],
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          blurRadius: 5,
                          color: Colors.brown,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          data['forbiddenWords'][i],
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      onStackFinished: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Stack Finished",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            duration: const Duration(milliseconds: 500),
          ),
        );
      },
      itemChanged: (SwipeItem item, int index) {
        setState(() {
          _currentWordIndex = index + 1;
        });
        _checkAndAddMore();
      },
      upSwipeAllowed: (_isTeam1Turn && _team1PassCount > 0) || (!_isTeam1Turn && _team2PassCount > 0),
      fillSpace: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF334d64),
        title: Text(
          'Matrix',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/switch_card_wp.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Text(
                      _isTeam1Turn ? widget.team1.keys.first : widget.team2.keys.first,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Skor: ${_isTeam1Turn ? _team1LikeCount : _team2LikeCount}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tabu: ${_isTeam1Turn ? _team1NopeCount : _team2NopeCount}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Süre: ${_formatTime(_remainingTime)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pas Hakkı: ${_isTeam1Turn ? _team1PassCount : _team2PassCount}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SizedBox(
                    height: 576,
                    width: 384,
                    child: _matchEngine == null || _swipeItems.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : _buildSwipeCards(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: const Color(0xFFB75265),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _matchEngine!.currentItem?.nope(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                "Oobat",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            ElevatedButton(
              onPressed: (_isTeam1Turn && _team1PassCount > 0) || (!_isTeam1Turn && _team2PassCount > 0)
                  ? () => _matchEngine!.currentItem?.superLike()
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                "Pas",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            ElevatedButton(
              onPressed: () => _matchEngine!.currentItem?.like(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                "Doğru",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}