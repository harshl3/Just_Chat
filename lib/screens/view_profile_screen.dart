import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/helper/my_date_util.dart';
import 'package:we_chat/widgets/avatar_selector.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import '../models/chat_user.dart';
import 'auth/login.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),

      child: Scaffold(
        //app bar
        appBar: AppBar(title: Text(widget.user.name)),

        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Joined On: ',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 17,
              ),
            ),
            Text(
              MyDateUtil.getLastMessageTime(
                context: context,
                time: widget.user.createdAt,
                showYear: true,
              ),
              style: TextStyle(color: Colors.black54, fontSize: 15),
            ),
          ],
        ),

        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(width: mq.width, height: mq.height * .03),

                //image from server or avatar
                widget.user.avatar.isNotEmpty
                    ? // Show avatar if available
                    Container(
                        height: mq.height * .2,
                        width: mq.height * .2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getAvatarColor(widget.user.avatar),
                        ),
                        child: Center(
                          child: Text(
                            _getAvatarEmoji(widget.user.avatar),
                            style: TextStyle(fontSize: mq.height * .1),
                          ),
                        ),
                      )
                    : // Show profile picture if no avatar
                    ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .3),
                        child: widget.user.image.startsWith('http')
                          ? CachedNetworkImage(
                              height: mq.height * .2,
                              width: mq.height * .2,
                              fit: BoxFit.cover,
                              imageUrl: widget.user.image,
                              errorWidget: (context, url, error) =>
                                  CircleAvatar(child: Icon(CupertinoIcons.person)),
                            )
                          : widget.user.image.isNotEmpty ? Image.memory(
                              base64Decode(widget.user.image),
                              height: mq.height * .2,
                              width: mq.height * .2,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  CircleAvatar(child: Icon(CupertinoIcons.person)),
                            ) : CircleAvatar(child: Icon(CupertinoIcons.person)),
                      ),

                SizedBox(height: mq.height * .03),

                Text(
                  widget.user.email,
                  style: TextStyle(color: Colors.black87, fontSize: 17),
                ),

                SizedBox(height: mq.height * .02),

                //user about
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'About: ',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      widget.user.about,
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
