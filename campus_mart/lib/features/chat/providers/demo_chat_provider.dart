import 'package:flutter/material.dart';
import '../models/chat_model.dart';

class DemoChatProvider extends ChangeNotifier {
  final Map<String, List<MessageModel>> _messages = {};
  final List<ChatModel> _chats = [];

  Stream<List<ChatModel>> getUserChats(String userId) =>
      Stream.value(_chats);

  Stream<List<MessageModel>> getMessages(String chatId) {
    return Stream.periodic(const Duration(milliseconds: 500), (_) {
      return _messages[chatId] ?? [];
    });
  }

  Future<String> getOrCreateChat({
    required String currentUserId,
    required String otherUserId,
    required String listingId,
    required String listingTitle,
    required String listingImage,
  }) async {
    final chatId = 'chat_${listingId}_${currentUserId}';
    final exists = _chats.any((c) => c.id == chatId);
    if (!exists) {
      _chats.add(ChatModel(
        id: chatId,
        participants: [currentUserId, otherUserId],
        lastMessage: '',
        updatedAt: DateTime.now(),
        listingId: listingId,
        listingTitle: listingTitle,
        listingImage: listingImage,
      ));
      _messages[chatId] = [];
    }
    return chatId;
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    _messages[chatId] ??= [];
    _messages[chatId]!.add(MessageModel(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: 'User',
      text: text,
      createdAt: DateTime.now(),
    ));
    // Update last message in chat list
    final idx = _chats.indexWhere((c) => c.id == chatId);
    if (idx != -1) {
      _chats[idx] = ChatModel(
        id: chatId,
        participants: _chats[idx].participants,
        lastMessage: text,
        updatedAt: DateTime.now(),
        listingId: _chats[idx].listingId,
        listingTitle: _chats[idx].listingTitle,
        listingImage: _chats[idx].listingImage,
      );
    }
    notifyListeners();
  }
}
