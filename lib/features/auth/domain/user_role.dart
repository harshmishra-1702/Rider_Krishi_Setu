// lib/features/auth/domain/user_role.dart
import 'package:flutter/material.dart';

enum UserRole {
  rider(
    id: 'rider',
    title: 'Logistics Partner / Rider',
    titleHindi: 'लॉजिस्टिक्स पार्टनर / चालक (राइडर)',
    titleMarathi: 'लॉजिस्टिक्स पार्टनर / चालक (रायडर)',
    subtitle: 'Transport produce from farm gates to bulk buyers & dark stores',
    subtitleHindi: 'खेत से थोक खरीदारों और डार्क स्टोर्स तक ताजा फसल सुरक्षित पहुंचाएं',
    subtitleMarathi: 'शेतातून थेट खरेदीदार व डार्क स्टोर्सपर्यंत शेतमालाची वाहतूक करा',
    icon: Icons.local_shipping,
    color: Color(0xFF1B5E20), // Emerald Green
    isAvailable: true,
  ),
  farmer(
    id: 'farmer',
    title: 'Farmer / Producer (Kisan)',
    titleHindi: 'किसान / उत्पादक',
    titleMarathi: 'शेतकरी / उत्पादक',
    subtitle: 'List harvest batches, generate QR codes & request pooled pickup',
    subtitleHindi: 'फसल बैच लिस्ट करें, QR कोड बनाएं और पिकअप का अनुरोध करें',
    subtitleMarathi: 'पिकांची नोंद करा, QR कोड तयार करा आणि वाहतुकीची मागणी करा',
    icon: Icons.agriculture,
    color: Color(0xFF2E7D32),
    isAvailable: true,
  ),
  bulkBuyer(
    id: 'bulk_buyer',
    title: 'Commercial Bulk Buyer / Dark Store',
    titleHindi: 'थोक खरीदार / डार्क स्टोर',
    titleMarathi: 'घाऊक खरेदीदार / डार्क स्टोअर',
    subtitle: 'Procure bulk produce, track delivery & generate handover OTP',
    subtitleHindi: 'थोक उपज खरीदें, डिलीवरी ट्रैक करें और हैंडओवर OTP दें',
    subtitleMarathi: 'मोठ्या प्रमाणावर शेतमाल खरेदी करा व डिलिव्हरी ओटीपी द्या',
    icon: Icons.storefront,
    color: Color(0xFFE65100),
    isAvailable: true,
  ),
  consumer(
    id: 'consumer',
    title: 'Retail Consumer / Household',
    titleHindi: 'उपभोक्ता / ग्राहक',
    titleMarathi: 'ग्राहक / कुटुंब',
    subtitle: 'Farm-fresh direct produce delivery at fair transparent prices',
    subtitleHindi: 'उचित मूल्य पर खेत से सीधी ताजी उपज प्राप्त करें',
    subtitleMarathi: 'वाजवी भावात थेट शेतातून ताजा भाजीपाला मिळवा',
    icon: Icons.shopping_basket,
    color: Color(0xFF0277BD),
    isAvailable: true,
  );

  const UserRole({
    required this.id,
    required this.title,
    required this.titleHindi,
    required this.titleMarathi,
    required this.subtitle,
    required this.subtitleHindi,
    required this.subtitleMarathi,
    required this.icon,
    required this.color,
    required this.isAvailable,
  });

  final String id;
  final String title;
  final String titleHindi;
  final String titleMarathi;
  final String subtitle;
  final String subtitleHindi;
  final String subtitleMarathi;
  final IconData icon;
  final Color color;
  final bool isAvailable;

  String localizedTitle(String langCode) {
    if (langCode == 'hi') return titleHindi;
    if (langCode == 'mr') return titleMarathi;
    return title;
  }

  String localizedSubtitle(String langCode) {
    if (langCode == 'hi') return subtitleHindi;
    if (langCode == 'mr') return subtitleMarathi;
    return subtitle;
  }
}
