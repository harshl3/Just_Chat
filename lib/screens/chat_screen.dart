import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/helper/my_date_util.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/models/message.dart';
import 'package:we_chat/screens/view_profile_screen.dart';
import 'package:we_chat/widgets/message_card.dart';
import 'package:we_chat/widgets/avatar_selector.dart';
import '../api/apis.dart';
import '../main.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //for storing all messages
  List<Message> _list = [];
  final _textController = TextEditingController();
  bool _showEmoji = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: SafeArea(
              child: _appBar(),
            ),
          ),

            backgroundColor: Color.fromARGB(255, 234, 248, 255),

            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return SizedBox();

                        //if data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          // log('Data : ${jsonEncode(data![0].data())}');
                          _list =
                              data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              reverse: true,
                              itemCount: _list.length,
                              padding: EdgeInsets.only(top: mq.height * .01),
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessageCard(message: _list[index]);
                              },
                            );
                          } else {
                            return Center(
                              child: Text(
                                'Sayy Hiii 🤓! ',
                                style: TextStyle(fontSize: 25),
                              ),
                            );
                          }
                      }
                    },
                  ),
                ),

                //chat input field
                _chatInput(),

                //show emoji button funcnality
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        emojiViewConfig: EmojiViewConfig(
                          backgroundColor: Color.fromARGB(255, 234, 248, 255),
                          columns: 8,
                          emojiSizeMax: 32.0 * (Platform.isIOS ? 1.20 : 1.0),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
  }

  //app bar widget
  Widget _appBar() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewProfileScreen(user: widget.user),
          ),
        );
      },
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

          return Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back, color: Colors.black54),
              ),

              //user profile picture or avatar
              (list.isNotEmpty ? list[0].avatar : widget.user.avatar).isNotEmpty
                  ? // Show avatar if available
                  Container(
                      height: mq.height * .055,
                      width: mq.height * .055,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getAvatarColor(
                          list.isNotEmpty ? list[0].avatar : widget.user.avatar,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _getAvatarEmoji(
                            list.isNotEmpty ? list[0].avatar : widget.user.avatar,
                          ),
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
                        imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
                        errorWidget: (context, url, error) =>
                            CircleAvatar(child: Icon(CupertinoIcons.person)),
                      ),
                    ),

              SizedBox(width: 10),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.isNotEmpty ? list[0].name : widget.user.name,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),

                  Text(
                    list.isNotEmpty
                        ? list[0].isOnline
                              ? 'Online'
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: list[0].lastActive,
                                )
                        : MyDateUtil.getLastActiveTime(
                            context: context,
                            lastActive: widget.user.lastActive,
                          ),
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ],
          );
        },
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

  //bottom chat input widget
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: mq.height * .01,
        horizontal: mq.width * .025,
      ),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _showEmoji = !_showEmoji;
                      });
                    },
                    icon: Icon(
                      Icons.emoji_emotions,
                      color: Colors.blueAccent,
                      size: 25,
                    ),
                  ),

                  Expanded(
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onTap: () {
                        if (_showEmoji) {
                          setState(() => _showEmoji = !_showEmoji);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Type Something...',
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.image, color: Colors.blueAccent, size: 26),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.blueAccent,
                      size: 26,
                    ),
                  ),

                  SizedBox(width: mq.width * .02),
                ],
              ),
            ),
          ),

          MaterialButton(
            onPressed: () {
              // Trim the text to remove extra spaces
              final trimmedText = _textController.text.trim();
              if (trimmedText.isNotEmpty) {
                if(_list.isEmpty){
                  APIs.sendFirstMessage(widget.user, trimmedText, Type.text);
                } else {
                  APIs.sendMessage(widget.user, trimmedText, Type.text);
                }
                _textController.clear();
              }
            },
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            minWidth: 0,
            shape: CircleBorder(),
            color: Colors.green,
            child: Icon(Icons.send, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}
