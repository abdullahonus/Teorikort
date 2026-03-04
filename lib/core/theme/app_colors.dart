import 'package:flutter/material.dart';

class AppColors {
  // ─── Light Theme Brand Colors ─────────────────────────────────────────────
  // Görselden analiz: Teal/Turkuaz Palette
  static const primary =
      Color(0xFF2ABAAB); // Ana teal — header, buton, aktif nav
  static const primaryLight =
      Color(0xFF4ECDC4); // Açık teal (hover, secondary use)
  static const primaryDark = Color(0xFF1A9E91); // Koyu teal — pressed states

  static const secondary = Color(0xFF1FA89A); // Biraz koyu teal — gradient içi
  static const accent = Color(0xFF4ECDC4); // Mint accent — başarı ikonları

  static const error = Color(0xFFE53935); // Standart kırmızı
  static const warning = Color(0xFFFFA726); // Amber uyarı
  static const info = Color(0xFF29B6F6); // Açık mavi bilgi

  // ─── Light Theme Surface Colors ───────────────────────────────────────────
  static const background = Color(0xFFFFFFFF); // Saf beyaz arka plan
  static const cardBackground = Color(0xFFF5F7F7); // Çok hafif gri kart
  static const surfaceVariant =
      Color(0xFFE8F5F4); // Mint highlight (expanded items)
  static const textPrimary = Color(0xFF1A2E35); // Koyu slate — ana metin
  static const textSecondary = Color(0xFF7B9099); // Gri — ikincil metin

  // ─── Dark Theme Colors ────────────────────────────────────────────────────
  static const backgroundDark = Color(0xFF0D1F24); // Derin lacivert/teal siyah
  static const cardBackgroundDark = Color(0xFF162830); // Koyu teal surface
  static const textPrimaryDark = Color(0xFFE0F2F1); // Buz beyaz
  static const textSecondaryDark = Color(0xFF80CBC4); // Soluk teal gri
}
