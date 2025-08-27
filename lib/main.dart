import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oobat/pages/team_set.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        // LoveDays tarzı alternatif fontlar (hepsi Türkçe destekli)
        textTheme: TextTheme(
          displayLarge: GoogleFonts.kalam( // En yakın alternatif
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          displayMedium: GoogleFonts.kalam( // Zarif script font
            fontSize: 32,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
          headlineSmall: GoogleFonts.kalam( // Hafif script font
            fontSize: 28,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
          bodyLarge: GoogleFonts.kalam( // Eğlenceli script
            fontSize: 20,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
          bodyMedium: GoogleFonts.kalam( // El yazısı tarzı
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.kalam(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: const TeamSet(),
    );
  }
}