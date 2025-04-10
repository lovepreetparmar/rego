import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_with_code.dart';
import 'providers/language_provider.dart';

void main() {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: SafeArea(
        child: MaterialApp(
          title: 'Rego HR',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const LoginWithCode(),
        ),
      ),
    );
  }
}
