import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat_user.dart';
import '../models/message.dart';
import 'user_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  bool canChatWith(String otherUserId) {
    final currentUserId = this.currentUserId;
    return currentUserId != null && currentUserId != otherUserId;
  }

  String buildConversationId(String userA, String userB) {
    final ids = [userA, userB]..sort();
    return ids.join('_');
  }

  Future<void> ensureCurrentUserProfile() async {
    await UserService().syncFirebaseUserProfile();
  }

  Future<List<ChatUser>> getUsers() async {
    final currentUserId = this.currentUserId;
    if (currentUserId == null) return [];

    await ensureCurrentUserProfile();

    final snapshot = await _firestore.collection('users').get();
    final users = snapshot.docs
        .map(ChatUser.fromFirestore)
        .where((user) => user.id != currentUserId)
        .toList();

    users.sort(
      (a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    );
    return users;
  }

  Stream<List<ChatUser>> watchUsers() async* {
    final currentUserId = this.currentUserId;
    if (currentUserId == null) return;

    await ensureCurrentUserProfile();
    yield* _firestore.collection('users').snapshots().map((snapshot) {
      final users = snapshot.docs
          .map(ChatUser.fromFirestore)
          .where((user) => user.id != currentUserId)
          .toList();
      users.sort(
        (a, b) => a.displayName.toLowerCase().compareTo(
          b.displayName.toLowerCase(),
        ),
      );
      return users;
    });
  }

  Stream<List<Message>> getMessages(String otherUserId) {
    final currentUserId = this.currentUserId;
    if (currentUserId == null) return const Stream.empty();

    final conversationId = buildConversationId(currentUserId, otherUserId);

    return _firestore
        .collection('chats')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Message.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> sendMessage({
    required String receiverId,
    required String text,
  }) async {
    final currentUserId = this.currentUserId;
    if (currentUserId == null || !canChatWith(receiverId)) return;

    final cleanedText = text.trim();
    if (cleanedText.isEmpty) return;

    final conversationId = buildConversationId(currentUserId, receiverId);
    final messageReference = _firestore
        .collection('chats')
        .doc(conversationId)
        .collection('messages')
        .doc();

    final message = Message(
      id: messageReference.id,
      senderId: currentUserId,
      receiverId: receiverId,
      text: cleanedText,
      timestamp: DateTime.now(),
      status: 'sent',
    );

    await messageReference.set(message.toMap());
    await _firestore
        .collection('chats')
        .doc(conversationId)
        .set({'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  Future<void> markMessagesAsSeen(String otherUserId) async {
    final currentUserId = this.currentUserId;
    if (currentUserId == null || !canChatWith(otherUserId)) return;

    final conversationId = buildConversationId(currentUserId, otherUserId);
    final messages = await _firestore
        .collection('chats')
        .doc(conversationId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isNotEqualTo: 'seen')
        .get();

    for (final doc in messages.docs) {
      await doc.reference.update({'status': 'seen'});
    }
  }
}
