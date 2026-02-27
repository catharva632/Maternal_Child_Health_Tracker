import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../controllers/settings_controller.dart';


class LlmScreen extends StatefulWidget {
  const LlmScreen({super.key});

  @override
  State<LlmScreen> createState() => _LlmScreenState();
}

class _LlmScreenState extends State<LlmScreen> {
  final String serverUrl =
      "https://rohan2436-maternal-and-child-health-tracker.hf.space/chat";

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> messages = [];
  bool isLoading = false;
  bool isTyping = false;
  bool showScrollToBottom = false;

  String typingText = "";
  
  // Language Support
  String selectedLanguage = "English";
  final List<String> languages = ["English", "Hindi", "Marathi"];

  // Voice System
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  String _timeNow() => DateFormat('hh:mm a').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    selectedLanguage = SettingsController().language.value;
    _initSpeech();
    /// 🔹 Listen to scroll position
    _scrollController.addListener(() {
      final atBottom = _scrollController.offset >=
          _scrollController.position.maxScrollExtent - 50;

      if (showScrollToBottom == atBottom) {
        setState(() {
          showScrollToBottom = !atBottom;
        });
      }
    });
  }

  void _initSpeech() async {
    try {
      await _speech.initialize(
        onStatus: (status) => debugPrint('Speech status: $status'),
        onError: (error) => debugPrint('Speech error: $error'),
      );
    } catch (e) {
      debugPrint("Speech init error: $e");
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
            });
            // Auto-send if final
            if (result.finalResult) {
              setState(() => _isListening = false);
              sendMessage(result.recognizedWords);
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  /// 🔹 Ultra smooth auto-scroll
  void _scrollToBottom({bool force = false}) {
    if (!_scrollController.hasClients) return;

    if (!showScrollToBottom || force) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic,
        );
      });
    }
  }

  /// 🔹 Typing animation (char by char)
  Future<void> _typeBotMessage(String fullText) async {
    isTyping = true;
    typingText = "";

    setState(() {
      messages.add({
        "text": "",
        "isUser": false,
        "time": _timeNow(),
      });
    });

    _scrollToBottom(force: true);

    for (int i = 0; i < fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 25));
      typingText += fullText[i];

      setState(() {
        messages.last["text"] = typingText;
      });

      _scrollToBottom();
    }

    isTyping = false;
    _scrollToBottom(force: true);
  }

  /// 🔹 Send message
  Future<void> sendMessage(String text) async {
    setState(() {
      messages.add({
        "text": text,
        "isUser": true,
        "time": _timeNow(),
      });
      isLoading = true;
    });

    _controller.clear();
    _scrollToBottom(force: true);

    Future<String?> _tryFormat(String url, Map<String, dynamic> body) async {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        return response.body;
      }
      debugPrint("Payload failed (${body.keys.first}): ${response.statusCode}");
      return null;
    }

    try {
      String? responseBody;
      
      // Pass language to the payload
      final Map<String, dynamic> baseBody = {
        "message": text,
        "language": selectedLanguage,
      };

      responseBody = await _tryFormat(serverUrl, baseBody);
      responseBody ??= await _tryFormat(serverUrl, {"inputs": text, "language": selectedLanguage});
      responseBody ??= await _tryFormat(serverUrl, {"query": text, "language": selectedLanguage});
      responseBody ??= await _tryFormat(serverUrl, {"question": text, "language": selectedLanguage});

      if (responseBody != null) {
        debugPrint("Chatbot Response: $responseBody");
        final data = jsonDecode(responseBody);
        String? reply;

        // 1. Handle List response (Hugging Face Inference API style)
        if (data is List && data.isNotEmpty) {
          final first = data[0];
          if (first is Map) {
            reply = first["generated_text"] ?? first["text"];
          } else if (first is String) {
            reply = first;
          }
        } 
        // 2. Handle Map response (Standard API style)
        else if (data is Map) {
          reply = data["expert_answer"] ??
                  data["answer"] ?? 
                  data["response"] ?? 
                  data["reply"] ?? 
                  data["generated_text"] ?? 
                  data["text"];
          
          // 3. Handle Gradio style {"data": ["..."]}
          if (reply == null && data["data"] != null && data["data"] is List && data["data"].isNotEmpty) {
            final dFirst = data["data"][0];
            if (dFirst is String) {
              reply = dFirst;
            } else if (dFirst is Map) {
              reply = dFirst["text"] ?? dFirst["generated_text"];
            }
          }
        }

        reply ??= "Error: Unexpected response format from server. Body: ${responseBody.length > 100 ? responseBody.substring(0, 100) + '...' : responseBody}";
        
        await _typeBotMessage(reply);
      } else {
        await _typeBotMessage("The server is currently unavailable (Error 500). This usually means the AI model is still loading on Hugging Face.");
      }
    } catch (e) {
      debugPrint("Chatbot Error: $e");
      await _typeBotMessage("Connection failed. Please check your internet.");
    } finally {
      setState(() => isLoading = false);
      _scrollToBottom(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFFF48FB1), // Pink Theme
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(SettingsController().tr("Maternal Health Tracker"), 
              style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            Text(SettingsController().tr("AI Assistant"),
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          // Language Dropdown
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: DropdownButton<String>(
              value: selectedLanguage,
              dropdownColor: const Color(0xFFF48FB1),
              underline: const SizedBox(),
              icon: const Icon(Icons.language, color: Colors.white),
              items: languages.map((String lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Text(lang, style: const TextStyle(color: Colors.white, fontSize: 13)),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() => selectedLanguage = newValue);
                  SettingsController().setLanguage(newValue);
                }
              },
            ),
          ),
        ],
      ),

      /// 🔥 WATERMARK + CHAT
      body: Stack(
        children: [

          Column(
            children: [
              /// 🔹 CHAT LIST
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isUser = msg["isUser"];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: isUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (!isUser)
                              Padding(
                                padding: const EdgeInsets.only(right: 8, top: 4),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFFFCE4EC),
                                  child: Icon(Icons.smart_toy, color: const Color(0xFFF48FB1), size: 20),
                                ),
                              ),
                            Column(
                              crossAxisAlignment: isUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width * 0.72,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isUser
                                          ? const Color(0xFFF48FB1)
                                          : const Color(0xFFFCE4EC), // Soft Pink for Bot
                                      borderRadius:
                                          BorderRadius.circular(16),
                                    ),
                                    child: SelectableText(
                                      msg["text"],
                                      style: TextStyle(
                                          color: isUser ? Colors.white : Colors.black87,
                                          fontSize: 15),
                                    ),
                                  ),
                                  if (!isUser)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: IconButton(
                                        icon: const Icon(Icons.copy, size: 16, color: Colors.grey),
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: msg["text"]));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(SettingsController().tr("Copied to clipboard"))),
                                          );
                                        },
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 6, right: 6, top: 4),
                                    child: Text(
                                      msg["time"],
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              if (isLoading || isTyping)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    SettingsController().tr("Assistant is typing..."),
                    style: const TextStyle(color: Color(0xFFF48FB1), fontSize: 12),
                  ),
                ),

              /// 🔹 INPUT BAR
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style:
                            const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: SettingsController().tr("Type a message..."),
                          hintStyle:
                              const TextStyle(color: Colors.grey),
                          prefixIcon: IconButton(
                            icon: Icon(_isListening ? Icons.mic : Icons.mic_none, 
                              color: _isListening ? Colors.red : Colors.grey),
                            onPressed: _listen,
                          ),
                          filled: true,
                          fillColor:
                              const Color(0xFFF5F5F5), // Light Grey Fill
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(24),
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(24),
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(24),
                            borderSide: const BorderSide(color: Color(0xFFF48FB1)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      backgroundColor:
                          const Color(0xFFF48FB1),
                      child: IconButton(
                        icon: const Icon(Icons.send,
                            color: Colors.white),
                        onPressed: isTyping
                            ? null
                            : () {
                                final text =
                                    _controller.text.trim();
                                if (text.isNotEmpty) {
                                  sendMessage(text);
                                }
                              },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),

          /// 🔹 SCROLL TO BOTTOM FAB
          if (showScrollToBottom)
            Positioned(
              right: 16,
              bottom: 90,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFFF48FB1),
                onPressed: () => _scrollToBottom(force: true),
                child: const Icon(Icons.arrow_downward, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
