import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/analyze_viewmodel.dart';
import 'views/home_page.dart';
// import 'views/analyze_page.dart'; // alternatif olarak direkt açılacaksa

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => AnalyzeViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CheatBuster',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: Colors.blueGrey.shade200,
          secondary: Colors.tealAccent.shade200,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(), // veya const AnalyzePage()
    );
  }
}
