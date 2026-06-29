import 'package:flutter/material.dart';

class AppColors {
  // Purple theme - image ke according
  static const primary        = Color(0xFF6C3AE8);  // main purple
  static const primaryDark    = Color(0xFF5028C8);  // dark purple
  static const primaryLight   = Color(0xFF8B5CF6);  // light purple
  static const accent         = Color(0xFF7C3AED);
  static const background     = Color(0xFFF5F3FF);  // light purple bg
  static const surface        = Color(0xFFFFFFFF);
  static const error          = Color(0xFFDC2626);
  static const success        = Color(0xFF16A34A);
  static const textPrimary    = Color(0xFF111827);
  static const textSecondary  = Color(0xFF6B7280);
  static const textMuted      = Color(0xFF9CA3AF);
  static const textWhite      = Color(0xFFFFFFFF);
  static const border         = Color(0xFFE5E7EB);
  static const cardBg         = Color(0xFFEDE9FE);  // purple card
}

class Collections {
  static const users    = 'users';
  static const families = 'families';
  static const media    = 'media';
  static const chats    = 'chats';
  static const aiChats  = 'ai_chats';
}

class ApiConfig {
  static const claudeEndpoint = 'https://api.anthropic.com/v1/messages';
  static const claudeModel    = 'claude-sonnet-4-6';
  static const maxTokens      = 1000;
}

class AppStrings {
  static const appName         = 'Family Circle';
  static const tagline         = 'A private space for your family.';
  static const tagline2        = 'Memories. Conversations. Peace.';
  static const splashSub       = 'Because family matters most.';
  static const loginTitle      = 'Welcome Back';
  static const loginSubtitle   = 'Login to your Family Circle';
  static const signupTitle     = 'Create Account';
  static const signupSubtitle  = 'Join your Family Circle';
  static const googleSignIn    = 'Continue with Google';
  static const orDivider       = 'or';
}