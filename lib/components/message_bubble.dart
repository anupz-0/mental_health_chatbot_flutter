import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    bool isUser = message.sender == Sender.user;

    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        if (isUser)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Image.asset(
              'assets/images/user.png',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
          ),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFF9C91FF)),
            ),
            child: Text(
              message.text,
              style: GoogleFonts.nunito(
                color: Colors.black,
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
