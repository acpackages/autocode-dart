import 'dart:convert';
import 'package:http/http.dart' as http;

/// Categories for conversion
enum UnitCategory {
  volume('Volume'),
  length('Length'),
  weight('Weight and Mass'),
  temperature('Temperature'),
  energy('Energy'),
  area('Area'),
  speed('Speed'),
  time('Time'),
  power('Power'),
  dataStorage('Data Storage'),
  pressure('Pressure'),
  angle('Angle'),
  currency('Currency');

  final String label;
  const UnitCategory(this.label);
}

/// A unit item with name, symbol, and ratio to a base unit
class UnitDefinition {
  final String id;
  final String name;
  final String symbol;
  final double toBase; // Factor to multiply by to convert to category base unit

  const UnitDefinition({
    required this.id,
    required this.name,
    required this.symbol,
    required this.toBase,
  });
}

/// Unit & Currency Converter Engine
class UnitConverter {
  static final Map<UnitCategory, List<UnitDefinition>> units = {
    UnitCategory.length: const [
      UnitDefinition(id: 'nm', name: 'Nanometers', symbol: 'nm', toBase: 1e-9),
      UnitDefinition(id: 'um', name: 'Microns', symbol: 'µm', toBase: 1e-6),
      UnitDefinition(
        id: 'mm',
        name: 'Millimeters',
        symbol: 'mm',
        toBase: 0.001,
      ),
      UnitDefinition(id: 'cm', name: 'Centimeters', symbol: 'cm', toBase: 0.01),
      UnitDefinition(id: 'm', name: 'Meters', symbol: 'm', toBase: 1.0),
      UnitDefinition(
        id: 'km',
        name: 'Kilometers',
        symbol: 'km',
        toBase: 1000.0,
      ),
      UnitDefinition(id: 'in', name: 'Inches', symbol: 'in', toBase: 0.0254),
      UnitDefinition(id: 'ft', name: 'Feet', symbol: 'ft', toBase: 0.3048),
      UnitDefinition(id: 'yd', name: 'Yards', symbol: 'yd', toBase: 0.9144),
      UnitDefinition(id: 'mi', name: 'Miles', symbol: 'mi', toBase: 1609.344),
      UnitDefinition(
        id: 'nmi',
        name: 'Nautical miles',
        symbol: 'NM',
        toBase: 1852.0,
      ),
    ],
    UnitCategory.volume: const [
      UnitDefinition(
        id: 'ml',
        name: 'Milliliters',
        symbol: 'mL',
        toBase: 0.001,
      ),
      UnitDefinition(
        id: 'cm3',
        name: 'Cubic centimeters',
        symbol: 'cm³',
        toBase: 0.001,
      ),
      UnitDefinition(id: 'l', name: 'Liters', symbol: 'L', toBase: 1.0),
      UnitDefinition(
        id: 'm3',
        name: 'Cubic meters',
        symbol: 'm³',
        toBase: 1000.0,
      ),
      UnitDefinition(
        id: 'tsp',
        name: 'Teaspoons (US)',
        symbol: 'tsp',
        toBase: 0.00492892,
      ),
      UnitDefinition(
        id: 'tbsp',
        name: 'Tablespoons (US)',
        symbol: 'tbsp',
        toBase: 0.0147868,
      ),
      UnitDefinition(
        id: 'fl_oz',
        name: 'Fluid ounces (US)',
        symbol: 'fl oz',
        toBase: 0.0295735,
      ),
      UnitDefinition(
        id: 'cup',
        name: 'Cups (US)',
        symbol: 'cup',
        toBase: 0.236588,
      ),
      UnitDefinition(
        id: 'pt',
        name: 'Pints (US)',
        symbol: 'pt',
        toBase: 0.473176,
      ),
      UnitDefinition(
        id: 'qt',
        name: 'Quarts (US)',
        symbol: 'qt',
        toBase: 0.946353,
      ),
      UnitDefinition(
        id: 'gal',
        name: 'Gallons (US)',
        symbol: 'gal',
        toBase: 3.78541,
      ),
    ],
    UnitCategory.weight: const [
      UnitDefinition(id: 'mg', name: 'Milligrams', symbol: 'mg', toBase: 1e-6),
      UnitDefinition(id: 'g', name: 'Grams', symbol: 'g', toBase: 0.001),
      UnitDefinition(id: 'kg', name: 'Kilograms', symbol: 'kg', toBase: 1.0),
      UnitDefinition(id: 't', name: 'Metric tons', symbol: 't', toBase: 1000.0),
      UnitDefinition(
        id: 'oz',
        name: 'Ounces',
        symbol: 'oz',
        toBase: 0.02834952,
      ),
      UnitDefinition(
        id: 'lb',
        name: 'Pounds',
        symbol: 'lb',
        toBase: 0.45359237,
      ),
      UnitDefinition(id: 'st', name: 'Stones', symbol: 'st', toBase: 6.350293),
      UnitDefinition(
        id: 'ton',
        name: 'Short tons (US)',
        symbol: 'ton',
        toBase: 907.18474,
      ),
    ],
    UnitCategory.temperature: const [
      UnitDefinition(id: 'c', name: 'Celsius', symbol: '°C', toBase: 1.0),
      UnitDefinition(id: 'f', name: 'Fahrenheit', symbol: '°F', toBase: 1.0),
      UnitDefinition(id: 'k', name: 'Kelvin', symbol: 'K', toBase: 1.0),
    ],
    UnitCategory.energy: const [
      UnitDefinition(id: 'j', name: 'Joules', symbol: 'J', toBase: 1.0),
      UnitDefinition(
        id: 'kj',
        name: 'Kilojoules',
        symbol: 'kJ',
        toBase: 1000.0,
      ),
      UnitDefinition(
        id: 'cal',
        name: 'Thermal calories',
        symbol: 'cal',
        toBase: 4.184,
      ),
      UnitDefinition(
        id: 'kcal',
        name: 'Food calories',
        symbol: 'kcal',
        toBase: 4184.0,
      ),
      UnitDefinition(
        id: 'wh',
        name: 'Watt-hours',
        symbol: 'Wh',
        toBase: 3600.0,
      ),
      UnitDefinition(
        id: 'kwh',
        name: 'Kilowatt-hours',
        symbol: 'kWh',
        toBase: 3600000.0,
      ),
      UnitDefinition(
        id: 'ev',
        name: 'Electronvolts',
        symbol: 'eV',
        toBase: 1.602176634e-19,
      ),
      UnitDefinition(
        id: 'btu',
        name: 'British thermal units',
        symbol: 'BTU',
        toBase: 1055.06,
      ),
      UnitDefinition(
        id: 'ft_lb',
        name: 'Foot-pounds',
        symbol: 'ft⋅lb',
        toBase: 1.355818,
      ),
    ],
    UnitCategory.area: const [
      UnitDefinition(
        id: 'mm2',
        name: 'Square millimeters',
        symbol: 'mm²',
        toBase: 1e-6,
      ),
      UnitDefinition(
        id: 'cm2',
        name: 'Square centimeters',
        symbol: 'cm²',
        toBase: 1e-4,
      ),
      UnitDefinition(
        id: 'm2',
        name: 'Square meters',
        symbol: 'm²',
        toBase: 1.0,
      ),
      UnitDefinition(id: 'ha', name: 'Hectares', symbol: 'ha', toBase: 10000.0),
      UnitDefinition(
        id: 'km2',
        name: 'Square kilometers',
        symbol: 'km²',
        toBase: 1e6,
      ),
      UnitDefinition(
        id: 'in2',
        name: 'Square inches',
        symbol: 'in²',
        toBase: 0.00064516,
      ),
      UnitDefinition(
        id: 'ft2',
        name: 'Square feet',
        symbol: 'ft²',
        toBase: 0.09290304,
      ),
      UnitDefinition(
        id: 'yd2',
        name: 'Square yards',
        symbol: 'yd²',
        toBase: 0.83612736,
      ),
      UnitDefinition(
        id: 'ac',
        name: 'Acres',
        symbol: 'ac',
        toBase: 4046.8564224,
      ),
      UnitDefinition(
        id: 'mi2',
        name: 'Square miles',
        symbol: 'mi²',
        toBase: 2589988.110336,
      ),
    ],
    UnitCategory.speed: const [
      UnitDefinition(
        id: 'cm_s',
        name: 'Centimeters per second',
        symbol: 'cm/s',
        toBase: 0.01,
      ),
      UnitDefinition(
        id: 'm_s',
        name: 'Meters per second',
        symbol: 'm/s',
        toBase: 1.0,
      ),
      UnitDefinition(
        id: 'km_h',
        name: 'Kilometers per hour',
        symbol: 'km/h',
        toBase: 0.2777777777777778,
      ),
      UnitDefinition(
        id: 'ft_s',
        name: 'Feet per second',
        symbol: 'ft/s',
        toBase: 0.3048,
      ),
      UnitDefinition(
        id: 'mph',
        name: 'Miles per hour',
        symbol: 'mph',
        toBase: 0.44704,
      ),
      UnitDefinition(
        id: 'knot',
        name: 'Knots',
        symbol: 'kn',
        toBase: 0.5144444444444445,
      ),
      UnitDefinition(id: 'mach', name: 'Mach', symbol: 'Ma', toBase: 340.29),
    ],
    UnitCategory.time: const [
      UnitDefinition(
        id: 'ms',
        name: 'Milliseconds',
        symbol: 'ms',
        toBase: 0.001,
      ),
      UnitDefinition(id: 's', name: 'Seconds', symbol: 's', toBase: 1.0),
      UnitDefinition(id: 'min', name: 'Minutes', symbol: 'min', toBase: 60.0),
      UnitDefinition(id: 'h', name: 'Hours', symbol: 'h', toBase: 3600.0),
      UnitDefinition(id: 'd', name: 'Days', symbol: 'd', toBase: 86400.0),
      UnitDefinition(id: 'wk', name: 'Weeks', symbol: 'wk', toBase: 604800.0),
      UnitDefinition(id: 'yr', name: 'Years', symbol: 'yr', toBase: 31536000.0),
    ],
    UnitCategory.power: const [
      UnitDefinition(id: 'w', name: 'Watts', symbol: 'W', toBase: 1.0),
      UnitDefinition(id: 'kw', name: 'Kilowatts', symbol: 'kW', toBase: 1000.0),
      UnitDefinition(
        id: 'hp_mech',
        name: 'Horsepower (US/Imperial)',
        symbol: 'hp',
        toBase: 745.69987,
      ),
      UnitDefinition(
        id: 'ft_lb_s',
        name: 'Foot-pounds/minute',
        symbol: 'ft⋅lb/min',
        toBase: 0.0225969658,
      ),
      UnitDefinition(
        id: 'btu_min',
        name: 'BTUs/minute',
        symbol: 'BTU/min',
        toBase: 17.584264,
      ),
    ],
    UnitCategory.dataStorage: const [
      UnitDefinition(id: 'b', name: 'Bits', symbol: 'b', toBase: 0.125),
      UnitDefinition(id: 'B', name: 'Bytes', symbol: 'B', toBase: 1.0),
      UnitDefinition(
        id: 'KB',
        name: 'Kilobytes (decimal)',
        symbol: 'KB',
        toBase: 1e3,
      ),
      UnitDefinition(
        id: 'KiB',
        name: 'Kibibytes (binary)',
        symbol: 'KiB',
        toBase: 1024.0,
      ),
      UnitDefinition(
        id: 'MB',
        name: 'Megabytes (decimal)',
        symbol: 'MB',
        toBase: 1e6,
      ),
      UnitDefinition(
        id: 'MiB',
        name: 'Mebibytes (binary)',
        symbol: 'MiB',
        toBase: 1048576.0,
      ),
      UnitDefinition(
        id: 'GB',
        name: 'Gigabytes (decimal)',
        symbol: 'GB',
        toBase: 1e9,
      ),
      UnitDefinition(
        id: 'GiB',
        name: 'Gibibytes (binary)',
        symbol: 'GiB',
        toBase: 1073741824.0,
      ),
      UnitDefinition(
        id: 'TB',
        name: 'Terabytes (decimal)',
        symbol: 'TB',
        toBase: 1e12,
      ),
      UnitDefinition(
        id: 'TiB',
        name: 'Tebibytes (binary)',
        symbol: 'TiB',
        toBase: 1099511627776.0,
      ),
    ],
    UnitCategory.pressure: const [
      UnitDefinition(id: 'pa', name: 'Pascals', symbol: 'Pa', toBase: 1.0),
      UnitDefinition(
        id: 'kpa',
        name: 'Kilopascals',
        symbol: 'kPa',
        toBase: 1000.0,
      ),
      UnitDefinition(id: 'bar', name: 'Bars', symbol: 'bar', toBase: 100000.0),
      UnitDefinition(
        id: 'psi',
        name: 'Pounds/sq. inch',
        symbol: 'psi',
        toBase: 6894.757,
      ),
      UnitDefinition(
        id: 'atm',
        name: 'Standard atmospheres',
        symbol: 'atm',
        toBase: 101325.0,
      ),
      UnitDefinition(
        id: 'torr',
        name: 'Millimeters of mercury',
        symbol: 'mmHg',
        toBase: 133.3224,
      ),
    ],
    UnitCategory.angle: const [
      UnitDefinition(id: 'deg', name: 'Degrees', symbol: '°', toBase: 1.0),
      UnitDefinition(
        id: 'rad',
        name: 'Radians',
        symbol: 'rad',
        toBase: 57.295779513,
      ),
      UnitDefinition(id: 'grad', name: 'Gradians', symbol: 'grad', toBase: 0.9),
    ],
  };

