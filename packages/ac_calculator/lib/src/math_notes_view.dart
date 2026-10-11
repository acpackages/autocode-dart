import 'package:flutter/material.dart';
import 'calculator_theme.dart';
import 'expression_evaluator.dart';
import 'converter.dart';

/// A single line in a typed math note
class MathNoteLine {
  String input;
  String result;
  String? error;

  MathNoteLine({required this.input, this.result = '', this.error});
}

/// A saved Math Note document
class MathNoteDocument {
  String id;
  String title;
  List<String> rawLines;

  MathNoteDocument({
    required this.id,
    required this.title,
    required this.rawLines,
  });
}

/// Evaluator engine for typed Math Notes with variable environments and conversions
class MathNotesEngine {
  final Map<String, double> variables = {};

  List<MathNoteLine> evaluateLines(List<String> rawLines) {
    variables.clear();
    final evaluated = <MathNoteLine>[];

    for (final raw in rawLines) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) {
        evaluated.add(MathNoteLine(input: raw, result: ''));
        continue;
      }

      // Check comments
      if (trimmed.startsWith('#') || trimmed.startsWith('//')) {
        evaluated.add(MathNoteLine(input: raw, result: ''));
        continue;
      }

      // 1. Check unit conversion pattern e.g. "50 m in ft" or "100 km to miles"
      final conversionMatch = RegExp(
        r'^(.+)\s+(?:in|to)\s+([a-zA-Z_°]+)$',
      ).firstMatch(trimmed);
      if (conversionMatch != null) {
        final exprPart = conversionMatch.group(1)!.trim();
        final targetUnitStr = conversionMatch.group(2)!.trim();

        // Extract value and source unit from exprPart e.g. "50 m"
        final sourceMatch = RegExp(
          r'^([\d\.\+\-\*\/\s\(\)]+)\s+([a-zA-Z_°]+)$',
        ).firstMatch(exprPart);
        if (sourceMatch != null) {
          final valExpr = sourceMatch.group(1)!.trim();
          final sourceUnitStr = sourceMatch.group(2)!.trim();

          try {
            final eval = MathExpressionEvaluator(variables: variables);
            final val = eval.evaluate(valExpr);

            // Find matching unit definition
            UnitDefinition? fromUnit;
            UnitDefinition? toUnit;
            UnitCategory? matchedCat;

            for (final cat in UnitCategory.values) {
              if (cat == UnitCategory.currency) continue;
              final list = UnitConverter.units[cat] ?? [];
              for (final u in list) {
                if (u.id.toLowerCase() == sourceUnitStr.toLowerCase() ||
                    u.symbol.toLowerCase() == sourceUnitStr.toLowerCase() ||
                    u.name.toLowerCase() == sourceUnitStr.toLowerCase()) {
                  fromUnit = u;
                  matchedCat = cat;
                }
                if (u.id.toLowerCase() == targetUnitStr.toLowerCase() ||
                    u.symbol.toLowerCase() == targetUnitStr.toLowerCase() ||
                    u.name.toLowerCase() == targetUnitStr.toLowerCase()) {
                  toUnit = u;
                }
              }
              if (fromUnit != null && toUnit != null) break;
            }

            if (fromUnit != null && toUnit != null && matchedCat != null) {
              final converted = UnitConverter.convert(
                category: matchedCat,
                from: fromUnit,
                to: toUnit,
                value: val,
              );
              final resStr = _formatNum(converted) + ' ' + toUnit.symbol;
              evaluated.add(MathNoteLine(input: raw, result: resStr));
              continue;
            }
          } catch (_) {}
        }
      }

      // 2. Check variable assignment e.g. "x = 10" or "width = 5 * 2"
      if (trimmed.contains('=')) {
        final parts = trimmed.split('=');
        final varName = parts[0].trim();
        final expr = parts.sublist(1).join('=').trim();

        if (RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(varName)) {
          try {
            final eval = MathExpressionEvaluator(variables: variables);
            final val = eval.evaluate(expr);
            if (!val.isNaN && !val.isInfinite) {
              variables[varName] = val;
              evaluated.add(MathNoteLine(input: raw, result: _formatNum(val)));
              continue;
            } else {
              evaluated.add(
                MathNoteLine(input: raw, error: 'Invalid expression'),
              );
              continue;
            }
          } catch (e) {
            evaluated.add(MathNoteLine(input: raw, error: 'Syntax error'));
            continue;
          }
        }
      }

