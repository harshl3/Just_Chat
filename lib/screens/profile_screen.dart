import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../widgets/avatar_selector.dart';
import 'auth/login.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),

      child: Scaffold(
        //app bar
        appBar: AppBar(title: Text("Profile Screen")),

        //floating button to add new user
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            // shape:StadiumBorder(),
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              Dialogs.showProgressBar(context, 'Logging Out');

              await APIs.updateActiveStatus(false);

              await APIs.auth.signOut();

              APIs.auth = FirebaseAuth.instance;

              // Navigate back to Login Page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            icon: Icon(Icons.logout, color: Colors.white),
            label: Text(
              'Logout',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),

        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(width: mq.width, height: mq.height * .03),

                  //user profile picture
                  Stack(
                    children: [
                      //profile picture
                      _image != null
                          ?
                            //local image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                mq.height * .3,
                              ),
                              child: Image.file(
                                File(_image!),
                                height: mq.height * .2,
                                width: mq.height * .2,
                                fit: BoxFit.cover,
                              ),
                            )
                          :
                            //image from server or avatar
                            widget.user.avatar.isNotEmpty
                                ? // Show selected avatar if available
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
                                : // Show profile picture if no avatar selected
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      mq.height * .3,
                                    ),
                                    child: widget.user.image.startsWith('http')
                                      ? CachedNetworkImage(
                                          height: mq.height * .2,
                                          width: mq.height * .2,
                                          fit: BoxFit.cover,
                                          imageUrl: widget.user.image,
                                          errorWidget: (context, url, error) =>
                                              CircleAvatar(
                                                child: Icon(CupertinoIcons.person),
                                              ),
                                        )
                                      : widget.user.image.isNotEmpty ? Image.memory(
                                          base64Decode(widget.user.image),
                                          height: mq.height * .2,
                                          width: mq.height * .2,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              CircleAvatar(
                                                child: Icon(CupertinoIcons.person),
                                              ),
                                        ) : CircleAvatar(child: Icon(CupertinoIcons.person)),
                                  ),

                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          onPressed: () {
                            _showBottomSheet();
                          },
                          elevation: 1,
                          shape: CircleBorder(),
                          color: Colors.white,
                          child: Icon(Icons.edit, color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: mq.height * .03),

                  Text(
                    widget.user.email,
                    style: TextStyle(color: Colors.black54, fontSize: 17),
                  ),

                  SizedBox(height: mq.height * .05),

                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      initialValue: widget.user.name,
                      onSaved: (val) => APIs.me.name = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person, color: Colors.blue),
                        hintText: 'eg. Happy Singh',
                        label: Text('Name'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),

                  // SizedBox(height: mq.height * .02),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      initialValue: widget.user.about,
                      onSaved: (val) => APIs.me.about = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                        ),
                        hintText: 'eg. Feeling Happy :)',
                        label: Text('About'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: mq.height * .05),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: StadiumBorder(),
                      minimumSize: Size(mq.width * .3, mq.height * .06),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // Update user info including avatar
                        APIs.updateUserInfo().then((value) async {
                          if (_image != null) {
                            Dialogs.showProgressBar(context, 'Saving Profile Picture...');
                            await APIs.updateProfilePicture(File(_image!));
                            Navigator.pop(context);
                          }
                          if(mounted) {
                            Dialogs.showSnackBar(
                              context,
                              'Profile Updated Successfully !',
                            );
                          }
                        });
                      }
                    },
                    icon: Icon(Icons.edit, size: 28, color: Colors.white),
                    label: Text(
                      'UPDATE',
                      style: TextStyle(fontSize: 17, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //bottom sheet for picking a profile picture or avatar for user
  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(
            top: mq.height * .03,
            bottom: mq.height * .05,
          ),
          children: [
            Text(
              'Pick Profile Picture or Avatar',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),

            SizedBox(height: mq.height * .02),

            // Avatar selection section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose an Avatar:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: mq.height * .01),
                  AvatarSelector(
                    onAvatarSelected: (avatarId) {
                      setState(() {
                        APIs.me.avatar = avatarId;
                        _image = null; // Clear profile picture if avatar is selected
                      });
                      Navigator.pop(context);
                      // Update avatar in database
                      APIs.updateUserAvatar(avatarId).then((value) {
                        Dialogs.showSnackBar(context, 'Avatar updated successfully!');
                      });
                    },
                    currentAvatar: widget.user.avatar,
                  ),
                  SizedBox(height: mq.height * .02),
                  Divider(),
                  SizedBox(height: mq.height * .01),
                  Text(
                    'Or Upload Profile Picture:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: mq.height * .02),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //pick picture from gallery button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: CircleBorder(),
                    fixedSize: Size(mq.width * .3, mq.height * .15),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    // Pick an image.
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      log(
                        'Image Path : ${image.path} -- MimeType : ${image.mimeType}',
                      );
                      setState(() {
                        _image = image.path;
                        APIs.me.avatar = ''; // Clear avatar if profile picture is selected
                      });

                      //for hiding bottom sheet
                      Navigator.pop(context);
                    }
                  },
                  child: Image.asset('images/add_image.png'),
                ),

                //take picture from camera button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: CircleBorder(),
                    fixedSize: Size(mq.width * .3, mq.height * .15),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    // Pick an image.
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (image != null) {
                      log('Image Path : ${image.path} ');
                      setState(() {
                        _image = image.path;
                        APIs.me.avatar = ''; // Clear avatar if profile picture is selected
                      });

                      //for hiding bottom sheet
                      Navigator.pop(context);
                    }
                  },
                  child: Image.asset('images/camera.png'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Helper method to get avatar color based on avatar ID
  Color _getAvatarColor(String avatarId) {
    return AvatarSelector.getAvatarColor(avatarId);
  }

  // Helper method to get avatar emoji based on avatar ID
  String _getAvatarEmoji(String avatarId) {
    return AvatarSelector.getAvatarEmoji(avatarId);
  }


}
