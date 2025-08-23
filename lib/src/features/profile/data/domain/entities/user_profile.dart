class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? photoURL;
  final int postsCount;
  final int age;
  final List<String> interests;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.photoURL,
    required this.postsCount,
    required this.age,
    required this.interests,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? photoURL,
    int? postsCount,
    int? age,
    List<String>? interests,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      postsCount: postsCount ?? this.postsCount,
      age: age ?? this.age,
      interests: interests ?? this.interests,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProfile &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.photoURL == photoURL &&
        other.postsCount == postsCount &&
        other.age == age &&
        other.interests.toString() == interests.toString();
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        photoURL.hashCode ^
        postsCount.hashCode ^
        age.hashCode ^
        interests.hashCode;
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, email: $email, photoURL: $photoURL, postsCount: $postsCount, age: $age, interests: $interests)';
  }
}
