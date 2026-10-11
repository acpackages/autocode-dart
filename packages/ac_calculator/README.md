# ac_calculator

A feature-complete, lightweight, and reusable Flutter calculator package replicating the behavior and experience of Microsoft Windows Calculator and Apple iPhone Calculator.

## Features

- **Standard Calculator**: Arithmetic (`+`, `-`, `×`, `÷`), context-sensitive percentages (`200 + 10% = 220`), repeated equals (`1 + 2 = = =`), sign toggle (`±`), `CE`, `C`, backspace (`⌫`), reciprocals (`1/x`), powers, roots.
- **Scientific Calculator**: Angle modes (`DEG`, `RAD`), trigonometry (`sin`, `cos`, `tan`), inverse and hyperbolic functions (`sinh`, `cosh`, `tanh`, `asinh`, etc.), logarithms (`ln`, `log10`, `log2`), exponential (`e^x`, `10^x`, `2^x`), factorials (`n!`), absolute value (`|x|`), constants (`π`, `e`).
- **Programmer Calculator**: Full support for `HEX`, `DEC`, `OCT`, and `BIN` number bases with simultaneous representations, bit toggling, word-size masking (`QWORD` 64-bit, `DWORD` 32-bit, `WORD` 16-bit, `BYTE` 8-bit), bitwise operations (`AND`, `OR`, `XOR`, `NOT`, `LSH`, `RSH`).
- **Graphing Calculator**: Interactive 2D math plotting canvas with pan and zoom gesture support, grid lines, Cartesian axes, equation manager, and multi-equation plotting.
- **Date Calculator**: Date differences (years, months, days, total days) and duration addition/subtraction with full leap-year and calendar month-boundary handling.
- **Unit & Currency Converter**:
  - Offline local conversions across 12 categories: Length, Volume, Weight & Mass, Temperature (with offset conversion), Energy, Area, Speed, Time, Power, Data Storage (decimal & binary), Pressure, and Angle.
  - Live Currency Converter powered by Frankfurter API (European Central Bank reference rates) with offline caching and manual refresh.
- **Math Notes**: Apple Math Notes-style typed math interface supporting inline equations, variable assignment and dependency evaluation (`x = 10`, `x * 5`), unit conversions in prose (`50 m in ft`), and note management.
- **Memory & History**: Memory operations (`MC`, `MR`, `M+`, `M-`, `MS`) and interactive calculation history with recall, item deletion, and clear all.
- **Centralized Theme**: Single `AcCalculatorTheme` class controlling all colors, typography, dimensions, and borders across all modes, with presets for Windows (Light/Dark) and iPhone (Light/Dark).
- **Desktop & Mobile Responsive**: Adapts seamlessly to mobile touch screens and desktop widescreen layouts with collapsible sidebars.
- **Keyboard & Clipboard Support**: Full hardware keyboard navigation and clipboard copy/paste.

## Getting Started

Add `ac_calculator` to your `pubspec.yaml`:

```yaml
dependencies:
  ac_calculator:
    path: path/to/ac_calculator
```

Import the package:

```dart
import 'package:ac_calculator/ac_calculator.dart';
```

## Basic Usage

Embed `AcCalculator` into your Flutter widget tree:

```dart
import 'package:flutter/material.dart';
import 'package:ac_calculator/ac_calculator.dart';

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 500,
          height: 700,
          child: AcCalculator(
            theme: AcCalculatorTheme.windowsDark(),
            initialMode: CalculatorMode.standard,
            enableHistory: true,
            enableMemory: true,
            enableCurrencyConverter: true,
            onResultChanged: (result) {
              print('Result: $result');
            },
          ),
        ),
      ),
    );
  }
}
```

## Themes & Customization

The appearance is centrally driven by `AcCalculatorTheme`. Ready-to-use presets include:
- `AcCalculatorTheme.windowsLight()`
- `AcCalculatorTheme.windowsDark()`
- `AcCalculatorTheme.iphoneLight()`
- `AcCalculatorTheme.iphoneDark()`

You can customize individual attributes using `copyWith`:

```dart
final customTheme = AcCalculatorTheme.windowsDark().copyWith(
  equalsButtonColor: Colors.amber,
  displayFontSize: 42.0,
  buttonRadius: 8.0,
);
```

## Currency API

The live currency conversion utilizes the [Frankfurter API](https://api.frankfurter.dev/), an open and free API tracking European Central Bank (ECB) reference rates without requiring an API key. Rates are cached in-memory with offline fallback support for interrupted connectivity.