      // 3. Standard expression evaluation e.g. "x * 5"
      try {
        final eval = MathExpressionEvaluator(variables: variables);
        final val = eval.evaluate(trimmed);
        if (!val.isNaN && !val.isInfinite) {
          evaluated.add(MathNoteLine(input: raw, result: _formatNum(val)));
        } else {
          evaluated.add(MathNoteLine(input: raw, error: 'Undefined'));
        }
      } catch (e) {
        evaluated.add(MathNoteLine(input: raw, error: 'Syntax error'));
      }
    }

    return evaluated;
  }

  static String _formatNum(double val) {
    if (val == val.roundToDouble() && val.abs() < 1e15) {
      return val.toInt().toString();
    }
    String str = val.toStringAsPrecision(8);
    if (str.contains('.')) {
      while (str.endsWith('0')) {
        str = str.substring(0, str.length - 1);
      }
      if (str.endsWith('.')) {
        str = str.substring(0, str.length - 1);
      }
    }
    return str;
  }
}

/// Widget for Typed Math Notes interface
class AcMathNotesView extends StatefulWidget {
  final AcCalculatorTheme theme;

  const AcMathNotesView({super.key, required this.theme});

  @override
  State<AcMathNotesView> createState() => _AcMathNotesViewState();
}

class _AcMathNotesViewState extends State<AcMathNotesView> {
  final TextEditingController _textController = TextEditingController();
  final MathNotesEngine _engine = MathNotesEngine();
  List<MathNoteLine> _evaluatedLines = [];

  final List<MathNoteDocument> _savedDocuments = [
    MathNoteDocument(
      id: '1',
      title: 'Welcome Note',
      rawLines: [
        '# Apple Math Notes Replica',
        'x = 10',
        'y = 25',
        'total = x + y',
        'total * 2',
        '50 m in ft',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadDocument(_savedDocuments.first);
    _textController.addListener(_onTextChanged);
  }

  void _loadDocument(MathNoteDocument doc) {
    _textController.text = doc.rawLines.join('\n');
    _recalculate();
  }

  void _onTextChanged() {
    _recalculate();
  }

  void _recalculate() {
    final lines = _textController.text.split('\n');
    setState(() {
      _evaluatedLines = _engine.evaluateLines(lines);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Container(
      color: theme.backgroundColor,
      padding: theme.panelPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toolbar: Notes List / New Note
          Row(
            children: [
              Text(
                'Math Notes',
                style: TextStyle(
                  color: theme.displayTextColor,
                  fontSize: theme.panelHeaderFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  final newDoc = MathNoteDocument(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: 'Note ${_savedDocuments.length + 1}',
                    rawLines: [''],
                  );
                  setState(() {
                    _savedDocuments.add(newDoc);
                    _loadDocument(newDoc);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.functionButtonColor,
                    borderRadius: BorderRadius.circular(theme.buttonRadius),
                  ),
                  child: Text(
                    '+ New Note',
                    style: TextStyle(
                      color: theme.functionButtonTextColor,
                      fontSize: theme.bodyFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Split view / Interactive note editing
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Input column
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.panelBackgroundColor,
                      borderRadius: BorderRadius.circular(theme.panelRadius),
                      border: Border.all(
                        color: theme.borderColor,
                        width: theme.borderThickness,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      style: TextStyle(
                        color: theme.panelTextColor,
                        fontSize: theme.bodyFontSize + 2,
                        fontFamily: 'monospace',
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText:
                            'Type expressions (e.g. x = 10, x * 2, 50 m in ft)',
                        hintStyle: TextStyle(color: theme.secondaryTextColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Live calculation results column
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.panelBackgroundColor,
                      borderRadius: BorderRadius.circular(theme.panelRadius),
                      border: Border.all(
                        color: theme.borderColor,
                        width: theme.borderThickness,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: ListView.builder(
                      itemCount: _evaluatedLines.length,
                      itemBuilder: (context, idx) {
                        final line = _evaluatedLines[idx];
                        final hasRes = line.result.isNotEmpty;
                        final hasErr = line.error != null;

                        return Container(
                          height:
                              24, // roughly single line height matching monospace
                          alignment: Alignment.centerLeft,
                          child: Text(
                            hasRes
                                ? '= ${line.result}'
                                : (hasErr ? '! ${line.error}' : ''),
                            style: TextStyle(
                              color:
                                  hasErr
                                      ? theme.errorColor
                                      : theme.equalsButtonColor,
                              fontSize: theme.bodyFontSize + 1,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
