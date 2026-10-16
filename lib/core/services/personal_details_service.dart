import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';

class UserPersonalDetails {
  final String height;
  final String weight;
  final String occupation;
  final String location;
  final String hometown;
  final List<String> traits;
  final List<String> hobbies;

  const UserPersonalDetails({
    required this.height,
    required this.weight,
    required this.occupation,
    required this.location,
    required this.hometown,
    required this.traits,
    required this.hobbies,
  });

  Map<String, dynamic> toJson() => {
        'height': height,
        'weight': weight,
        'occupation': occupation,
        'location': location,
        'hometown': hometown,
        'traits': traits,
        'hobbies': hobbies,
      };

  factory UserPersonalDetails.fromJson(Map<String, dynamic> json) => UserPersonalDetails(
        height: json['height'] as String? ?? '173cm',
        weight: json['weight'] as String? ?? '60-65KG',
        occupation: json['occupation'] as String? ?? 'Small Business',
        location: json['location'] as String? ?? 'Islamabad',
        hometown: json['hometown'] as String? ?? 'Islamabad',
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

    // Dynamic fallback according to the user's name/gender
    final details = _generateDynamicFallback(user);
    _cache[user.id] = details;
    return details;
  }

  UserPersonalDetails _generateDynamicFallback(UserModel user) {
    final nameLower = user.name.toLowerCase();
    final isFemale = user.gender.toLowerCase() == 'female' ||
        nameLower.contains('anam') ||
        nameLower.contains('shanzay') ||
        nameLower.contains('sonia') ||
        nameLower.contains('neha') ||
        nameLower.contains('queen') ||
        nameLower.contains('ayesha') ||
        nameLower.contains('alishbha') ||
        nameLower.contains('hina');

    final loc = user.region.isNotEmpty ? user.region.split(',').first.trim() : 'Islamabad';

    if (isFemale) {
      if (nameLower.contains('anam')) {
        return UserPersonalDetails(
          height: '165cm',
          weight: '48-52KG',
          occupation: 'UI Designer & Host',
          location: loc,
          hometown: 'Lahore',
          traits: ['Creative', 'Romantic', 'Friendly'],
          hobbies: ['Photography', 'Music 🎵', 'Fashion 👠'],
        );
      } else if (nameLower.contains('shanzay')) {
        return UserPersonalDetails(
          height: '168cm',
          weight: '50-54KG',
          occupation: 'Fashion Model',
          location: loc,
          hometown: 'Karachi',
          traits: ['Energetic', 'Fun', 'Adventurous'],
          hobbies: ['Dancing 💃', 'Travel ✈️', 'Fitness 🏋️'],
        );
      } else if (nameLower.contains('sonia')) {
        return UserPersonalDetails(
          height: '162cm',
          weight: '50-53KG',
          occupation: 'Digital Creator',
          location: loc,
          hometown: 'Islamabad',
          traits: ['Sweet', 'Romantic', 'Patient'],
          hobbies: ['Reading 📚', 'Cooking 🍳', 'Music 🎵'],
        );
      } else {
        return UserPersonalDetails(
          height: '164cm',
          weight: '50-55KG',
          occupation: 'Streamer & Creator',
          location: loc,
          hometown: loc,
          traits: ['Romantic', 'Charming', 'Fun'],
          hobbies: ['Chatting 💬', 'Singing 🎤', 'Travel ✈️'],
        );
      }
    } else {
      if (nameLower.contains('shehryar')) {
        return UserPersonalDetails(
          height: '175cm',
          weight: '55-60KG',
          occupation: 'Developer',
          location: loc,
          hometown: 'Islamabad',
          traits: ['Romantic', 'Patient', 'Adventurous', 'Ambitious'],
          hobbies: ['Coding 💻', 'Gaming 🎮', 'Travel ✈️'],
        );
      }
      return UserPersonalDetails(
        height: '173cm',
        weight: '60-65KG',
        occupation: 'Small Business',
        location: loc,
        hometown: loc,
        traits: ['Romantic', 'Adventurous', 'Fun'],
        hobbies: ['Music 🎵', 'Gaming 🎮', 'Travel ✈️'],
      );
    }
  }
}
