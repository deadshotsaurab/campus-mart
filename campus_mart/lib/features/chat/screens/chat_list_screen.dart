import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/chat_provider.dart';
import '../models/chat_model.dart';
import '../../auth/providers/auth_provider.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final uid = auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('My Chats')),
      body: uid == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Login to see your chats'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Login'),
                  ),
                ],
              ),
            )
          : StreamBuilder<List<ChatModel>>(
              stream: context.read<ChatProvider>().getUserChats(uid),
              builder: (ctx, snap) {
                final chats = snap.data ?? [];
                if (chats.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No chats yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey)),
                        SizedBox(height: 8),
                        Text('Find a listing and chat with sellers!',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: chats.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final chat = chats[i];
                    final otherUserId = chat.participants.firstWhere(
                        (p) => p != uid,
                        orElse: () => uid ?? '');
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: chat.listingImage.isNotEmpty
                            ? Image.network(
                                chat.listingImage,
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _placeholder(),
                              )
                            : _placeholder(),
                      ),
                      title: Text(
                        chat.listingTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        chat.lastMessage.isEmpty
                            ? 'No messages yet'
                            : chat.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        chat.updatedAt == null ? '' : timeago.format(chat.updatedAt!),
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF6B7280)),
                      ),
                      onTap: () =>
                          context.push('/chat/${chat.id}', extra: {
                        'listingTitle': chat.listingTitle,
                        'otherUserId': otherUserId,
                      }),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 52,
      height: 52,
      color: const Color(0xFF1A1A5E).withOpacity(0.1),
      child: const Icon(Icons.storefront, color: Color(0xFF1A1A5E)),
    );
  }
}
