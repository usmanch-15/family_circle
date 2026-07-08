import 'package:flutter/cupertino.dart';

class AppSpacing {
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 12.0;
  static const double lg  = 16.0;
  static const double xl  = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  // Padding shortcuts
  static const p4  = EdgeInsetsPadding(4);
  static const p8  = EdgeInsetsPadding(8);
  static const p12 = EdgeInsetsPadding(12);
  static const p16 = EdgeInsetsPadding(16);
  static const p24 = EdgeInsetsPadding(24);
  static const p32 = EdgeInsetsPadding(32);

  // Border radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusRound = 100.0;
}

// Helper class for padding
class EdgeInsetsPadding {
  final double value;
  const EdgeInsetsPadding(this.value);
  get all => EdgeInsets.all(value);
  get h   => EdgeInsets.symmetric(horizontal: value);
  get v   => EdgeInsets.symmetric(vertical: value);
}