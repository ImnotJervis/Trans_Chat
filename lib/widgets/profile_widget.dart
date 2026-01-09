import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ProfileWidget({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(userData['profileImage'] ?? ''),
          radius: 50,
        ),
        const SizedBox(height: 10),
        Text(
          userData['name'].isEmpty ? userData['email'] : userData['name'],
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(userData['statusMessage'] ?? '상태 메시지가 없습니다.'),
      ],
    );
  }
}
