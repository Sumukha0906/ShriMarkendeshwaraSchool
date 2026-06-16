import 'package:flutter/material.dart';

class InviteScreen extends StatelessWidget {
  final String token;
  const InviteScreen({super.key, required this.token});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Invite: $token')),
    );
  }
}