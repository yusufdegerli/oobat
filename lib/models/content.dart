import 'package:flutter/material.dart';
import 'package:oobat/pages/game_screen.dart';
import 'package:oobat/pages/card_swipe.dart'; // CardSwipe'ı import edin

class Content {
  final String text;
  final Color color;
  final String imagePath;

  const Content({
    required this.text,
    required this.color,
    this.imagePath = 'assets/images/default_card_template.jpg',
  });
}