import 'package:flutter/material.dart';
import 'constants.dart';

class AppTextStyles {
  // Headings
  static const h1 = TextStyle(
      fontSize: 28, fontWeight: FontWeight.w700,
      color: AppColors.textPrimary, letterSpacing: -0.5);

  static const h2 = TextStyle(
      fontSize: 22, fontWeight: FontWeight.w700,
      color: AppColors.textPrimary, letterSpacing: -0.3);

  static const h3 = TextStyle(
      fontSize: 18, fontWeight: FontWeight.w600,
      color: AppColors.textPrimary);

  static const h4 = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600,
      color: AppColors.textPrimary);

  // Body
  static const body = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w400,
      color: AppColors.textPrimary, height: 1.5);

  static const bodyMedium = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w500,
      color: AppColors.textPrimary);

  static const bodySmall = TextStyle(
      fontSize: 12, fontWeight: FontWeight.w400,
      color: AppColors.textSecondary, height: 1.4);

  // Labels
  static const label = TextStyle(
      fontSize: 11, fontWeight: FontWeight.w600,
      color: AppColors.textMuted, letterSpacing: 0.8);

  static const caption = TextStyle(
      fontSize: 11, fontWeight: FontWeight.w400,
      color: AppColors.textMuted);

  // Special
  static const chatBubble = TextStyle(
      fontSize: 14, height: 1.4);

  static const timestamp = TextStyle(
      fontSize: 10, fontWeight: FontWeight.w400);

  static const sectionTitle = TextStyle(
      fontSize: 11, fontWeight: FontWeight.w600,
      letterSpacing: 0.8);

  static const buttonText = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);
}