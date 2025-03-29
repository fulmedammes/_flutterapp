import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
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
                padding: const EdgeInsets.all(8.0),
                child: Text('Update Available: $_latestVersion'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => const HomeScreen()),
                );
              },
              child: const Text('Refresh for Updates'),
            ),
          ],
        ),
      ),
    );
  }
}
