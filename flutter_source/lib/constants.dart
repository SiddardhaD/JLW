import 'package:flutter/material.dart';

/// Corporate palette — white & blue executive theme.
class JLWColors {
  /// App background
  static const Color darkBg = Color(0xFFF3F6FB);

  /// Primary brand blue (re-using existing naming to avoid refactors)
  static const Color brandGreen = Color(0xFF1D4ED8);

  /// Surfaces
  static const Color cardBg = Colors.white;
  static const Color inputBg = Color(0xFFE5EDF8);
  static const Color mintAccent = brandGreen;
  static const Color slateText = Color(0xFF64748B);
  static const Color textDark = Color(0xFF0F172A);
  static const Color borderColor = Color(0xFFD0DEEE);

  // Action status indicators
  static const Color buttonReject = Color(0xFFDC2626);
  static const Color statusUrgent = Color(0xFFDC2626);
  static const Color statusRoutine = brandGreen;
  static const Color statusHighValue = Color(0xFFF97316);
}
