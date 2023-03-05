import 'package:flutter/material.dart';
import 'package:test_database/database.dart';
import 'package:flutter/material.dart';
import 'package:test_database/homePage.dart';


void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  runApp(const SqfliteApp());
}

class SqfliteApp extends StatelessWidget {
  const SqfliteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // Remove the debug banner
        debugShowCheckedModeBanner: false,
        title: 'SQLITE',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: const MyApp());
  }
}