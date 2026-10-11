/// Helper for calendar and date calculation
class DateCalculationResult {
  final int years;
  final int months;
  final int days;
  final int totalDays;

  const DateCalculationResult({
    required this.years,
    required this.months,
    required this.days,
    required this.totalDays,
  });

  String get summary {
    final parts = <String>[];
    if (years > 0) parts.add('$years ${years == 1 ? 'year' : 'years'}');
    if (months > 0) parts.add('$months ${months == 1 ? 'month' : 'months'}');
    if (days > 0 || parts.isEmpty)
      parts.add('$days ${days == 1 ? 'day' : 'days'}');
    return parts.join(', ');
  }
}

class DateCalculator {
  /// Calculate difference between two dates [from] and [to]
  static DateCalculationResult difference(DateTime from, DateTime to) {
    DateTime start = DateTime(from.year, from.month, from.day);
    DateTime end = DateTime(to.year, to.month, to.day);

    if (start.isAfter(end)) {
      final temp = start;
      start = end;
      end = temp;
    }

    final totalDays = end.difference(start).inDays;

    int y = end.year - start.year;
    int m = end.month - start.month;
    int d = end.day - start.day;

    if (d < 0) {
      // Borrow days from previous month of end date
      m -= 1;
      final prevMonthDays = _daysInMonth(
        end.year,
        end.month - 1 <= 0 ? 12 : end.month - 1,
      );
      d += prevMonthDays;
    }

    if (m < 0) {
      y -= 1;
      m += 12;
    }

    return DateCalculationResult(
      years: y,
      months: m,
      days: d,
      totalDays: totalDays,
    );
  }

  /// Add duration (years, months, days) to a date
  static DateTime addDuration(
    DateTime date, {
    int years = 0,
    int months = 0,
    int days = 0,
  }) {
    int targetYear = date.year + years;
    int targetMonth = date.month + months;

    while (targetMonth > 12) {
      targetYear++;
      targetMonth -= 12;
    }
    while (targetMonth < 1) {
      targetYear--;
      targetMonth += 12;
    }

    final maxDays = _daysInMonth(targetYear, targetMonth);
    final targetDay = date.day > maxDays ? maxDays : date.day;

    final targetDate = DateTime(targetYear, targetMonth, targetDay);
    return targetDate.add(Duration(days: days));
  }

  /// Subtract duration (years, months, days) from a date
  static DateTime subtractDuration(
    DateTime date, {
    int years = 0,
    int months = 0,
    int days = 0,
  }) {
    return addDuration(date, years: -years, months: -months, days: -days);
  }

  static int _daysInMonth(int year, int month) {
    if (month == 2) {
      final isLeapYear =
          (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const days = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return days[month];
  }
}
