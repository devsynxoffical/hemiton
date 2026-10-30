import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';

class UserPersonalDetails {
  final String height;
  final String weight;
  final String occupation;
  final String location;
  final String hometown;
  final bool isHometownLocked;
  final List<String> traits;
  final List<String> hobbies;

  const UserPersonalDetails({
    this.height = '173cm',
    this.weight = '60-65KG',
    this.occupation = 'Small Business',
    required this.location,
    required this.hometown,
    this.isHometownLocked = false,
    this.traits = const ['Romantic', 'Adventurous', 'Fun'],
    this.hobbies = const ['Music 🎵', 'Gaming 🎮', 'Travel ✈️'],
  });

  UserPersonalDetails copyWith({
    String? height,
    String? weight,
    String? occupation,
    String? location,
    String? hometown,
    bool? isHometownLocked,
    List<String>? traits,
    List<String>? hobbies,
  }) {
    return UserPersonalDetails(
      height: height ?? this.height,
      weight: weight ?? this.weight,
      occupation: occupation ?? this.occupation,
      location: location ?? this.location,
      hometown: hometown ?? this.hometown,
      isHometownLocked: isHometownLocked ?? this.isHometownLocked,
      traits: traits ?? this.traits,
      hobbies: hobbies ?? this.hobbies,
    );
  }

  Map<String, dynamic> toJson() => {
        'height': height,
        'weight': weight,
        'occupation': occupation,
        'location': location,
        'hometown': hometown,
        'isHometownLocked': isHometownLocked,
        'traits': traits,
        'hobbies': hobbies,
      };

  factory UserPersonalDetails.fromJson(Map<String, dynamic> json) => UserPersonalDetails(
        height: json['height'] as String? ?? '173cm',
        weight: json['weight'] as String? ?? '60-65KG',
        occupation: json['occupation'] as String? ?? 'Small Business',
        location: json['location'] as String? ?? 'Islamabad, Pakistan',
        hometown: json['hometown'] as String? ?? '',
        isHometownLocked: json['isHometownLocked'] == true,
        traits: (json['traits'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            ['Romantic', 'Adventurous', 'Fun'],
        hobbies: (json['hobbies'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            ['Music 🎵', 'Gaming 🎮', 'Travel ✈️'],
      );
}

class PersonalDetailsService {
  static final PersonalDetailsService instance = PersonalDetailsService._internal();
  PersonalDetailsService._internal();

  static const String _prefPrefix = 'user_personal_details_';

  // In-memory cache
  final Map<String, UserPersonalDetails> _cache = {};

  Future<void> saveDetails(String userId, UserPersonalDetails details) async {
    _cache[userId] = details;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefPrefix$userId', jsonEncode(details.toJson()));
    } catch (e) {
      debugPrint('Error saving personal details: $e');
    }
  }

  Future<UserPersonalDetails> getDetails(UserModel user) async {
    if (_cache.containsKey(user.id)) {
      return _cache[user.id]!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStr = prefs.getString('$_prefPrefix${user.id}');
      if (savedStr != null && savedStr.isNotEmpty) {
        final decoded = jsonDecode(savedStr) as Map<String, dynamic>;
        final details = UserPersonalDetails.fromJson(decoded);
        _cache[user.id] = details;
        return details;
      }
    } catch (e) {
      debugPrint('Error loading personal details: $e');
    }

    final details = _generateDynamicFallback(user);
    _cache[user.id] = details;
    return details;
  }

  /// Auto-detects the user's current city & country based on IP geolocation or device timezone/region
  Future<String> detectCurrentLocation() async {
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
      ));
      final res = await dio.get('http://ip-api.com/json/?fields=status,country,city');
      if (res.statusCode == 200 && res.data is Map) {
        final data = res.data as Map;
        if (data['status'] == 'success') {
          final city = (data['city']?.toString() ?? '').trim();
          final country = (data['country']?.toString() ?? '').trim();
          if (city.isNotEmpty && country.isNotEmpty) {
            return '$city, $country';
          }
          if (country.isNotEmpty) {
            return country;
          }
        }
      }
    } catch (_) {}

    // Fallback based on device timezone offset
    final offsetHours = DateTime.now().timeZoneOffset.inHours;
    if (offsetHours == 5) return 'Islamabad, Pakistan';
    if (offsetHours == 4) return 'Dubai, UAE';
    if (offsetHours == 3) return 'Riyadh, Saudi Arabia';
    if (offsetHours == 5 || DateTime.now().timeZoneOffset.inMinutes == 330) return 'New Delhi, India';
    if (offsetHours == 0 || offsetHours == 1) return 'London, United Kingdom';
    if (offsetHours <= -4 && offsetHours >= -8) return 'New York, United States';
    return 'Islamabad, Pakistan';
  }

  UserPersonalDetails _generateDynamicFallback(UserModel user) {
    final cleanRegion = user.region.replaceAll(RegExp(r'[\u{1F1E6}-\u{1F1FF}]{2}', unicode: true), '').trim();
    final loc = (cleanRegion.isNotEmpty && cleanRegion.toLowerCase() != 'global')
        ? cleanRegion
        : 'Islamabad, Pakistan';

    return UserPersonalDetails(
      location: loc,
      hometown: '',
      isHometownLocked: false,
    );
  }
}
