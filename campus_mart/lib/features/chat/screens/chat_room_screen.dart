import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../providers/chat_provider.dart';
import '../models/chat_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../app/theme.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  final String listingTitle;
  final String otherUserId;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    required this.listingTitle,
    required this.otherUserId,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report User', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to report this user for suspicious activity? Our team will review the chat history.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, minimumSize: const Size(100, 40)),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report submitted successfully. Thank you for keeping Campus Mart safe!')),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
    await context.read<ChatProvider>().sendMessage(
          chatId: widget.chatId,
          senderId: uid,
          text: text,
        );
    _scrollToBottom();
  }

  void _showBidDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Make an Offer'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Offer Amount (₹)',
            prefixIcon: Icon(Icons.currency_rupee),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text);
              if (amount == null || amount <= 0) return;
              Navigator.pop(ctx);
              
              final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
              await context.read<ChatProvider>().sendMessage(
                chatId: widget.chatId,
                senderId: uid,
                text: 'Offered ₹$amount',
                type: MessageType.bid,
                bidAmount: amount,
              );
              _scrollToBottom();
            },
            child: const Text('Send Offer'),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().currentUser?.uid ?? '';
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F5),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.listingTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            Text(
              'Negotiating',
              style: TextStyle(fontSize: 12, color: AppTheme.olxSecondary.withOpacity(0.9), fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _showBidDialog,
            icon: const Icon(Icons.gavel_rounded, color: Colors.white, size: 18),
            label: const Text('BID', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onSelected: (value) {
              if (value == 'profile') {
                context.push('/profile/${widget.otherUserId}');
              } else if (value == 'report') {
                _showReportDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_pin_outlined, color: AppTheme.primaryColor),
                    SizedBox(width: 12),
                    Text('View Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.report_problem_outlined, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Report User', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Bidding Banner for visibility (Restored Old UI)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppTheme.olxSecondary.withOpacity(0.15),
            child: Row(
              children: [
                const Icon(Icons.gavel_rounded, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Want to negotiate price?',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.primaryColor),
                  ),
                ),
                ElevatedButton(
                  onPressed: _showBidDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('MAKE OFFER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F5),
                image: DecorationImage(
                  image: const NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'),
                  opacity: 0.03,
                  repeat: ImageRepeat.repeat,
                ),
              ),
              child: StreamBuilder<List<MessageModel>>(
                stream: context.read<ChatProvider>().getMessages(widget.chatId),
                builder: (ctx, snap) {
                  final messages = snap.data ?? [];
                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.primaryColor.withOpacity(0.1)),
                          const SizedBox(height: 16),
                          const Text('Start the conversation!', style: TextStyle(color: Color(0xFF406367), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final msg = messages[i];
                      final isMe = msg.senderId == uid;
                      return _MessageBubble(message: msg, isMe: isMe);
                    },
                  );
                },
              ),
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                cursorColor: AppTheme.primaryColor,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
                    onPressed: _showBidDialog,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    if (message.type == MessageType.bid) {
      return _buildBidCard(context);
    }
    
    final timeStr = DateFormat('h:mm a').format(message.timestamp);
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isMe ? Colors.white : const Color(0xFF002F34),
                fontSize: 15,
                height: 1.4,
                fontWeight: isMe ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white.withOpacity(0.6) : const Color(0xFF406367),
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.done_all, size: 14, color: AppTheme.olxSecondary),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBidCard(BuildContext context) {
    final isPending = message.bidStatus == BidStatus.pending;
    final isAccepted = message.bidStatus == BidStatus.accepted;
    final isRejected = message.bidStatus == BidStatus.rejected;
    
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.gavel_rounded, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isMe ? 'Your Offer' : 'Received Offer',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                  const Spacer(),
                  _buildStatusChip(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Price Offered', style: TextStyle(color: Color(0xFF406367), fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    '₹${message.bidAmount}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.primaryColor),
                  ),
                  if (isPending && !isMe) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.read<ChatProvider>().updateBidStatus(message.id, BidStatus.rejected),
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Reject'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.read<ChatProvider>().updateBidStatus(message.id, BidStatus.accepted),
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.olxSecondary, foregroundColor: AppTheme.primaryColor),
                            child: const Text('Accept'),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (isAccepted)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text('✅ This offer was accepted!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                  if (isRejected)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text('❌ This offer was rejected.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color = Colors.orange;
    String label = 'PENDING';
    if (message.bidStatus == BidStatus.accepted) {
      color = Colors.green;
      label = 'ACCEPTED';
    } else if (message.bidStatus == BidStatus.rejected) {
      color = Colors.red;
      label = 'REJECTED';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
