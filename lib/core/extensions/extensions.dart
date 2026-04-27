import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Useful extensions on BuildContext
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

/// Useful extensions on DateTime
extension DateTimeExtensions on DateTime {
  String get formatted => DateFormat('MMM d, yyyy').format(this);
  String get formattedWithTime => DateFormat('MMM d, yyyy · h:mm a').format(this);
  String get timeOnly => DateFormat('h:mm a').format(this);
  String get dayOfWeek => DateFormat('EEEE').format(this);
  String get shortDay => DateFormat('E').format(this);
  String get monthDay => DateFormat('MMM d').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  String get relativeLabel {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    final diff = DateTime.now().difference(this);
    if (diff.inDays < 7) return dayOfWeek;
    return formatted;
  }
}

/// Extensions on String
extension StringExtensions on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }
}

/// Extensions on num for responsive sizing
extension NumExtensions on num {
  SizedBox get heightBox => SizedBox(height: toDouble());
  SizedBox get widthBox => SizedBox(width: toDouble());
}
