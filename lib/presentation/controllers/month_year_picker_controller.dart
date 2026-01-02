import 'package:flutter/material.dart';

/// Controller for MonthYearPicker
/// Tuân thủ Single Responsibility Principle - CHỈ LO LOGIC
class MonthYearPickerController extends ChangeNotifier {
  final int startYear;
  final int endYear;

  int _selectedMonth;
  int _selectedYear;

  MonthYearPickerController({
    required DateTime initialDate,
    required this.startYear,
    required this.endYear,
  })  : _selectedMonth = initialDate.month,
        _selectedYear = initialDate.year;

  // Getters
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;
  bool get canGoPreviousYear => _selectedYear > startYear;
  bool get canGoNextYear => _selectedYear < endYear;

  DateTime get selectedDate => DateTime(_selectedYear, _selectedMonth, 1);

  // Business Logic
  void selectMonth(int month) {
    if (month >= 1 && month <= 12) {
      _selectedMonth = month;
      notifyListeners();
    }
  }

  void previousYear() {
    if (canGoPreviousYear) {
      _selectedYear--;
      notifyListeners();
    }
  }

  void nextYear() {
    if (canGoNextYear) {
      _selectedYear++;
      notifyListeners();
    }
  }

  String getMonthName(int month) {
    const monthNames = [
      'Th1',
      'Th2',
      'Th3',
      'Th4',
      'Th5',
      'Th6',
      'Th7',
      'Th8',
      'Th9',
      'Th10',
      'Th11',
      'Th12',
    ];
    return monthNames[month - 1];
  }
}
