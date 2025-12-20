import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  ChatUser({
    required this.image,
    required this.name,
    required this.about,
    required this.createdAt,
    required this.id,
    required this.lastActive,
    required this.isOnline,
    required this.pushToken,
    required this.email,
    this.avatar = '', // Avatar field for predefined avatar selection
  });
  late String image;
  late String name;
  late String about;
  late String createdAt;
  late String id;
  late String lastActive;
  late bool isOnline;
  late String pushToken;
  late String email;
  late String avatar; // Stores the selected avatar identifier

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? ''; //?? -> null operetor
    name = json['name'] ?? ''; // if value is null then use ''
    about = json['about'] ?? '';
    
    // Handle Timestamp conversion for createdAt
    if (json['created_at'] is Timestamp) {
      createdAt = (json['created_at'] as Timestamp).millisecondsSinceEpoch.toString();
    } else {
      createdAt = json['created_at']?.toString() ?? '';
    }
    
    id = json['id'] ?? '';
    
    // Handle Timestamp conversion for lastActive
    if (json['last_active'] is Timestamp) {
      lastActive = (json['last_active'] as Timestamp).millisecondsSinceEpoch.toString();
    } else {
      lastActive = json['last_active']?.toString() ?? '';
    }
    
    // Fix: isOnline should be boolean, handle both bool and string cases
    if (json['is_online'] is bool) {
      isOnline = json['is_online'] as bool;
    } else {
      isOnline = json['is_online']?.toString().toLowerCase() == 'true' || false;
    }
    pushToken = json['push_token'] ?? '';
    email = json['email'] ?? '';
    avatar = json['avatar'] ?? ''; // Avatar identifier
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['name'] = name;
    data['about'] = about;
    data['created_at'] = createdAt;
    data['id'] = id;
    data['last_active'] = lastActive;
    data['is_online'] = isOnline;
    data['push_token'] = pushToken;
    data['email'] = email;
    data['avatar'] = avatar; // Include avatar in JSON
    return data;
  }
}
