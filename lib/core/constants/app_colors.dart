import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds & Surfaces
  static const Color background = Color(0xFF0F172A); // Dark slate
  static const Color surface = Color(0xFF1E293B);    // Slate card
  static const Color surfaceLight = Color(0xFF334155);
  static const Color border = Color(0xFF334155);

  // Accents & Brand
  static const Color primary = Color(0xFF6366F1);     // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color secondary = Color(0xFF06B6D4);   // Cyan / Countdown

  // Status & Categories
  static const Color success = Color(0xFF10B981);     // Emerald / Income / Completed
  static const Color warning = Color(0xFFF59E0B);     // Amber / Reminder
  static const Color danger = Color(0xFFEF4444);      // Rose / Penalty / Expense
  static const Color important = Color(0xFFF43F5E);   // Rose / Exclamation indicator

  // Text
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF182234)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient alertGradient = LinearGradient(
    colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient financeGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
