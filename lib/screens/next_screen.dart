import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/background.dart';
import 'SpeakScreen.dart'; // <-- Import SpeakScreen

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

class _NextScreenState extends State<NextScreen> with TickerProviderStateMixin {
  final List<Message> _messages = [
    Message(
      text:
          "Hello! I'm here to listen and support you. Feel free to share what's on your mind today.",
      isUser: false,
    ),
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<AnimationController> _animControllers = [];
  final List<Animation<Offset>> _slideAnimations = [];

  @override
  void initState() {
    super.initState();
    _addInitialAnimation();
  }

  void _addInitialAnimation() {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    final animation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    _animControllers.add(controller);
    _slideAnimations.add(animation);
    controller.forward();
  }

  @override
  void dispose() {
    for (var anim in _animControllers) {
      anim.dispose();
    }
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(Message(text: text.trim(), isUser: true));
    });
    _controller.clear();
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _messages.add(Message(text: "Thanks for sharing!", isUser: false));
        final controller = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 600),
        );
        final animation = Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

        _animControllers.add(controller);
        _slideAnimations.add(animation);
        controller.forward();
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
            top: 22,
            right: 0,
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
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 25,
              ),
            ),
          ),

          // Info Rectangle
          Positioned(
            top: screenHeight * 0.11,
            left: screenWidth / 2 - 175,
            child: Container(
              width: 350,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFA57DF2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 3,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Mental Health Support Chat",
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "AI-powered emotional support and guidance",
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _messages.clear();
                        _messages.add(Message(
                          text:
                              "Hello! I'm here to listen and support you. Feel free to share what's on your mind today.",
                          isUser: false,
                        ));
                        _animControllers.clear();
                        _slideAnimations.clear();
                        _addInitialAnimation();
                      });
                      _scrollToBottom();
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      color: Colors.transparent,
                      child: Image.asset(
                        'assets/images/re.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Glass Container
          Positioned(
            top: screenHeight * 0.18,
            left: 20,
            right: 20,
            bottom: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
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
                  padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ListView.builder(
                              controller: _scrollController,
                              itemCount: _messages.length,
                              padding: const EdgeInsets.only(bottom: 70),
                              itemBuilder: (context, index) {
                                final msg = _messages[index];

                                // fallback if missing
                                if (_animControllers.length <= index) {
                                  _addInitialAnimation();
                                }

                                final anim = _animControllers[index];
                                final slide = _slideAnimations[index];

                                final bubble = Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.all(12),
                                  constraints: BoxConstraints(
                                    maxWidth: screenWidth * 0.7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: msg.isUser
                                        ? Colors.blue.withOpacity(0.3)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: msg.isUser
                                          ? Colors.blueAccent
                                          : const Color(0xFF8C62DC),
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
                                );

                                return FadeTransition(
                                  opacity:
                                      anim.drive(Tween(begin: 0.0, end: 1.0)),
                                  child: msg.isUser
                                      ? Align(
                                          alignment: Alignment.centerRight,
                                          child: bubble,
                                        )
                                      : SlideTransition(
                                          position: slide,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0, top: 4),
                                                  child: ClipOval(
                                                    child: Image.asset(
                                                      'assets/images/logo.png',
                                                      width: 36,
                                                      height: 36,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                bubble,
                                              ],
                                            ),
                                          ),
                                        ),
                                );
                              },
                            ),

                            // Input + Send
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _controller,
                                        style: const TextStyle(
                                            color: Colors.black),
                                        decoration: InputDecoration(
                                          hintText: "Type your message...",
                                          hintStyle: TextStyle(
                                            color: Colors.black.withOpacity(0.5),
                                          ),
                                          filled: true,
                                          fillColor:
                                              Colors.white.withOpacity(0.2),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            borderSide: BorderSide(
                                              color:
                                                  Colors.white.withOpacity(0.3),
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () =>
                                          _sendMessage(_controller.text),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color.fromARGB(
                                                  255, 0, 0, 0)
                                              .withOpacity(0.8),
                                        ),
                                        child: const Icon(
                                          Icons.send,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Speak Button
          Positioned(
            bottom: 125,
            left: 40,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SpeakScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.mic, color: Colors.white),
              label: const Text(
                "Speak",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8C62DC),
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: BorderSide(color: Colors.white.withOpacity(0.8)),
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
