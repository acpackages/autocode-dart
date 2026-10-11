import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'calculator_theme.dart';
import 'calculator_logic.dart';
import 'converter.dart';
import 'date_calculator.dart';
import 'graph_view.dart';
import 'math_notes_view.dart';

/// The primary feature-complete Windows and iPhone Calculator widget.
class AcCalculator extends StatefulWidget {
  final AcCalculatorTheme theme;
  final CalculatorMode initialMode;
  final bool enableHistory;
  final bool enableMemory;
  final bool enableCurrencyConverter;
  final void Function(String result)? onResultChanged;

  const AcCalculator({
    super.key,
    this.theme = const AcCalculatorTheme(
      backgroundColor: Color(0xFFF3F3F3),
      displayBackgroundColor: Color(0xFFF3F3F3),
      displayTextColor: Color(0xFF1F1F1F),
      secondaryTextColor: Color(0xFF606060),
      numberButtonColor: Color(0xFFFFFFFF),
      numberButtonTextColor: Color(0xFF1F1F1F),
      operatorButtonColor: Color(0xFFF9F9F9),
      operatorButtonTextColor: Color(0xFF1F1F1F),
      functionButtonColor: Color(0xFFF9F9F9),
      functionButtonTextColor: Color(0xFF1F1F1F),
      equalsButtonColor: Color(0xFF0067C0),
      equalsButtonTextColor: Color(0xFFFFFFFF),
      navBackgroundColor: Color(0xFFEBEBEB),
      navTextColor: Color(0xFF1F1F1F),
      panelBackgroundColor: Color(0xFFF8F8F8),
      panelTextColor: Color(0xFF1F1F1F),
      selectedItemColor: Color(0x200067C0),
      borderColor: Color(0xFFE5E5E5),
      dividerColor: Color(0xFFE0E0E0),
      errorColor: Color(0xFFC42B1C),
      graphBackgroundColor: Color(0xFFFFFFFF),
      graphGridColor: Color(0xFFEEEEEE),
      graphAxisColor: Color(0xFF888888),
      graphLineColors: [Color(0xFF0067C0)],
    ),
    this.initialMode = CalculatorMode.standard,
    this.enableHistory = true,
    this.enableMemory = true,
    this.enableCurrencyConverter = true,
    this.onResultChanged,
  });

  @override
  State<AcCalculator> createState() => _AcCalculatorState();
}

class _AcCalculatorState extends State<AcCalculator> {
  late CalculatorLogic _logic;
  final FocusNode _focusNode = FocusNode();

  // Desktop side panel: 0 = None, 1 = History, 2 = Memory
  int _activeSidePanel = 0;

  // Date Calculator State
  bool _dateDiffMode = true; // true = Diff between dates, false = Add/Subtract
  DateTime _dateFrom = DateTime.now();
  DateTime _dateTo = DateTime.now().add(const Duration(days: 30));
  int _dateAddYears = 0;
  int _dateAddMonths = 0;
  int _dateAddDays = 0;

  // Converter State
  UnitCategory _converterCategory = UnitCategory.length;
  late UnitDefinition _converterFromUnit;
  late UnitDefinition _converterToUnit;
  double _converterInputVal = 1.0;

  // Currency Converter State
  final CurrencyService _currencyService = CurrencyService();
  String _currFrom = 'USD';
  String _currTo = 'EUR';
  double _currAmount = 100.0;
  double _currResult = 0.0;
  bool _currLoading = false;
  String? _currError;

