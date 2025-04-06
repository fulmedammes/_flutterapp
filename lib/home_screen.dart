import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'version_widget.dart';
import 'update_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _updateAvailable = false;
  String _latestVersion = '';
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    final latestVersion = await UpdateService.getLatestVersion();
    if (latestVersion != null) {
      final currentVersion = (await PackageInfo.fromPlatform()).version;

      if (latestVersion != currentVersion) {
        setState(() {
          _updateAvailable = true;
          _latestVersion = latestVersion;
        });
      }
    }
  }

  void _reloadApp() {
    // TODO: Implement PWA update mechanism here.
    // The previous html.window.location.reload() only works in a browser tab,
    // not reliably for installed PWAs. Need to interact with the service worker
    // (e.g., postMessage({action: 'skipWaiting'}) and then reload).
    print("Update Now button clicked - PWA reload logic needed.");
  }

  Future<void> _signOut() async {
    try {
      await _supabase.auth.signOut();
      // AuthGate will handle navigation
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign Out Failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Home Screen! #15'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: _signOut,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to the app!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const VersionWidget(),
            if (_updateAvailable)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Update Available: $_latestVersion', 
                      style: const TextStyle(
                        color: Colors.red, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _reloadApp,
                      icon: const Icon(Icons.system_update),
                      label: const Text('Update Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _checkForUpdates,
              icon: const Icon(Icons.refresh),
              label: const Text('Check for Updates'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('button x'),
            ),
          ],
        ),
      ),
    );
  }
}