  /// Convert between units in the same category
  static double convert({
    required UnitCategory category,
    required UnitDefinition from,
    required UnitDefinition to,
    required double value,
  }) {
    if (from.id == to.id) return value;

    if (category == UnitCategory.temperature) {
      // Temperature conversion with offsets
      double celsius;
      if (from.id == 'c') {
        celsius = value;
      } else if (from.id == 'f') {
        celsius = (value - 32.0) * (5.0 / 9.0);
      } else {
        // Kelvin
        celsius = value - 273.15;
      }

      if (to.id == 'c') {
        return celsius;
      } else if (to.id == 'f') {
        return celsius * (9.0 / 5.0) + 32.0;
      } else {
        // Kelvin
        return celsius + 273.15;
      }
    }

    // Standard linear conversion
    final inBase = value * from.toBase;
    return inBase / to.toBase;
  }
}

/// Lightweight Currency Service with caching and offline fallback
class CurrencyService {
  final String apiEndpoint;
  final http.Client _client;

  // Cache: base currency -> { targetCurrency: rate }, and timestamp
  final Map<String, Map<String, double>> _cachedRates = {};
  DateTime? _lastUpdated;
  bool _isOfflineRate = false;

  CurrencyService({
    this.apiEndpoint = 'https://api.frankfurter.dev/v1/latest',
    http.Client? client,
  }) : _client = client ?? http.Client() {
    // Populate sensible static fallback rates (USD base) in case totally offline
    _cachedRates['USD'] = {
      'USD': 1.0,
      'EUR': 0.88,
      'GBP': 0.77,
      'JPY': 152.0,
      'CAD': 1.38,
      'AUD': 1.51,
      'CHF': 0.88,
      'CNY': 7.15,
      'INR': 85.0,
    };
    _lastUpdated = DateTime(2026, 1, 1);
  }

