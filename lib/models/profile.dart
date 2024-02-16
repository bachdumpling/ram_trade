class Profile {
  Profile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
  });

  /// User ID of the profile
  final String id;

  /// First name of the profile
  final String firstName;

  /// Last name of the profile
  final String lastName;

  /// Date and time when the profile was created
  final DateTime createdAt;

  /// A method to get the full name of the user
  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Profile.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        firstName = map['first_name'] ?? '',
        lastName = map['last_name'] ?? '',
        createdAt = DateTime.parse(map['created_at']);

  Profile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    DateTime? createdAt,
  }) {
    return Profile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
