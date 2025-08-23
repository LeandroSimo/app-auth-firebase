import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.email,
    super.photoURL,
    required super.postsCount,
    required super.age,
    required super.interests,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoURL: json['photoURL'] as String?,
      postsCount: _parseToInt(json['qtd_posts']) ?? 0,
      age: _parseToInt(json['age']) ?? 0,
      interests: _parseToStringList(json['interests']) ?? [],
    );
  }

  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserProfileModel.fromJson({...data, 'id': doc.id});
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoURL': photoURL,
      'qtd_posts': postsCount,
      'age': age,
      'interests': interests,
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // Remove o ID do documento
    json.remove('email'); // Remove o email, pois vem do Firebase Auth
    json.remove('photoURL'); // Remove a photoURL, pois vem do Firebase Auth
    return json;
  }

  factory UserProfileModel.fromEntity(UserProfile userProfile) {
    return UserProfileModel(
      id: userProfile.id,
      name: userProfile.name,
      email: userProfile.email,
      photoURL: userProfile.photoURL,
      postsCount: userProfile.postsCount,
      age: userProfile.age,
      interests: userProfile.interests,
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      name: name,
      email: email,
      photoURL: photoURL,
      postsCount: postsCount,
      age: age,
      interests: interests,
    );
  }

  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is double) return value.toInt();
    return null;
  }

  static List<String>? _parseToStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return null;
  }
}
