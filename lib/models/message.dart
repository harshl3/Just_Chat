import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  Message({
    required this.fromId,
    required this.msg,
    required this.read,
    required this.sent,
    required this.toId,
    required this.type,
  });
  late final String fromId;
  late final String msg;
  late final String read;
  late final String sent;
  late final String toId;
  late final Type type;

  Message.fromJson(Map<String, dynamic> json) {
    fromId = json['fromId'].toString();
    msg = json['msg'].toString();
    
    // Handle Timestamp conversion for read field
    if (json['read'] is Timestamp) {
      read = (json['read'] as Timestamp).millisecondsSinceEpoch.toString();
    } else {
      read = json['read']?.toString() ?? '';
    }
    
    // Handle Timestamp conversion for sent field
    if (json['sent'] is Timestamp) {
      sent = (json['sent'] as Timestamp).millisecondsSinceEpoch.toString();
    } else {
      sent = json['sent']?.toString() ?? '';
    }
    
    toId = json['toId'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['fromId'] = fromId;
    data['msg'] = msg;
    data['read'] = read;
    data['sent'] = sent;
    data['toId'] = toId;
    data['type'] = type.name;
    return data;
  }
}

enum Type { text, image }
