import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_model.dart';
import '../../auth/providers/auth_provider.dart';

class ChatProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  AuthProvider? _auth;

  void updateAuth(AuthProvider auth) {
    _auth = auth;
    notifyListeners();
  }

  String _chatId(String uid1, String uid2, String listingId) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}_$listingId';
  }

  Future<String> getOrCreateChat({
    required String currentUserId,
    required String otherUserId,
    required String listingId,
    required String listingTitle,
    String listingImage = '',
  }) async {
    final chatId = _chatId(currentUserId, otherUserId, listingId);
    final doc = await _supabase.from('chats').select().eq('id', chatId).maybeSingle();
    
    if (doc == null) {
      await _supabase.from('chats').insert({
        'id': chatId,
        'participants': [currentUserId, otherUserId],
        'listingId': listingId,
        'listingTitle': listingTitle,
        'listingImage': listingImage,
        'lastMessage': '',
        'lastMessageTime': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
    return chatId;
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chatId', chatId)
        .order('createdAt', ascending: true)
        .map((data) => data.map((d) => MessageModel.fromMap(d, d['id'])).toList());
  }

  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String senderId,
    MessageType type = MessageType.text,
    double? bidAmount,
  }) async {
    final myName = _auth?.currentUser?.name ?? 'User';
    final now = DateTime.now().toIso8601String();
    
    await _supabase.from('messages').insert({
      'chatId': chatId,
      'senderId': senderId,
      'senderName': myName,
      'text': text,
      'type': type == MessageType.bid ? 'bid' : 'text',
      'bidAmount': bidAmount,
      'bidStatus': 'pending',
      'createdAt': now,
    });
    
    await _supabase.from('chats').update({
      'lastMessage': text,
      'lastMessageTime': now,
    }).eq('id', chatId);
  }

  Future<void> updateBidStatus(String messageId, BidStatus status) async {
    await _supabase.from('messages').update({
      'bidStatus': status.name,
    }).eq('id', messageId);
  }

  Stream<List<ChatModel>> getUserChats(String userId) {
    return _supabase
        .from('chats')
        .stream(primaryKey: ['id'])
        .order('lastMessageTime', ascending: false)
        .map((data) {
           return data.where((d) => (d['participants'] as List).contains(userId))
             .map((d) => ChatModel.fromMap(d, d['id']))
             .toList();
        });
  }
}