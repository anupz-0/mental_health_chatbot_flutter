import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/background.dart';

class Message {
  final String text;
  final bool isUser;
  Message({required this.text, required this.isUser});
}

class NextScreen extends StatefulWidget {
  const NextScreen({super.key});

  @override
  State<NextScreen> createState() => _NextScreenState();
}

class _NextScreenState extends State<NextScreen> {
  final List<Message> _messages = [
    Message(
      text:
          "Hello! I'm here to listen and support you. Feel free to share what's on your mind today.",
      isUser: false,
    ),
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(Message(text: text.trim(), isUser: true));
    });

    _controller.clear();
    _scrollToBottom();

    // Simulated bot replies
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _messages.add(Message(text: "Thanks for sharing!", isUser: false));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Background(),

          // Top logo
          Positioned(
            top: 40,
            right: 20,
            child: Image.asset(
              'assets/images/logo.png',
              width: 100,
              height: 100,
            ),
          ),

          // Back button
          Positioned(
            top: 50,
            left: 15,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Image.asset(
                'assets/images/back.png',
                width: 25,
                height: 25,
              ),
            ),
          ),

          // Glass container
          Positioned(
            top: screenHeight * 0.15,
            left: 20,
            right: 20,
            bottom: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.only(
                      top: 20, left: 15, right: 15, bottom: 80),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            return Align(
                              alignment: msg.isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.all(12),
                                constraints: BoxConstraints(
                                    maxWidth: screenWidth * 0.7),
                                decoration: BoxDecoration(
                                  color: msg.isUser
                                      ? Colors.blue.withOpacity(0.3)
                                      : Colors.purple.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: msg.isUser
                                        ? Colors.blueAccent
                                        : Colors.purpleAccent,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  msg.text,
                                  style: GoogleFonts.nunito(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Input row inside glass
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: "Type your message...",
                                hintStyle:
                                    TextStyle(color: Colors.black.withOpacity(0.5)),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => _sendMessage(_controller.text),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.purpleAccent.withOpacity(0.8),
                              ),
                              child: const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Speak Button
          Positioned(
            bottom: 40,
            left: 30,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.mic),
              label: const Text("Speak"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),

          // Emergency Text
          Positioned(
            bottom: 10,
            left: 20,
            right: 20,
            child: Text(
              "This is an AI assistant for emotional support. For crisis situations, please contact emergency services or a mental health professional.",
              style: GoogleFonts.nunito(fontSize: 10, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
