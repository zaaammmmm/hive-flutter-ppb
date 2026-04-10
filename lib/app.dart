import 'package:flutter/material.dart';
import 'package:mahasiswa_app/views/mahasiswa_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MahasiswaPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
