import 'package:flutter/material.dart';
import '../../api/apis.dart';
import '../../helper/dialogs.dart';
import '../../main.dart';
import '../../widgets/avatar_selector.dart';
import '../home_screen.dart';

/// Profile setup screen shown after user registration
/// Allows users to set their name, bio, and choose an avatar
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  String _selectedAvatar = '';

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Your Profile'),
        automaticallyImplyLeading: false, // Prevent going back
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(mq.width * .05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: mq.height * .03),

              // Title
              Text(
                'Welcome to We Chat!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: mq.height * .01),
              Text(
                'Set up your profile',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: mq.height * .04),

              // Avatar selection section
              Text(
                'Choose Your Avatar:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: mq.height * .02),
              AvatarSelector(
                onAvatarSelected: (avatarId) {
                  setState(() {
                    _selectedAvatar = avatarId;
                  });
                },
                currentAvatar: _selectedAvatar,
              ),
              SizedBox(height: mq.height * .04),

              // Name input field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.blue),
                  hintText: 'Enter your name',
                  label: Text('Name'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Name is required';
                  }
                  if (val.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: mq.height * .03),

              // Bio input field
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.info_outline, color: Colors.blue),
                  hintText: 'Tell about yourself in Bio',
                  label: Text('Bio'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
              SizedBox(height: mq.height * .04),

              // Continue button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: StadiumBorder(),
                  minimumSize: Size(mq.width * .7, mq.height * .06),
                ),
                onPressed: _saveProfile,
                icon: Icon(Icons.check_circle, size: 28, color: Colors.white),
                label: Text(
                  'Continue',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Save profile information and navigate to home screen
  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // Show loading dialog
      Dialogs.showProgressBar(context, 'Setting up your profile...');

      try {
        // Update user information
        APIs.me.name = _nameController.text.trim();
        APIs.me.about = _bioController.text.trim().isEmpty
            ? "Hey, I'm using We Chat!"
            : _bioController.text.trim();
        APIs.me.avatar = _selectedAvatar;

        // Create user in Firestore with updated info
        await APIs.createUser();

        // Get self info to ensure everything is synced
        await APIs.getSelfInfo();

        // Hide loading dialog
        Navigator.pop(context);

        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );

        Dialogs.showSnackBar(context, 'Profile setup complete!');
      } catch (e) {
        // Hide loading dialog
        Navigator.pop(context);
        
        // Show error
        Dialogs.showSnackBar(
          context,
          'Error setting up profile: ${e.toString()}',
        );
      }
    }
  }
}


