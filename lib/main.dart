import 'package:flutter/material.dart';

import 'NFC_Reader_Screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo NFC Card Read',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFFF8F8FF)
        ),
        home:  NFCReaderScreen()
    );
  }
}

