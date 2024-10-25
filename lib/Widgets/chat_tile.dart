import 'package:chat_app/models/user_profile.dart';
import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  final UserProfile userProfile;
  final Function onTap;

  const ChatTile({
    super.key,
    required this.userProfile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      shape:RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onTap: () {
        onTap();
      },
      dense: true,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(userProfile.pfpURL!),
      ),
      title: Text(userProfile.name!),
    );
  }
}
