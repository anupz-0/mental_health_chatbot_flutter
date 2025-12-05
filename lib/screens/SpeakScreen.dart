import 'dart:async';
import 'dart:convert' as conv;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:web_socket_channel/io.dart';

import '../components/background.dart';

class Msg {
  final String text;
  final bool isUser;

  Msg({required this.text, required this.isUser});
}

class SpeakScreen extends StatefulWidget {
  const SpeakScreen({super.key});

  @override
  State<SpeakScreen> createState() => _SpeakScreenState();
}

class _SpeakScreenState extends State<SpeakScreen>
    with TickerProviderStateMixin {
  // Chat state
  final List<Msg> _messages = [
    Msg(
      text:
          "Hello! I'm here to listen and support you. Feel free to share what's on your mind today.",
      isUser: false,
    ),
  ];
  final ScrollController _scrollController = ScrollController();
  final List<AnimationController> _animControllers = [];
  final List<Animation<Offset>> _slideAnimations = [];

  // Audio + WS state
  bool _isRecording = false;
  bool _permissionGranted = false;
  late FlutterSoundRecorder _recorder;

  IOWebSocketChannel? _wsChannel;
  StreamSubscription? _wsSub;
  StreamController<Uint8List>? _audioController;

  // Accumulate all ASR text for one utterance
  String _currentUtterance = '';

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initializeRecorder();
    _addInitialAnimation();
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    for (var anim in _animControllers) {
      anim.dispose();
    }
    _scrollController.dispose();
    _wsSub?.cancel();
    _wsChannel?.sink.close();
    _audioController?.close();
    super.dispose();
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

  Future<void> _requestPermission() async {
    if (!_permissionGranted) {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        _permissionGranted = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required!')),
        );
      }
    }
  }

  void _sendUserMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(Msg(text: text.trim(), isUser: true));
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
  }

  void _sendBotReply(String text) {
    setState(() {
      _messages.add(Msg(text: text, isUser: false));
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
  }

  Future<void> _connectWs() async {
    if (_wsChannel != null) return;
    // TODO: replace with your server IP / host
    const url = 'ws://192.168.1.64:8000/ws/asr';
    _wsChannel = IOWebSocketChannel.connect(Uri.parse(url));

    _wsSub = _wsChannel!.stream.listen(
      (event) {
        try {
          final data = conv.jsonDecode(event as String);
          _handleAsrMessage(data as Map<String, dynamic>);
        } catch (_) {
          // ignore malformed
        }
      },
      onError: (_) {},
      onDone: () {
        _wsChannel = null;
      },
    );
  }

  // Accumulate ASR text; send as one user bubble after recording stops
  void _handleAsrMessage(Map<String, dynamic> data) {
    final type = data['type'];
    final text = (data['text'] ?? '').toString();

    if (type == 'partial') {
      // ignore partials (could show typing indicator here)
      return;
    } else if (type == 'final') {
      if (text.isEmpty) return;
      if (_currentUtterance.isEmpty) {
        _currentUtterance = text;
      } else {
        _currentUtterance = '$_currentUtterance $text';
      }
    } else if (type == 'info') {
      final msg = (data['msg'] ?? '').toString();
      if (msg.isNotEmpty) {
        _sendBotReply('[Info] $msg');
      }
    }
  }

  Future<void> _startStreaming() async {
    await _connectWs();

    _audioController = StreamController<Uint8List>();

    // Forward chunks from recorder stream to WebSocket
    _audioController!.stream.listen((Uint8List bytes) {
      _wsChannel?.sink.add(bytes);
    });

    await _recorder.startRecorder(
      toStream: _audioController!.sink,
      codec: Codec.pcm16, // from flutter_sound, not dart:convert
      numChannels: 1,
      sampleRate: 16000,
    );
  }

  Future<void> _stopStreaming() async {
    await _recorder.stopRecorder();
    await _audioController?.close();
    _audioController = null;
    _wsChannel?.sink.add(conv.jsonEncode({'cmd': 'flush'}));
  }

  Future<void> _handleSpeakPress() async {
  await _requestPermission();
  if (!_permissionGranted) return;

  if (!_isRecording) {
    // starting a new utterance
    _currentUtterance = '';
    await _startStreaming();
    setState(() => _isRecording = true);
    _sendUserMessage('');
  } else {
    // stopping: flush on server, then show the accumulated text as one bubble
    await _stopStreaming();
    setState(() => _isRecording = false);
     _sendUserMessage('');

    // small delay to let all "final" chunks arrive
    Future.delayed(const Duration(milliseconds: 300), () {
      final utterance = _currentUtterance.trim();
      if (utterance.isNotEmpty) {
        // user bubble with full utterance
        _sendUserMessage(utterance);
        // bot acknowledges
        _sendBotReply('Voice received');
      }
      _currentUtterance = '';
    });
  }
}


  void _handleRefresh() {
    setState(() {
      _messages.clear();
      _animControllers.clear();
      _slideAnimations.clear();
      _messages.add(
        Msg(
          text:
              "Hello! I'm here to listen and support you. Feel free to share what's on your mind today.",
          isUser: false,
        ),
      );
      _addInitialAnimation();
    });
    _scrollToBottom();
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
              child:
                  const Icon(Icons.arrow_back, color: Colors.black, size: 25),
            ),
          ),
          // Glass container
          Positioned(
            top: screenHeight * 0.18,
            left: 20,
            right: 20,
            bottom: 80,
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
                        color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                  child: Stack(
                    children: [
                      // Messages
                      ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length,
                        padding: const EdgeInsets.only(
                            top: 40, bottom: 20, left: 15, right: 15),
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final anim = _animControllers[index];
                          final slide = _slideAnimations[index];
                          final bubble = Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            constraints: BoxConstraints(
                                maxWidth: screenWidth * 0.7),
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
                                            padding: const EdgeInsets.only(
                                                right: 8, top: 4),
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
                      // Refresh button inside glass container, top-right
                      Positioned(
                        top: 5,
                        right: 10,
                        child: GestureDetector(
                          onTap: _handleRefresh,
                          child: Container(
                            width: 24,
                            height: 24,
                            color: Colors.transparent,
                            child: Image.asset(
                              'assets/images/re.png',
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Speak button at center bottom
          Positioned(
            bottom: 90,
            left: screenWidth / 2 - 30,
            child: GestureDetector(
              onTap: _handleSpeakPress,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? Colors.red : Colors.transparent,
                  border: Border.all(
                      color: Colors.white.withOpacity(0.5), width: 3),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/sp.png',
                    width: 35,
                    height: 35,
                  ),
                ),
              ),
            ),
          ),
          // Emergency text
          Positioned(
            bottom: 5,
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
