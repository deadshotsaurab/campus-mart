

class ChatModel {
  final String id;
  final List<String> participants;
  final String listingId;
  final String listingTitle;
  final String listingImage;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final DateTime? updatedAt;

  ChatModel({
    required this.id,
    required this.participants,
    required this.listingId,
    required this.listingTitle,
    this.listingImage = '',
    required this.lastMessage,
    this.lastMessageTime,
    this.updatedAt,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatModel(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      listingId: map['listingId'] ?? '',
      listingTitle: map['listingTitle'] ?? '',
      listingImage: map['listingImage'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] != null ? DateTime.tryParse(map['lastMessageTime'].toString()) : null,
      updatedAt: map['lastMessageTime'] != null ? DateTime.tryParse(map['lastMessageTime'].toString()) : null,
    );
  }
}

enum MessageType { text, bid }
enum BidStatus { pending, accepted, rejected }

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;
  final MessageType type;
  final double? bidAmount;
  final BidStatus bidStatus;

  // Getter alias
  DateTime get timestamp => createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
    this.type = MessageType.text,
    this.bidAmount,
    this.bidStatus = BidStatus.pending,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      text: map['text'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
      type: map['type'] == 'bid' ? MessageType.bid : MessageType.text,
      bidAmount: map['bidAmount'] != null ? double.tryParse(map['bidAmount'].toString()) : null,
      bidStatus: _parseBidStatus(map['bidStatus']),
    );
  }

  static BidStatus _parseBidStatus(String? status) {
    switch (status) {
      case 'accepted': return BidStatus.accepted;
      case 'rejected': return BidStatus.rejected;
      default: return BidStatus.pending;
    }
  }

  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    'senderName': senderName,
    'text': text,
    'createdAt': DateTime.now().toIso8601String(),
    'type': type == MessageType.bid ? 'bid' : 'text',
    'bidAmount': bidAmount,
    'bidStatus': bidStatus.name,
  };
}

typedef ChatMessage = MessageModel;