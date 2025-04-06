import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_gate.dart';
import 'dart:js' as js; // For accessing JS environment variables in web

// Environment variable handler
class EnvConfig {
  static Future<Map<String, String>> getVariables() async {
    Map<String, String> variables = {};
    
    // Check for web environment first to access window.ENV
    if (kIsWeb) {
      try {
        // Access the environment variables set by GitHub Actions
        final env = js.context['ENV'];
        if (env != null) {
          final supabaseUrl = env['SUPABASE_URL'];
          final supabaseAnonKey = env['SUPABASE_ANON_KEY'];
          
          if (supabaseUrl != null) variables['SUPABASE_URL'] = supabaseUrl.toString();
          if (supabaseAnonKey != null) variables['SUPABASE_ANON_KEY'] = supabaseAnonKey.toString();
          
          print('Loaded environment variables from window.ENV');
        }
      } catch (e) {
        print('Error accessing window.ENV: $e');
      }
    }
    
    // If we couldn't get variables from window.ENV (or not on web),
    // try to load from .env file
    if (variables.isEmpty) {
      try {
        // Try to load .env, but handle the case where it doesn't exist
        await dotenv.load(fileName: ".env");
        
        final supabaseUrl = dotenv.env['SUPABASE_URL'];
        final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
        
        if (supabaseUrl != null) variables['SUPABASE_URL'] = supabaseUrl;
        if (supabaseAnonKey != null) variables['SUPABASE_ANON_KEY'] = supabaseAnonKey;
        
        print('Loaded environment variables from .env file');
      } catch (e) {
        // Simply log the error and continue - .env is optional
        print('Note: .env file not found or not readable. This is expected in production.');
      }
    }

    return variables;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get environment variables from either .env or environment
  final config = await EnvConfig.getVariables();
  
  // Get URL and key (prioritize environment when available)
  final supabaseUrl = config['SUPABASE_URL'];
  final supabaseAnonKey = config['SUPABASE_ANON_KEY'];

  // Check if we have the required configuration
  if (supabaseUrl == null || supabaseAnonKey == null) {
    print('ERROR: Missing Supabase credentials. Make sure SUPABASE_URL and SUPABASE_ANON_KEY are set.');
    // In a real app, you'd want to show an error screen
  } else {
    // Initialize Supabase with the credentials
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  runApp(const MyApp());
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