  // Graphing State
  final List<String> _graphEquations = ['x^2', 'sin(x)'];
  final TextEditingController _graphTextCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _logic = CalculatorLogic(mode: widget.initialMode);
    _initConverterUnits();
    _updateCurrency();
  }

  void _initConverterUnits() {
    final list = UnitConverter.units[_converterCategory] ?? [];
    if (list.length >= 2) {
      _converterFromUnit = list[0];
      _converterToUnit = list[1];
    } else if (list.isNotEmpty) {
      _converterFromUnit = list[0];
      _converterToUnit = list[0];
    }
  }

  Future<void> _updateCurrency() async {
    if (!widget.enableCurrencyConverter) return;
    setState(() {
      _currLoading = true;
      _currError = null;
    });
    try {
      final res = await _currencyService.convertCurrency(
        from: _currFrom,
        to: _currTo,
        amount: _currAmount,
      );
      setState(() {
        _currResult = res;
        _currLoading = false;
      });
    } catch (e) {
      setState(() {
        _currError = e.toString();
        _currLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _graphTextCtrl.dispose();
    super.dispose();
  }

  void _onKeyPress(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final char = event.character;

    if (char != null && '0123456789'.contains(char)) {
      setState(() => _logic.inputDigit(char));
      return;
    }
    if (char == '.') {
      setState(() => _logic.inputDecimal());
      return;
    }
    if (char == '+' || char == '-') {
      setState(() => _logic.setOperator(char!));
      return;
    }
    if (char == '*' || char == 'x') {
      setState(() => _logic.setOperator('×'));
      return;
    }
    if (char == '/') {
      setState(() => _logic.setOperator('÷'));
      return;
    }
    if (char == '%') {
      setState(() => _logic.inputPercentage());
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter ||
        char == '=') {
      setState(() => _logic.calculateEquals());
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      setState(() => _logic.backspace());
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      setState(() => _logic.clearAll());
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _onKeyPress,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 650;
          return Container(
            color: theme.backgroundColor,
            child: Column(
              children: [
                // Navigation Header / Mode Switcher
                _buildNavigationBar(theme, isWide),
                // Main Content Body
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildModeContent(theme, isWide)),
                      // Responsive Desktop Side Panel for History & Memory
                      if (isWide &&
                          _activeSidePanel > 0 &&
                          (_logic.mode == CalculatorMode.standard ||
                              _logic.mode == CalculatorMode.scientific ||
                              _logic.mode == CalculatorMode.programmer))
                        _buildSidePanel(theme),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Top Navigation / Mode Selector ---
  Widget _buildNavigationBar(AcCalculatorTheme theme, bool isWide) {
    return Container(
      color: theme.navBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        children: [
          PopupMenuButton<CalculatorMode>(
            tooltip: 'Select Mode',
            initialValue: _logic.mode,
            onSelected: (mode) {
              setState(() {
                _logic.mode = mode;
                if (mode == CalculatorMode.converter) {
                  _initConverterUnits();
                }
              });
            },
            itemBuilder:
                (context) => [
                  _modeMenuItem(CalculatorMode.standard, 'Standard'),
                  _modeMenuItem(CalculatorMode.scientific, 'Scientific'),
                  _modeMenuItem(CalculatorMode.programmer, 'Programmer'),
                  _modeMenuItem(CalculatorMode.graphing, 'Graphing'),
                  _modeMenuItem(CalculatorMode.date, 'Date Calculation'),
                  _modeMenuItem(CalculatorMode.converter, 'Unit & Currency'),
                  _modeMenuItem(CalculatorMode.mathNotes, 'Math Notes'),
                ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu, color: theme.navTextColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  _modeTitle(_logic.mode),
                  style: TextStyle(
                    color: theme.navTextColor,
                    fontSize: theme.navFontSize + 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  color: theme.navTextColor,
                  size: 18,
                ),
              ],
            ),
          ),
          const Spacer(),
          // Angle switch for scientific
          if (_logic.mode == CalculatorMode.scientific) ...[
            GestureDetector(
              onTap: () {
                setState(() {
                  _logic.angleMode =
                      _logic.angleMode == AngleMode.degree
                          ? AngleMode.radian
                          : AngleMode.degree;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.functionButtonColor,
                  borderRadius: BorderRadius.circular(theme.buttonRadius),
                ),
                child: Text(
                  _logic.angleMode == AngleMode.degree ? 'DEG' : 'RAD',
                  style: TextStyle(
                    color: theme.functionButtonTextColor,
                    fontSize: theme.navFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          // History & Memory toggles
          if (widget.enableHistory &&
              (_logic.mode == CalculatorMode.standard ||
                  _logic.mode == CalculatorMode.scientific ||
                  _logic.mode == CalculatorMode.programmer)) ...[
            IconButton(
              icon: Icon(Icons.history, color: theme.navTextColor, size: 20),
              tooltip: 'History',
              onPressed: () {
                setState(() {
                  _activeSidePanel = _activeSidePanel == 1 ? 0 : 1;
                });
              },
            ),
          ],
          if (widget.enableMemory &&
              (_logic.mode == CalculatorMode.standard ||
                  _logic.mode == CalculatorMode.scientific)) ...[
            IconButton(
              icon: Icon(Icons.memory, color: theme.navTextColor, size: 20),
              tooltip: 'Memory',
              onPressed: () {
                setState(() {
                  _activeSidePanel = _activeSidePanel == 2 ? 0 : 2;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  PopupMenuItem<CalculatorMode> _modeMenuItem(
    CalculatorMode mode,
    String label,
  ) {
    return PopupMenuItem(value: mode, child: Text(label));
  }

  String _modeTitle(CalculatorMode mode) {
    return switch (mode) {
      CalculatorMode.standard => 'Standard',
      CalculatorMode.scientific => 'Scientific',
      CalculatorMode.programmer => 'Programmer',
      CalculatorMode.graphing => 'Graphing',
      CalculatorMode.date => 'Date Calculation',
      CalculatorMode.converter => 'Converter',
      CalculatorMode.mathNotes => 'Math Notes',
    };
  }

  // --- Content Selector By Mode ---
  Widget _buildModeContent(AcCalculatorTheme theme, bool isWide) {
    return switch (_logic.mode) {
      CalculatorMode.standard => _buildKeypadCalculator(
        theme,
        isWide,
        isScientific: false,
      ),
      CalculatorMode.scientific => _buildKeypadCalculator(
        theme,
        isWide,
        isScientific: true,
      ),
      CalculatorMode.programmer => _buildProgrammerView(theme, isWide),
      CalculatorMode.graphing => _buildGraphingView(theme),
      CalculatorMode.date => _buildDateCalculatorView(theme),
      CalculatorMode.converter => _buildConverterView(theme),
      CalculatorMode.mathNotes => AcMathNotesView(theme: theme),
    };
  }

  // --- Standard & Scientific Keypad Views ---
  Widget _buildKeypadCalculator(
    AcCalculatorTheme theme,
    bool isWide, {
    required bool isScientific,
  }) {
    return Column(
      children: [
        // Display area
        _buildDisplayArea(theme),
        // Memory Quick Bar (MC, MR, M+, M-, MS)
        if (widget.enableMemory) _buildMemoryBar(theme),
        // Keypad grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child:
                isScientific
                    ? _buildScientificGrid(theme)
                    : _buildStandardGrid(theme),
          ),
        ),
      ],
    );
  }

  // --- Top Display Area ---
  Widget _buildDisplayArea(AcCalculatorTheme theme) {
    return Container(
      color: theme.displayBackgroundColor,
      padding: theme.displayPadding,
      alignment: Alignment.bottomRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Previous expression preview
          Text(
            _logic.expressionPreview,
            style: TextStyle(
              color: theme.secondaryTextColor,
              fontSize: theme.secondaryDisplayFontSize,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Primary number / error text
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: SelectableText(
              _logic.display,
              style: TextStyle(
                color:
                    _logic.hasError ? theme.errorColor : theme.displayTextColor,
                fontSize: theme.displayFontSize,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  // --- Memory Quick Action Bar ---
  Widget _buildMemoryBar(AcCalculatorTheme theme) {
    final hasMem = _logic.memoryList.isNotEmpty;
    final textStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.bold);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _memButton(
            'MC',
            theme,
            hasMem ? () => setState(() => _logic.memoryClear()) : null,
            textStyle,
          ),
          _memButton(
            'MR',
            theme,
            hasMem ? () => setState(() => _logic.memoryRecall()) : null,
            textStyle,
          ),
          _memButton(
            'M+',
            theme,
            () => setState(() => _logic.memoryAdd()),
            textStyle,
          ),
          _memButton(
            'M-',
            theme,
            () => setState(() => _logic.memorySubtract()),
            textStyle,
          ),
          _memButton(
            'MS',
            theme,
            () => setState(() => _logic.memoryStore()),
            textStyle,
          ),
        ],
      ),
    );
  }

  Widget _memButton(
    String text,
    AcCalculatorTheme theme,
    VoidCallback? onPressed,
    TextStyle style,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor:
                onPressed != null
                    ? theme.displayTextColor
                    : theme.secondaryTextColor.withAlpha(100),
            padding: const EdgeInsets.symmetric(vertical: 4),
          ),
          child: Text(text, style: style),
        ),
      ),
    );
  }

  // --- Standard Keypad Layout ---
  Widget _buildStandardGrid(AcCalculatorTheme theme) {
    final rows = [
      ['%', 'CE', 'C', '⌫'],
      ['1/x', 'x²', '√x', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['±', '0', '.', '='],
    ];

    return Column(
      children:
          rows.map((row) {
            return Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children:
                    row.map((label) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(theme.spacing / 2),
                          child: _buildCalculatorButton(label, theme),
                        ),
                      );
                    }).toList(),
              ),
            );
          }).toList(),
    );
  }

  // --- Scientific Keypad Layout ---
  Widget _buildScientificGrid(AcCalculatorTheme theme) {
    final rows = [
      ['(', ')', '1/x', 'n!', 'CE', 'C', '⌫'],
      ['sin', 'cos', 'tan', 'x²', 'x³', 'x^y', '÷'],
      ['asin', 'acos', 'atan', '√x', '∛x', 'yroot', '×'],
      ['sinh', 'cosh', 'tanh', '7', '8', '9', '-'],
      ['ln', 'log', '10^x', '4', '5', '6', '+'],
      ['π', 'e', '|x|', '1', '2', '3', '='],
      ['rand', 'mod', '2^x', '±', '0', '.', '='],
    ];

    return Column(
      children:
          rows.map((row) {
            return Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children:
                    row.map((label) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(theme.spacing / 2),
                          child: _buildCalculatorButton(label, theme),
                        ),
                      );
                    }).toList(),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildCalculatorButton(String label, AcCalculatorTheme theme) {
    Color bg;
    Color fg;

    final isEquals = label == '=';
    final isDigit = '0123456789.'.contains(label);
    final isOp = ['+', '-', '×', '÷', 'x^y', 'yroot', 'mod'].contains(label);

    if (isEquals) {
      bg = theme.equalsButtonColor;
      fg = theme.equalsButtonTextColor;
    } else if (isDigit) {
      bg = theme.numberButtonColor;
      fg = theme.numberButtonTextColor;
    } else if (isOp) {
      bg = theme.operatorButtonColor;
      fg = theme.operatorButtonTextColor;
    } else {
      bg = theme.functionButtonColor;
      fg = theme.functionButtonTextColor;
    }

    return GestureDetector(
      onTap: () => _handleButtonTap(label),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(theme.buttonRadius),
          border: Border.all(
            color: theme.borderColor,
            width: theme.borderThickness,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: theme.buttonFontSize,
            fontWeight: isDigit || isEquals ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _handleButtonTap(String label) {
    setState(() {
      if ('0123456789'.contains(label)) {
        _logic.inputDigit(label);
      } else if (label == '.') {
        _logic.inputDecimal();
      } else if (label == '±') {
        _logic.toggleSign();
      } else if (label == '%') {
        _logic.inputPercentage();
      } else if (label == 'CE') {
        _logic.clearEntry();
      } else if (label == 'C') {
        _logic.clearAll();
      } else if (label == '⌫') {
        _logic.backspace();
      } else if (label == '=') {
        _logic.calculateEquals();
        widget.onResultChanged?.call(_logic.display);
      } else if (['+', '-', '×', '÷', 'x^y', 'yroot', 'mod'].contains(label)) {
        _logic.setOperator(label);
      } else {
        // Unary function
        _logic.applyUnary(label);
        widget.onResultChanged?.call(_logic.display);
      }
    });
  }

  // --- Programmer Mode View ---
  Widget _buildProgrammerView(AcCalculatorTheme theme, bool isWide) {
    return Column(
      children: [
        // Display area
        _buildDisplayArea(theme),
        // Hex / Dec / Oct / Bin Representations
        Container(
          color: theme.panelBackgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children:
                ProgrammerBase.values.map((base) {
                  final isSelected = _logic.programmerBase == base;
                  final valStr = _logic.formatProgrammerValue(
                    _logic.programmerValue,
                    base,
                  );
                  return GestureDetector(
                    onTap: () => setState(() => _logic.programmerBase = base),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 45,
                            child: Text(
                              base.label,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? theme.equalsButtonColor
                                        : theme.secondaryTextColor,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              valStr,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? theme.displayTextColor
                                        : theme.panelTextColor,
                                fontFamily: 'monospace',
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
        // Word Size Picker (QWORD, DWORD, WORD, BYTE)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children:
                ProgrammerWordSize.values.map((ws) {
                  final isSel = _logic.wordSize == ws;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(ws.label),
                      selected: isSel,
                      onSelected: (_) => setState(() => _logic.wordSize = ws),
                    ),
                  );
                }).toList(),
          ),
        ),
        // Programmer Keypad
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: _buildProgrammerGrid(theme),
          ),
        ),
      ],
    );
  }

  Widget _buildProgrammerGrid(AcCalculatorTheme theme) {
    final rows = [
      ['AND', 'OR', 'XOR', 'NOT', 'CE', 'C', '⌫'],
      ['LSH', 'RSH', 'MOD', '÷', 'D', 'E', 'F'],
      ['+', '-', '×', '÷', 'A', 'B', 'C'],
      ['7', '8', '9', '4', '5', '6', '='],
      ['1', '2', '3', '±', '0', '=', '='],
    ];

    return Column(
      children:
          rows.map((row) {
            return Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children:
                    row.map((label) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(theme.spacing / 2),
                          child: _buildProgrammerButton(label, theme),
                        ),
                      );
                    }).toList(),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildProgrammerButton(String label, AcCalculatorTheme theme) {
    // Check if button is enabled for current base
    bool enabled = true;
    if ('ABCDEF'.contains(label) &&
        _logic.programmerBase != ProgrammerBase.hex) {
      enabled = false;
    }
    if ('89'.contains(label) &&
        (_logic.programmerBase == ProgrammerBase.oct ||
            _logic.programmerBase == ProgrammerBase.bin)) {
      enabled = false;
    }
    if ('234567'.contains(label) &&
        _logic.programmerBase == ProgrammerBase.bin) {
      enabled = false;
    }

    Color bg =
        '0123456789ABCDEF'.contains(label)
            ? theme.numberButtonColor
            : (label == '='
                ? theme.equalsButtonColor
                : theme.functionButtonColor);
    Color fg =
        '0123456789ABCDEF'.contains(label)
            ? theme.numberButtonTextColor
            : (label == '='
                ? theme.equalsButtonTextColor
                : theme.functionButtonTextColor);

    if (!enabled) {
      bg = theme.backgroundColor;
      fg = theme.secondaryTextColor.withAlpha(50);
    }

    return GestureDetector(
      onTap:
          enabled
              ? () {
                setState(() {
                  if ('0123456789ABCDEF'.contains(label)) {
                    _logic.inputDigit(label);
                  } else if (label == 'NOT') {
                    _logic.programmerNot();
                  } else if ([
                    'AND',
                    'OR',
                    'XOR',
                    'LSH',
                    'RSH',
                    'MOD',
                    '+',
                    '-',
                    '×',
                    '÷',
                  ].contains(label)) {
                    _logic.setOperator(label);
                  } else if (label == '=') {
                    _logic.calculateEquals();
                  } else if (label == 'CE') {
                    _logic.clearEntry();
                  } else if (label == 'C') {
                    _logic.clearAll();
                  } else if (label == '⌫') {
                    _logic.backspace();
                  } else if (label == '±') {
                    _logic.toggleSign();
                  }
                });
              }
              : null,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(theme.buttonRadius),
          border: Border.all(
            color: theme.borderColor,
            width: theme.borderThickness,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: theme.buttonFontSize - 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- Graphing View ---
  Widget _buildGraphingView(AcCalculatorTheme theme) {
    return Column(
      children: [
        // Equation Manager
        Container(
          color: theme.panelBackgroundColor,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _graphTextCtrl,
                      style: TextStyle(color: theme.panelTextColor),
                      decoration: InputDecoration(
                        hintText: 'Enter equation (e.g. y = x^2, sin(x))',
                        hintStyle: TextStyle(color: theme.secondaryTextColor),
                        filled: true,
                        fillColor: theme.backgroundColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            theme.buttonRadius,
                          ),
                        ),
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          setState(() {
                            _graphEquations.add(val.trim());
                            _graphTextCtrl.clear();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final val = _graphTextCtrl.text.trim();
                      if (val.isNotEmpty) {
                        setState(() {
                          _graphEquations.add(val);
                          _graphTextCtrl.clear();
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.equalsButtonColor,
                      foregroundColor: theme.equalsButtonTextColor,
                    ),
                    child: const Text('Add Plot'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children:
                    _graphEquations.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final eq = entry.value;
                      final color =
                          theme.graphLineColors[idx %
                              theme.graphLineColors.length];
                      return Chip(
                        avatar: CircleAvatar(backgroundColor: color, radius: 5),
                        label: Text(
                          eq,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.panelTextColor,
                          ),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () {
                          setState(() => _graphEquations.removeAt(idx));
                        },
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
        // Interactive Graph Canvas
        Expanded(
          child: AcGraphView(expressions: _graphEquations, theme: theme),
        ),
      ],
    );
  }

  // --- Date Calculator View ---
  Widget _buildDateCalculatorView(AcCalculatorTheme theme) {
    final diffResult = DateCalculator.difference(_dateFrom, _dateTo);
    final addDateResult =
        _dateDiffMode
            ? DateTime.now()
            : DateCalculator.addDuration(
              _dateFrom,
              years: _dateAddYears,
              months: _dateAddMonths,
              days: _dateAddDays,
            );

    return SingleChildScrollView(
      padding: theme.panelPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ChoiceChip(
                label: const Text('Difference between dates'),
                selected: _dateDiffMode,
                onSelected: (val) => setState(() => _dateDiffMode = true),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Add or subtract days'),
                selected: !_dateDiffMode,
                onSelected: (val) => setState(() => _dateDiffMode = false),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_dateDiffMode) ...[
            Text(
              'From:',
              style: TextStyle(
                color: theme.displayTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            _dateSelectorTile(
              theme,
              _dateFrom,
              (d) => setState(() => _dateFrom = d),
            ),
            const SizedBox(height: 12),
            Text(
              'To:',
              style: TextStyle(
                color: theme.displayTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            _dateSelectorTile(
              theme,
              _dateTo,
              (d) => setState(() => _dateTo = d),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.panelBackgroundColor,
                borderRadius: BorderRadius.circular(theme.panelRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Difference',
                    style: TextStyle(color: theme.secondaryTextColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    diffResult.summary,
                    style: TextStyle(
                      color: theme.displayTextColor,
                      fontSize: theme.displayFontSize - 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${diffResult.totalDays} total days',
                    style: TextStyle(color: theme.secondaryTextColor),
                  ),
                ],
              ),
            ),
          ] else ...[
            Text(
              'Start Date:',
              style: TextStyle(
                color: theme.displayTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            _dateSelectorTile(
              theme,
              _dateFrom,
              (d) => setState(() => _dateFrom = d),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _durationInput(
                  'Years',
                  _dateAddYears,
                  (v) => setState(() => _dateAddYears = v),
                ),
                const SizedBox(width: 8),
                _durationInput(
                  'Months',
                  _dateAddMonths,
                  (v) => setState(() => _dateAddMonths = v),
                ),
                const SizedBox(width: 8),
                _durationInput(
                  'Days',
                  _dateAddDays,
                  (v) => setState(() => _dateAddDays = v),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.panelBackgroundColor,
                borderRadius: BorderRadius.circular(theme.panelRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Result Date',
                    style: TextStyle(color: theme.secondaryTextColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${addDateResult.year}-${addDateResult.month.toString().padLeft(2, '0')}-${addDateResult.day.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: theme.displayTextColor,
                      fontSize: theme.displayFontSize - 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dateSelectorTile(
    AcCalculatorTheme theme,
    DateTime dt,
    ValueChanged<DateTime> onSelect,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: dt,
          firstDate: DateTime(1600),
          lastDate: DateTime(3000),
        );
        if (picked != null) onSelect(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: theme.panelBackgroundColor,
          border: Border.all(color: theme.borderColor),
          borderRadius: BorderRadius.circular(theme.buttonRadius),
        ),
        child: Text(
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}',
          style: TextStyle(color: theme.panelTextColor, fontSize: 16),
        ),
      ),
    );
  }

  Widget _durationInput(String label, int val, ValueChanged<int> onChanged) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          TextField(
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: val.toString()),
            onChanged: (s) => onChanged(int.tryParse(s) ?? 0),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }

  // --- Unit & Currency Converter View ---
  Widget _buildConverterView(AcCalculatorTheme theme) {
    return SingleChildScrollView(
      padding: theme.panelPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Category Selector
          DropdownButton<UnitCategory>(
            value: _converterCategory,
            isExpanded: true,
            dropdownColor: theme.panelBackgroundColor,
            items:
                UnitCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(
                      cat.label,
                      style: TextStyle(color: theme.displayTextColor),
                    ),
                  );
                }).toList(),
            onChanged: (cat) {
              if (cat == null) return;
              setState(() {
                _converterCategory = cat;
                _initConverterUnits();
              });
            },
          ),
          const SizedBox(height: 16),
          if (_converterCategory == UnitCategory.currency) ...[
            // Currency Interface
            _buildCurrencySubView(theme),
          ] else ...[
            // Unit Interface
            _buildUnitSubView(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildUnitSubView(AcCalculatorTheme theme) {
    final list = UnitConverter.units[_converterCategory] ?? [];
    final convertedVal = UnitConverter.convert(
      category: _converterCategory,
      from: _converterFromUnit,
      to: _converterToUnit,
      value: _converterInputVal,
    );

    return Column(
      children: [
        // From Unit
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                  text: _converterInputVal.toString(),
                ),
                style: TextStyle(color: theme.displayTextColor, fontSize: 22),
                onChanged:
                    (val) => setState(
                      () => _converterInputVal = double.tryParse(val) ?? 0.0,
                    ),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: DropdownButton<UnitDefinition>(
                value: _converterFromUnit,
                isExpanded: true,
                dropdownColor: theme.panelBackgroundColor,
                items:
                    list.map((u) {
                      return DropdownMenuItem(
                        value: u,
                        child: Text(
                          '${u.name} (${u.symbol})',
                          style: TextStyle(color: theme.displayTextColor),
                        ),
                      );
                    }).toList(),
                onChanged: (u) => setState(() => _converterFromUnit = u!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Swap Button
        IconButton(
          icon: Icon(Icons.swap_vert, color: theme.displayTextColor, size: 28),
          onPressed: () {
            setState(() {
              final tmp = _converterFromUnit;
              _converterFromUnit = _converterToUnit;
              _converterToUnit = tmp;
            });
          },
        ),
        const SizedBox(height: 16),
        // To Unit
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.panelBackgroundColor,
                  borderRadius: BorderRadius.circular(theme.buttonRadius),
                  border: Border.all(color: theme.borderColor),
                ),
                child: SelectableText(
                  _formatConverted(convertedVal),
                  style: TextStyle(
                    color: theme.displayTextColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: DropdownButton<UnitDefinition>(
                value: _converterToUnit,
                isExpanded: true,
                dropdownColor: theme.panelBackgroundColor,
                items:
                    list.map((u) {
                      return DropdownMenuItem(
                        value: u,
                        child: Text(
                          '${u.name} (${u.symbol})',
                          style: TextStyle(color: theme.displayTextColor),
                        ),
                      );
                    }).toList(),
                onChanged: (u) => setState(() => _converterToUnit = u!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrencySubView(AcCalculatorTheme theme) {
    const currencies = [
      'USD',
      'EUR',
      'GBP',
      'JPY',
      'CAD',
      'AUD',
      'CHF',
      'CNY',
      'INR',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: _currAmount.toString()),
                style: TextStyle(color: theme.displayTextColor, fontSize: 22),
                onChanged: (val) {
                  _currAmount = double.tryParse(val) ?? 0.0;
                  _updateCurrency();
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: DropdownButton<String>(
                value: _currFrom,
                isExpanded: true,
                dropdownColor: theme.panelBackgroundColor,
                items:
                    currencies
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(
                              c,
                              style: TextStyle(color: theme.displayTextColor),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (c) {
                  if (c == null) return;
                  setState(() => _currFrom = c);
                  _updateCurrency();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        IconButton(
          icon: Icon(Icons.swap_vert, color: theme.displayTextColor, size: 28),
          onPressed: () {
            setState(() {
              final tmp = _currFrom;
              _currFrom = _currTo;
              _currTo = tmp;
            });
            _updateCurrency();
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.panelBackgroundColor,
                  borderRadius: BorderRadius.circular(theme.buttonRadius),
                  border: Border.all(color: theme.borderColor),
                ),
                child:
                    _currLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : SelectableText(
                          _currError != null
                              ? 'Error'
                              : _formatConverted(_currResult),
                          style: TextStyle(
                            color:
                                _currError != null
                                    ? theme.errorColor
                                    : theme.displayTextColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: DropdownButton<String>(
                value: _currTo,
                isExpanded: true,
                dropdownColor: theme.panelBackgroundColor,
                items:
                    currencies
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(
                              c,
                              style: TextStyle(color: theme.displayTextColor),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (c) {
                  if (c == null) return;
                  setState(() => _currTo = c);
                  _updateCurrency();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              _currencyService.isOfflineRate
                  ? 'Rates: Cached/Offline'
                  : 'Rates: Live (Frankfurter / ECB)',
              style: TextStyle(color: theme.secondaryTextColor, fontSize: 12),
            ),
            const Spacer(),
            TextButton.icon(
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh'),
              onPressed: _updateCurrency,
            ),
          ],
        ),
      ],
    );
  }

  String _formatConverted(double val) {
    if (val == val.roundToDouble() && val.abs() < 1e15) {
      return val.toInt().toString();
    }
    String str = val.toStringAsPrecision(6);
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

  // --- Desktop Side Panel (History / Memory) ---
  Widget _buildSidePanel(AcCalculatorTheme theme) {
    final isHist = _activeSidePanel == 1;

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: theme.panelBackgroundColor,
        border: Border(
          left: BorderSide(
            color: theme.borderColor,
            width: theme.borderThickness,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Text(
                  isHist ? 'History' : 'Memory',
                  style: TextStyle(
                    color: theme.panelTextColor,
                    fontSize: theme.panelHeaderFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  tooltip: isHist ? 'Clear History' : 'Clear Memory',
                  onPressed: () {
                    setState(() {
                      if (isHist) {
                        _logic.clearHistory();
                      } else {
                        _logic.memoryClear();
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => setState(() => _activeSidePanel = 0),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // List Items
          Expanded(
            child: isHist ? _buildHistoryList(theme) : _buildMemoryList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(AcCalculatorTheme theme) {
    if (_logic.history.isEmpty) {
      return Center(
        child: Text(
          "There's no history yet",
          style: TextStyle(color: theme.secondaryTextColor),
        ),
      );
    }
    return ListView.builder(
      itemCount: _logic.history.length,
      itemBuilder: (context, idx) {
        final item = _logic.history[idx];
        return ListTile(
          title: Text(
            item.expression,
            style: TextStyle(color: theme.secondaryTextColor, fontSize: 13),
          ),
          subtitle: Text(
            item.result,
            style: TextStyle(
              color: theme.panelTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () => setState(() => _logic.restoreHistory(item)),
          trailing: IconButton(
            icon: const Icon(Icons.delete_forever, size: 16),
            onPressed: () => setState(() => _logic.removeHistoryAt(idx)),
          ),
        );
      },
    );
  }

  Widget _buildMemoryList(AcCalculatorTheme theme) {
    if (_logic.memoryList.isEmpty) {
      return Center(
        child: Text(
          "There's nothing saved in memory",
          style: TextStyle(color: theme.secondaryTextColor),
        ),
      );
    }
    return ListView.builder(
      itemCount: _logic.memoryList.length,
      itemBuilder: (context, idx) {
        final val = _logic.memoryList[idx];
        return ListTile(
          title: Text(
            val.toString(),
            style: TextStyle(
              color: theme.panelTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.arrow_upward, size: 16),
            tooltip: 'Recall',
            onPressed: () {
              setState(() {
                _logic.clearEntry();
                _logic.inputDigit(val.toString());
              });
            },
          ),
        );
      },
    );
  }
}
