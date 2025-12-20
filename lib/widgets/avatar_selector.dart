import 'package:flutter/material.dart';
import '../main.dart';

/// Widget for selecting avatars from predefined options
/// Displays a grid of emoji avatars that users can choose from
class AvatarSelector extends StatelessWidget {
  final Function(String) onAvatarSelected;
  final String currentAvatar;

  const AvatarSelector({
    super.key,
    required this.onAvatarSelected,
    this.currentAvatar = '',
  });

  // List of available avatars with their IDs and emojis
  static final List<Map<String, dynamic>> _avatars = [
    {'id': 'avatar1', 'emoji': '😀', 'name': 'Grinning'},
    {'id': 'avatar2', 'emoji': '😎', 'name': 'Cool'},
    {'id': 'avatar3', 'emoji': '🤩', 'name': 'Star-struck'},
    {'id': 'avatar4', 'emoji': '😊', 'name': 'Smiling'},
    {'id': 'avatar5', 'emoji': '🥳', 'name': 'Party'},
    {'id': 'avatar6', 'emoji': '🥱', 'name': 'Heart Eyes'},
    {'id': 'avatar7', 'emoji': '🤖', 'name': 'Hugging'},
    {'id': 'avatar8', 'emoji': '😇', 'name': 'Innocent'},
    {'id': 'avatar9', 'emoji': '🤠', 'name': 'Cowboy'},
    {'id': 'avatar10', 'emoji': '🥰', 'name': 'Smiling Face'},
    {'id': 'avatar11', 'emoji': '💟', 'name': 'Savoring'},
    {'id': 'avatar12', 'emoji': '🤓', 'name': 'Nerd'},
  ];

  // Get avatar color based on avatar ID
  static Color _getAvatarColor(String avatarId) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.lightBlueAccent,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.deepOrange,
      Colors.lightBlue,
    ];
    final index = avatarId.hashCode % colors.length;
    return colors[index.abs()];
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4 avatars per row
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: _avatars.length,
      itemBuilder: (context, index) {
        final avatar = _avatars[index];
        final isSelected = currentAvatar == avatar['id'];
        
        return GestureDetector(
          onTap: () => onAvatarSelected(avatar['id']),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getAvatarColor(avatar['id']),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                avatar['emoji'],
                style: TextStyle(fontSize: mq.width * .08),
              ),
            ),
          ),
        );
      },
    );
  }

  // Static method to get avatar emoji by ID (for use in other widgets)
  static String getAvatarEmoji(String avatarId) {
    final avatar = _avatars.firstWhere(
      (a) => a['id'] == avatarId,
      orElse: () => _avatars[0],
    );
    return avatar['emoji'];
  }

  // Static method to get avatar color by ID (for use in other widgets)
  static Color getAvatarColor(String avatarId) {
    return _getAvatarColor(avatarId);
  }
}


