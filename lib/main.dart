import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Try reading from --dart-define compile-time variables
  // Default to an empty string if the variable is not set.
  const String supabaseUrlFromEnv = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  const String supabaseAnonKeyFromEnv = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  String? supabaseUrl = supabaseUrlFromEnv.isNotEmpty ? supabaseUrlFromEnv : null;
  String? supabaseAnonKey = supabaseAnonKeyFromEnv.isNotEmpty ? supabaseAnonKeyFromEnv : null;

  bool loadedFromDartDefine = supabaseUrl != null && supabaseAnonKey != null;

  // 2. If not found via --dart-define, try loading .env for local development
  if (!loadedFromDartDefine) {
    print('Compile-time variables not found or incomplete. Attempting to load .env file...');
    try {
      await dotenv.load(fileName: ".env");
      // Use the values from .env only if they weren't already set by --dart-define
      supabaseUrl ??= dotenv.env['SUPABASE_URL'];
      supabaseAnonKey ??= dotenv.env['SUPABASE_ANON_KEY'];

      if (dotenv.env.containsKey('SUPABASE_URL') && dotenv.env.containsKey('SUPABASE_ANON_KEY')) {
         print('Loaded environment variables from .env file.');
      } else {
         print('Warning: .env file loaded, but SUPABASE_URL or SUPABASE_ANON_KEY might be missing in it.');
      }
    } catch (e) {
      // It's okay if .env doesn't exist or fails to load
      print('Note: .env file not found or failed to load. This is expected if running without a .env file.');
    }
  } else {
     print('Loaded environment variables from compile-time definitions (--dart-define).');
  }

  // 3. Check credentials and initialize Supabase
  if (supabaseUrl == null || supabaseUrl.isEmpty || supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
    print('ERROR: Supabase credentials missing.');
    print('Ensure SUPABASE_URL and SUPABASE_ANON_KEY are provided either via --dart-define for builds or in a .env file for local execution.');
    runApp(const ErrorApp(message: 'Supabase configuration missing.'));
    return; 
  } 
  
  try {
    print('Initializing Supabase...');
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    print('Supabase initialized successfully.');
    runApp(const MyApp());

  } catch (e) {
    print('ERROR: Failed to initialize Supabase: $e');
    runApp(ErrorApp(message: 'Failed to initialize Supabase: $e'));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My PWA App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Simple Error App to display initialization errors
class ErrorApp extends StatelessWidget {
  final String message;
  const ErrorApp({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Application Initialization Failed:\n$message',
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
