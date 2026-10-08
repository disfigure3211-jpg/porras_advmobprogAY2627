class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String image;
  final String age;
  final String contactNo;
  final String accessToken;
  final String refreshToken;
  final String loginType;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.image,
    required this.age,
    required this.contactNo,
    required this.accessToken,
    required this.refreshToken,
    this.loginType = 'firebase',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    int parsedId;
    if (rawId is int) {
      parsedId = rawId;
    } else if (rawId is String) {
      parsedId = int.tryParse(rawId) ?? rawId.hashCode;
    } else if (rawId is num) {
      parsedId = rawId.toInt();
    } else {
      parsedId = 0;
    }

    return User(
      id: parsedId,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      image: json['image'] as String? ?? '',
      age: '${json['age'] ?? ''}',
      contactNo: json['contactNo'] as String? ?? '',
      accessToken: (json['accessToken'] ?? json['token'] ?? '') as String,
      refreshToken: json['refreshToken'] as String? ?? '',
      loginType: (json['loginType'] ?? json['provider'] ?? 'firebase') as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'gender': gender,
    'image': image,
    'age': age,
    'contactNo': contactNo,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'loginType': loginType,
  };
}
