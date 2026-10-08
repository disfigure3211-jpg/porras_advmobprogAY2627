import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String avatar;

  const ChatUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatar = '',
  });

  factory ChatUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final storedFirstName = (data['firstName'] as String?)?.trim() ?? '';
    final fallbackName =
        (data['name'] as String?)?.trim() ??
        (data['username'] as String?)?.trim() ??
        '';
    return ChatUser(
      id: doc.id,
      firstName: storedFirstName.isNotEmpty ? storedFirstName : fallbackName,
      lastName: (data['lastName'] ?? '') as String,
      email: (data['email'] ?? '') as String,
      avatar:
          (data['avatar'] as String?) ??
          (data['photoURL'] as String?) ??
          (data['image'] as String?) ??
          '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'avatar': avatar,
    };
  }

  String get displayName => '$firstName $lastName'.trim();
  String get shortName => displayName.isNotEmpty ? displayName : email;
  String get initials {
    final value = shortName.trim();
    return value.isNotEmpty ? value.substring(0, 1).toUpperCase() : '?';
  }
}
