import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';

import './screens/faro.dart';

// final theme = ThemeData().copyWith(
//   useMaterial3: true,
//   textTheme: GoogleFonts.
// );

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      title: 'Faro²',
      home: const FaroScreen(),
    );
  }
}
