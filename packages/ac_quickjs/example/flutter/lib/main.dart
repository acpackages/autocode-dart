import 'package:flutter/material.dart';
import 'package:ac_quickjs/ac_quickjs.dart';

void main() {
  runApp(const QuickJsApp());
}

class QuickJsApp extends StatefulWidget {
  const QuickJsApp({super.key});

  @override
  State<QuickJsApp> createState() => _QuickJsAppState();
}

class _QuickJsAppState extends State<QuickJsApp> {
  String _output = 'Press Run to evaluate JavaScript via ac_quickjs';
  bool _isRunning = false;

  Future<void> _runScript() async {
    setState(() {
      _isRunning = true;
      _output = 'Evaluating...';
    });

    try {
      final engine = await JsEngine.create();
      await engine.init(
        bridge: (value) async {
          return JsResult.ok(
            JsValue.string('Dart Flutter Bridge received: ${value.value}'),
          );
        },
      );

      final r1 = await engine.eval(source: JsCode.code('1 + 2 * 3'));
      final r2 = await engine.eval(
        source: JsCode.code('Promise.resolve("Async QuickJS works in Flutter!")'),
      );
      final r3 = await engine.eval(
        source: JsCode.code('fjs.bridge_call("ping from Flutter UI")'),
      );

      await engine.close();

      setState(() {
        _output =
            '1. Math: ${r1.value}\n2. Promise: ${r2.value}\n3. Bridge: ${r3.value}';
      });
    } catch (e) {
      setState(() {
        _output = 'Error: $e';
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('ac_quickjs Flutter Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: _isRunning ? null : _runScript,
                child: Text(_isRunning ? 'Running...' : 'Run QuickJS Script'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _output,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
