import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ac_patches/ac_patches.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ac_patches updater
  final patchesDir = Directory('${Directory.current.path}/patches'.replaceAll('/', Platform.pathSeparator));
  await AcPatches.instance.initialize(
    serverUrl: 'http://localhost:8080',
    appId: 'com.accountea.patchdemo',
    releaseId: '1.0.0+1',
    buildNumber: 1,
    baseReleaseHash: 'sha256:base_release_hash_v1',
    publicKeyBase64: 'EXAMPLE_PUBLIC_KEY',
    platform: AcEnumPatchPlatform.windows,
    architecture: AcEnumPatchArchitecture.x86_64,
    patchesDirectory: patchesDir,
  );

  // Confirm healthy startup after successful boot
  await AcPatches.instance.markHealthy();

  runApp(const PatchDemoApp());
}

class PatchDemoApp extends StatelessWidget {
  const PatchDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ac_patches Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PatchDemoHomeScreen(),
    );
  }
}

class PatchDemoHomeScreen extends StatefulWidget {
  const PatchDemoHomeScreen({super.key});

  @override
  State<PatchDemoHomeScreen> createState() => _PatchDemoHomeScreenState();
}

class _PatchDemoHomeScreenState extends State<PatchDemoHomeScreen> {
  final List<String> _logs = [];
  bool _isChecking = false;
  bool _isDownloading = false;

  void _addLog(String msg) {
    setState(() {
      final time = DateTime.now().toLocal().toString().substring(11, 19);
      _logs.insert(0, '[$time] $msg');
    });
  }

  Future<void> _checkUpdate() async {
    setState(() => _isChecking = true);
    _addLog('Checking update server...');
    try {
      final hasUpdate = await AcPatches.instance.checkForUpdate();
      if (hasUpdate) {
        final update = AcPatches.instance.availableUpdate!;
        _addLog('Update Available: ${update.patchId} (${update.size} bytes)');
      } else {
        _addLog('No updates available for current track.');
      }
    } catch (e) {
      _addLog('Error: $e');
    } finally {
      setState(() => _isChecking = false);
    }
  }

  Future<void> _downloadUpdate() async {
    if (AcPatches.instance.availableUpdate == null) {
      _addLog('No update available to download. Check first.');
      return;
    }
    setState(() => _isDownloading = true);
    _addLog('Downloading & verifying patch...');
    try {
      final success = await AcPatches.instance.downloadUpdate();
      if (success) {
        _addLog('Patch verified & staged in pending/!');
      } else {
        _addLog('Download or signature verification failed.');
      }
    } catch (e) {
      _addLog('Download error: $e');
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  Future<void> _activatePending() async {
    _addLog('Activating pending patch for restart...');
    final activated = await AcPatches.instance.activateOnRestart();
    if (activated) {
      _addLog('Success: Patch moved to active/! Restart app to execute.');
    } else {
      _addLog('No pending patch found.');
    }
  }

  Future<void> _markHealthy() async {
    await AcPatches.instance.markHealthy();
    _addLog('Patch marked healthy. Failure counter reset.');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = AcPatches.instance.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ac_patches OTA Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Application & Patch Status',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Release Version:'),
                        const Text('1.0.0+1 (Base)', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Active Patch:'),
                        Text(
                          state.activePatchId ?? 'None (Running Base Code)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: state.activePatchId != null ? Colors.green : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pending Patch:'),
                        Text(
                          state.pendingPatchId ?? 'None',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: state.pendingPatchId != null ? Colors.orange : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Crash Counter:'),
                        Text(
                          '${state.failureCount} / ${state.maxFailuresThreshold}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: state.failureCount > 0 ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Action Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isChecking ? null : _checkUpdate,
                  icon: const Icon(Icons.cloud_sync),
                  label: Text(_isChecking ? 'Checking...' : 'Check Update'),
                ),
                ElevatedButton.icon(
                  onPressed: _isDownloading ? null : _downloadUpdate,
                  icon: const Icon(Icons.download),
                  label: Text(_isDownloading ? 'Downloading...' : 'Download Update'),
                ),
                ElevatedButton.icon(
                  onPressed: _activatePending,
                  icon: const Icon(Icons.system_update_alt),
                  label: const Text('Activate on Restart'),
                ),
                OutlinedButton.icon(
                  onPressed: _markHealthy,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark Healthy'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Live Log Console
            const Text(
              'Activity Log',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, i) => Text(
                    _logs[i],
                    style: const TextStyle(
                      color: Colors.lightGreenAccent,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
