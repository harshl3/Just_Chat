import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/my_date_util.dart';
import 'package:we_chat/models/message.dart';
import 'package:we_chat/screens/chat_screen.dart';
import 'package:we_chat/widgets/avatar_selector.dart';

import '../main.dart';
import '../models/chat_user.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 1,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)),
          );
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) {
              _message = list[0];
            }

            return ListTile(
              //user profile picture or avatar
              leading: widget.user.avatar.isNotEmpty
                  ? // Show avatar if available
                  Container(
                      height: mq.height * .055,
                      width: mq.height * .055,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getAvatarColor(widget.user.avatar),
                      ),
                      child: Center(
                        child: Text(
                          _getAvatarEmoji(widget.user.avatar),
                          style: TextStyle(fontSize: mq.height * .04),
                        ),
                      ),
                    )
                  : // Show profile picture if no avatar
                  ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .3),
                      child: CachedNetworkImage(
                        height: mq.height * .055,
                        width: mq.height * .055,
                        imageUrl: widget.user.image,
                        errorWidget: (context, url, error) =>
                            CircleAvatar(child: Icon(CupertinoIcons.person)),
                      ),
                    ),
              title: Text(widget.user.name),
              subtitle: Text(
                _message != null ? _message!.msg : widget.user.about,
                maxLines: 1,
              ),

              trailing: _message == null
                  ? null
                  : _message!.read.isEmpty && _message!.fromId != APIs.user.uid
                  ? Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    )
                  : Text(
                      MyDateUtil.getLastMessageTime(
                        context: context,
                        time: _message!.sent,
                      ),
                      style: TextStyle(color: Colors.black54),
                    ),
            );
          },
        ),
      ),
    );
  }

  // Helper method to get avatar color
  Color _getAvatarColor(String avatarId) {
    return AvatarSelector.getAvatarColor(avatarId);
  }

  // Helper method to get avatar emoji
  String _getAvatarEmoji(String avatarId) {
    return AvatarSelector.getAvatarEmoji(avatarId);
  }
}