  DateTime? get lastUpdated => _lastUpdated;
  bool get isOfflineRate => _isOfflineRate;

  /// Fetch exchange rates from Frankfurter API
  Future<Map<String, double>> fetchRates({String base = 'USD'}) async {
    try {
      final uri = Uri.parse('$apiEndpoint?base=$base');
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final ratesRaw = data['rates'] as Map<String, dynamic>;
        final rates = <String, double>{base: 1.0};
        ratesRaw.forEach((k, v) {
          rates[k] = (v as num).toDouble();
        });
        _cachedRates[base] = rates;
        _lastUpdated = DateTime.now();
        _isOfflineRate = false;
        return rates;
      } else {
        throw Exception('Server responded with ${response.statusCode}');
      }
    } catch (e) {
      // Offline fallback
      _isOfflineRate = true;
      if (_cachedRates.containsKey(base)) {
        return _cachedRates[base]!;
      }
      // If we don't have this base cached, check if we can cross-calculate with USD
      if (_cachedRates.containsKey('USD') &&
          _cachedRates['USD']!.containsKey(base)) {
        final usdRates = _cachedRates['USD']!;
        final baseToUsd = 1.0 / usdRates[base]!;
        final derived = <String, double>{};
        usdRates.forEach((k, v) {
          derived[k] = v * baseToUsd;
        });
        _cachedRates[base] = derived;
        return derived;
      }
      throw Exception('Failed to load exchange rates: $e');
    }
  }

  /// Convert currency amount
  Future<double> convertCurrency({
    required String from,
    required String to,
    required double amount,
  }) async {
    if (from == to) return amount;
    final rates = await fetchRates(base: from);
    final rate = rates[to];
    if (rate == null) {
      throw Exception('Currency rate for $to not available.');
    }
    return amount * rate;
  }
}
