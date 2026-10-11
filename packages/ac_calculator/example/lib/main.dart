import 'package:flutter/material.dart';
import 'package:ac_calculator/ac_calculator.dart';

void main() {
  runApp(const CalculatorExampleApp());
}

class CalculatorExampleApp extends StatefulWidget {
  const CalculatorExampleApp({super.key});

  @override
  State<CalculatorExampleApp> createState() => _CalculatorExampleAppState();
}

class _CalculatorExampleAppState extends State<CalculatorExampleApp> {
  AcCalculatorTheme _theme = AcCalculatorTheme.windowsDark();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AC Calculator Example',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AC Calculator'),
          actions: [
            PopupMenuButton<AcCalculatorTheme>(
              tooltip: 'Choose Theme Preset',
              icon: const Icon(Icons.palette),
              onSelected: (theme) => setState(() => _theme = theme),
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: AcCalculatorTheme.windowsDark(),
                      child: const Text('Windows Dark'),
                    ),
                    PopupMenuItem(
                      value: AcCalculatorTheme.windowsLight(),
                      child: const Text('Windows Light'),
                    ),
                    PopupMenuItem(
                      value: AcCalculatorTheme.iphoneDark(),
                      child: const Text('iPhone Dark'),
                    ),
                    PopupMenuItem(
                      value: AcCalculatorTheme.iphoneLight(),
                      child: const Text('iPhone Light'),
                    ),
                  ],
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800, maxHeight: 750),
            child: AcCalculator(
              theme: _theme,
              initialMode: CalculatorMode.standard,
              enableHistory: true,
              enableMemory: true,
              enableCurrencyConverter: true,
              onResultChanged: (res) {
                debugPrint('Calculator result changed: $res');
              },
            ),
          ),
        ),
      ),
    );
  }
}
