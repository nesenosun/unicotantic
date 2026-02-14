import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'services/api_service.dart';
import 'services/sync_service.dart';
import 'models/message.dart';
import '../../core/voice/widgets/voice_bottom_bar.dart';

class UnicaChatPage extends StatefulWidget {
  const UnicaChatPage({super.key});

  @override
  State<UnicaChatPage> createState() => _UnicaChatPageState();
}

class _UnicaChatPageState extends State<UnicaChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  final ApiService _apiService = ApiService();
  
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isLoading = false;
  bool _isMoreLoading = false;
  bool _isListening = false;
  int? _speakingIndex; 
  int _currentOffset = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadHistory(initial: true);
    SyncService().syncAll().then((_) {
      if (mounted) _loadHistory(initial: true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && _hasMore && !_isMoreLoading) {
      _loadHistory();
    }
  }

  void _loadHistory({bool initial = false}) async {
    if (initial) {
      setState(() {
        _isLoading = true;
        _currentOffset = 0;
        _messages.clear();
        _hasMore = true;
      });
    } else {
      setState(() => _isMoreLoading = true);
    }

    final int limit = initial ? 5 : 10;
    final history = await _apiService.getHistory(limit: limit, offset: _currentOffset);
    
    if (mounted) {
      setState(() {
        if (history.length < limit) _hasMore = false;
        _messages.insertAll(0, history);
        _currentOffset += history.length;
        _isLoading = false;
        _isMoreLoading = false;
      });
      if (initial) _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _initTts() async {
    await _flutterTts.setLanguage("tr-TR");
    await _flutterTts.setPitch(1.33); // Daha canlı bir ton
    if (Platform.isMacOS) {
      await _flutterTts.setSpeechRate(0.35); // macOS için çok daha yavaş
    } else {
      await _flutterTts.setSpeechRate(1.05); // Mobil için normal hız
    }

    _flutterTts.setCompletionHandler(() {
      setState(() => _speakingIndex = null);
    });

    _flutterTts.setCancelHandler(() {
      setState(() => _speakingIndex = null);
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() => _speakingIndex = null);
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (err) => setState(() => _isListening = false),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _controller.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _speak(String text, int index) async {
    if (_speakingIndex == index) {
      await _flutterTts.stop();
      setState(() => _speakingIndex = null);
    } else {
      setState(() => _speakingIndex = index);
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    }
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userText = _controller.text.trim();
    setState(() {
      _messages.add(Message(
        text: userText,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final result = await _apiService.sendMessage(userText);
      setState(() {
        _messages.add(Message(
          text: result['response'] ?? '',
          isUser: false,
          timestamp: DateTime.now(),
          thought: result['thought'],
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(Message(
          text: "Hata: Bağlantı kurulamadı.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.purpleAccent, Colors.cyanAccent],
                ),
              ),
              child: const Icon(Iconsax.flash_1, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Unica AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      bottomNavigationBar: VoiceBottomBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isMoreLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == 0 && _isMoreLoading) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.purpleAccent),
                  ));
                }
                
                final msgIndex = _isMoreLoading ? index - 1 : index;
                final msg = _messages[msgIndex];
                final isUser = msg.isUser;
                final timeStr = "${msg.timestamp.hour.toString().padLeft(2,'0')}:${msg.timestamp.minute.toString().padLeft(2,'0')}";

                return Column(
                  children: [
                    Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 2, left: 4, right: 4),
                        child: Text(
                          timeStr,
                          style: TextStyle(color: Colors.grey[600], fontSize: 10),
                        ),
                      ),
                    ),
                    Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isUser) ...[
                            IconButton(
                              onPressed: () => _speak(msg.text, msgIndex),
                              icon: Icon(
                                _speakingIndex == msgIndex ? Iconsax.stop : Iconsax.play,
                                color: _speakingIndex == msgIndex ? Colors.redAccent : Colors.purpleAccent,
                                size: 18,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isUser ? Colors.cyan.withOpacity(0.2) : Colors.purple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15).copyWith(
                                  bottomRight: isUser ? Radius.zero : null,
                                  bottomLeft: !isUser ? Radius.zero : null,
                                ),
                                border: Border.all(
                                  color: isUser ? Colors.cyanAccent.withOpacity(0.5) : Colors.purpleAccent.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                msg.text,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (_isLoading && _messages.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            ),
          _buildInputSection(),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _listen,
            icon: Icon(
              _isListening ? Iconsax.microphone_slash : Iconsax.microphone_2,
              color: _isListening ? Colors.red : Colors.cyanAccent,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Unica\'ya bir şeyler sor...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Iconsax.send_1, color: Colors.cyanAccent),
          ),
        ],
      ),
    );
  }
}
