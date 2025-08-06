import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jarvis/providers/theme_provider.dart';
import 'package:jarvis/providers/user_data_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;  // Temporarily disabled
import 'package:avatar_glow/avatar_glow.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';

class AIAssistantScreen extends StatefulWidget {
  @override
  _AIAssistantScreenState createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _typingController;
  late AnimationController _micController;

  // Message data
  List<Message> messages = [
    Message(
      text:
          "Hello! I'm your personal life tracker assistant. How can I help you today?",
      sender: MessageSender.ai,
      timestamp: DateTime.now().subtract(Duration(minutes: 5)),
    ),
  ];

  // UI state
  final _inputCtrl = TextEditingController();
  final _scrollController = ScrollController();
  final _screenshotController = ScreenshotController();
  bool _isLoading = false;
  bool _isSpeechEnabled = false;
  bool _isListening = false;
  bool _showSuggestions = true;
  int _selectedMessageIndex = -1;

  // Speech recognition - temporarily disabled
  // stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;

  // Suggested prompts
  List<String> suggestedPrompts = [
    "How's my progress today?",
    "Give me a workout recommendation",
    "What should I eat for dinner?",
    "How can I improve my sleep?",
    "Help me manage my finances",
    "Analyze my spending habits"
  ];

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _typingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _micController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    // Initialize speech recognition - temporarily disabled
    // _initSpeech();
  }

  // Initialize speech recognition capability - temporarily disabled
  Future<void> _initSpeech() async {
    // _speechAvailable = await _speech.initialize(
    //   onStatus: (status) {
    //     if (status == 'done') {
    //       setState(() {
    //         _isListening = false;
    //       });
    //     }
    //   },
    //   onError: (error) {
    //     setState(() {
    //       _isListening = false;
    //     });
    //   },
    // );

    // if (_speechAvailable) {
    //   setState(() {
    //     _isSpeechEnabled = true;
    //   });
    // }
  }

  // Start listening for speech input - temporarily disabled
  void _startListening() async {
    HapticFeedback.mediumImpact();

    // Show a placeholder message for now
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Speech recognition temporarily disabled'),
        duration: Duration(seconds: 2),
      ),
    );

    // if (_speechAvailable) {
    //   setState(() {
    //     _isListening = true;
    //   });

    //   _micController.repeat(reverse: true);

    //   await _speech.listen(
    //     onResult: (result) {
    //       setState(() {
    //         _inputCtrl.text = result.recognizedWords;
    //       });
    //     },
    //     listenFor: Duration(seconds: 15),
    //   );
    // }
  }

  // Stop listening for speech input - temporarily disabled
  void _stopListening() {
    HapticFeedback.lightImpact();
    // _speech.stop();
    _micController.reset();
    setState(() {
      _isListening = false;
    });
  }

  @override
  void dispose() {
    _typingController.dispose();
    _micController.dispose();
    _inputCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Send a message
  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;

    // Haptic feedback for tactile response
    HapticFeedback.lightImpact();

    final userMessage = Message(
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    setState(() {
      messages.add(userMessage);
      _inputCtrl.clear();
      _isLoading = true;
      _showSuggestions = false;
    });

    // Scroll to bottom after adding message
    _scrollToBottom();

    // Simulate AI thinking and response
    _generateAIResponse(text);
  }

  // Generate AI response with simulated typing effect
  void _generateAIResponse(String userMessage) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 1200));

    // Generate response based on user message
    String response = _getResponseForQuery(userMessage);

    // Add the AI message
    final aiMessage = Message(
      text: response,
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
      hasInsight: _hasInsightForMessage(userMessage),
      xpReward: _getXpRewardForMessage(userMessage),
    );

    setState(() {
      messages.add(aiMessage);
      _isLoading = false;
    });

    // Scroll to bottom after adding response
    _scrollToBottom();

    // Award XP for engaging with the assistant
    if (aiMessage.xpReward > 0) {
      final userData = Provider.of<UserDataProvider>(context, listen: false);
      final didLevelUp = userData.addXP(aiMessage.xpReward);

      // Show XP notification
      Future.delayed(Duration(milliseconds: 500), () {
        _showXpRewardNotification(aiMessage.xpReward, didLevelUp);
      });

      // Add to activity log
      userData.addActivity(
          'ai', 'Received insight from AI Assistant', aiMessage.xpReward);
    }
  }

  // Dummy response generator based on user query
  String _getResponseForQuery(String query) {
    query = query.toLowerCase();

    if (query.contains('progress') || query.contains("how am i doing")) {
      return "You're making excellent progress! You've completed 75% of your daily tasks and maintained your water intake streak for 7 days. Your step count is slightly below target, so consider a short walk this evening. You've stayed under your calorie goal for 3 consecutive days - great job with nutrition!";
    } else if (query.contains('workout') || query.contains('exercise')) {
      return "Based on your recent activity patterns, I recommend a 30-minute HIIT session today. Your logs show you've been focusing on upper body, so consider targeting legs and core with exercises like squats, lunges, and planks. Remember to stay hydrated - you're currently 2 glasses behind your water goal.";
    } else if (query.contains('eat') ||
        query.contains('dinner') ||
        query.contains('food')) {
      return "Looking at your nutrition log, you're low on protein today. For dinner, I recommend grilled salmon with quinoa and steamed vegetables. This would add about 35g of protein and help you meet your daily macronutrient targets. Your calorie budget has 650 calories remaining for today.";
    } else if (query.contains('sleep') || query.contains('tired')) {
      return "Your sleep data shows an average of 6.2 hours this week, which is below your 7.5 hour goal. Try going to bed 30 minutes earlier tonight and consider reducing screen time in the evening. Your sleep quality may improve by maintaining your room temperature between 65-68°F and avoiding caffeine after 2 PM.";
    } else if (query.contains('finance') ||
        query.contains('money') ||
        query.contains('spending')) {
      return "I've analyzed your recent transactions. You're currently 12% under your monthly budget, which is excellent! Your restaurant spending has decreased by 20% compared to last month. You might want to review your subscription services - they\'ve increased by \$15 this month. Your savings rate is currently at 15%, on track to meet your goal.";
    } else if (query.contains('hello') ||
        query.contains('hi') ||
        query.contains('hey')) {
      return "Hello! I'm here to help you stay on track with your health, productivity, and financial goals. What would you like assistance with today?";
    } else {
      return "I understand you're interested in \"${query}\". While I don't have specific insights about this yet, I can help you track and analyze it. Would you like me to set up a new tracking category for this topic in your dashboard?";
    }
  }

  // Determine if a response should include an insight
  bool _hasInsightForMessage(String message) {
    message = message.toLowerCase();
    return message.contains('progress') ||
        message.contains('analyze') ||
        message.contains('insight') ||
        message.contains('recommend');
  }

  // Determine XP reward based on user interaction
  int _getXpRewardForMessage(String message) {
    if (message.length > 50) return 15; // Detailed questions get more XP
    if (message.contains('?')) return 10; // Questions get medium XP
    return 5; // Basic interactions get small XP
  }

  // Show XP reward notification
  void _showXpRewardNotification(int xpAmount, bool didLevelUp) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.star, color: Colors.amber),
            SizedBox(width: 8),
            Text(
              didLevelUp
                  ? "Level Up! +$xpAmount XP"
                  : "+$xpAmount XP for engaging with your assistant",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: 70.0,
          left: 20.0,
          right: 20.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: didLevelUp ? Colors.purple : Colors.green,
        duration: Duration(seconds: didLevelUp ? 4 : 2),
      ),
    );
  }

  // Scroll to bottom of chat
  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Use a suggestion as input
  void _useSuggestion(String suggestion) {
    setState(() {
      _inputCtrl.text = suggestion;
    });
    _send();
  }

  // Share a message
  Future<void> _shareMessage(Message message) async {
    try {
      // Take screenshot of the message
      final image = await _screenshotController.captureFromWidget(
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade300, Colors.purple.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Life Tracker AI Assistant",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Divider(color: Colors.white30),
              Text(
                message.text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/shared_message.png';
      final file = File(imagePath);

      await file.writeAsBytes(image);

      await Share.shareFiles([imagePath],
          text: 'Check out this insight from my Life Tracker app!');
    } catch (e) {
      // Fallback to text sharing if image sharing fails
      await Share.share(message.text, subject: 'Life Tracker AI Assistant');
    }
  }

  // Copy message text to clipboard
  void _copyMessageText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Message copied to clipboard"),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: 70.0,
          left: 20.0,
          right: 20.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Show message actions menu
  void _showMessageActions(Message message, int index) {
    setState(() {
      _selectedMessageIndex = index;
    });

    // Hide menu after short delay if no action taken
    Future.delayed(Duration(seconds: 5), () {
      if (mounted && _selectedMessageIndex == index) {
        setState(() {
          _selectedMessageIndex = -1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final accentColor = themeProvider.accentColor;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology,
                color: Colors.purple,
                size: 20,
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              _showAssistantInfoDialog(context, isDark);
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'clear') {
                setState(() {
                  messages = [
                    Message(
                      text:
                          "Hello! I'm your personal life tracker assistant. How can I help you today?",
                      sender: MessageSender.ai,
                      timestamp: DateTime.now(),
                    ),
                  ];
                });
              } else if (value == 'save') {
                // Save conversation logic
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Clear chat'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.save_alt, size: 20),
                    SizedBox(width: 8),
                    Text('Save conversation'),
                  ],
                ),
              ),
            ],
          ),
        ],
        elevation: 0,
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
      ),
      body: Column(
        children: [
          // Chat messages area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        isDark ? Colors.black12 : Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  itemCount: messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (ctx, i) {
                    if (i >= messages.length) {
                      // Show typing indicator as the last item when loading
                      return _buildTypingIndicator(isDark);
                    }

                    return AnimationConfiguration.staggeredList(
                      position: i,
                      duration: Duration(milliseconds: 400),
                      child: SlideAnimation(
                        horizontalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _buildMessageItem(
                              messages[i], i, isDark, accentColor),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Suggestions area (collapsible)
          if (_showSuggestions && !_isLoading)
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: 60,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: suggestedPrompts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                    child: OutlinedButton(
                      onPressed: () => _useSuggestion(suggestedPrompts[index]),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isDark
                            ? Colors.grey[800]
                            : accentColor.withOpacity(0.05),
                        side: BorderSide(
                          color: isDark
                              ? Colors.grey[700]!
                              : accentColor.withOpacity(0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      ),
                      child: Text(
                        suggestedPrompts[index],
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : accentColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),

          // Message input area
          Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Voice input button
                if (_isSpeechEnabled)
                  GestureDetector(
                    onTap: _isListening ? _stopListening : _startListening,
                    child: AvatarGlow(
                      animate: _isListening,
                      glowColor: Colors.blue,
                      endRadius: 25.0,
                      duration: Duration(milliseconds: 2000),
                      repeat: true,
                      showTwoGlows: true,
                      repeatPauseDuration: Duration(milliseconds: 100),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isListening
                              ? Colors.blue
                              : (isDark ? Colors.grey[800] : Colors.grey[200]),
                        ),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.grey[700]),
                        ),
                      ),
                    ),
                  ),

                // Text input field
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    decoration: InputDecoration(
                      hintText:
                          _isListening ? 'Listening...' : 'Ask me anything…',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (value) {
                      // Show suggestions when input is empty
                      if (value.isEmpty && !_showSuggestions) {
                        setState(() {
                          _showSuggestions = true;
                        });
                      } else if (value.isNotEmpty && _showSuggestions) {
                        setState(() {
                          _showSuggestions = false;
                        });
                      }
                    },
                    onSubmitted: (_) => _send(),
                  ),
                ),

                // Send button
                GestureDetector(
                  onTap: _send,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _inputCtrl.text.isEmpty
                          ? (isDark ? Colors.grey[700] : Colors.grey[300])
                          : accentColor,
                    ),
                    child: Icon(
                      Icons.send,
                      color: _inputCtrl.text.isEmpty
                          ? (isDark ? Colors.white54 : Colors.grey[500])
                          : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build message bubble
  Widget _buildMessageItem(
      Message message, int index, bool isDark, Color accentColor) {
    final isAI = message.sender == MessageSender.ai;
    final showActions = _selectedMessageIndex == index;

    return GestureDetector(
      onLongPress: () {
        // Show message actions on long press
        _showMessageActions(message, index);
        HapticFeedback.mediumImpact();
      },
      onTap: () {
        // Hide message actions if tapped elsewhere
        if (_selectedMessageIndex != -1) {
          setState(() {
            _selectedMessageIndex = -1;
          });
        }
      },
      child: Align(
        alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment:
                isAI ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              // Message bubble
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isAI
                      ? (isDark ? Colors.purple[900] : Colors.purple[50])
                      : (isDark ? Colors.grey[800] : Colors.green[50]),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isAI ? 0 : 20),
                    topRight: Radius.circular(isAI ? 20 : 0),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black12
                          : Colors.grey.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isAI && message.hasInsight)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color:
                              isDark ? Colors.purple[700] : Colors.purple[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.psychology,
                              size: 14,
                              color:
                                  isDark ? Colors.white70 : Colors.purple[800],
                            ),
                            SizedBox(width: 4),
                            Text(
                              'AI Insight',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.purple[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      message.text,
                      style: TextStyle(
                        color: isAI
                            ? (isDark ? Colors.white : Colors.purple[800])
                            : (isDark ? Colors.white : Colors.green[800]),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              // Timestamp
              Padding(
                padding: EdgeInsets.only(top: 4, left: 8, right: 8),
                child: Text(
                  _formatTimestamp(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),

              // XP reward indicator for AI messages
              if (isAI && message.xpReward > 0)
                Container(
                  margin: EdgeInsets.only(top: 4, left: 8),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 12,
                        color: Colors.amber,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '+${message.xpReward} XP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                ),

              // Message actions
              if (showActions)
                Card(
                  elevation: 4,
                  margin: EdgeInsets.only(top: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.copy, size: 20),
                        onPressed: () {
                          _copyMessageText(message.text);
                          setState(() {
                            _selectedMessageIndex = -1;
                          });
                        },
                        tooltip: 'Copy',
                      ),
                      IconButton(
                        icon: Icon(Icons.share, size: 20),
                        onPressed: () {
                          _shareMessage(message);
                          setState(() {
                            _selectedMessageIndex = -1;
                          });
                        },
                        tooltip: 'Share',
                      ),
                      if (isAI)
                        IconButton(
                          icon: Icon(Icons.bookmark_border, size: 20),
                          onPressed: () {
                            // Save to favorites logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Saved to favorites"),
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.only(
                                    bottom: 70, left: 20, right: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                            setState(() {
                              _selectedMessageIndex = -1;
                            });
                          },
                          tooltip: 'Save',
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Build typing indicator for AI
  Widget _buildTypingIndicator(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.purple[900] : Colors.purple[50],
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpinKitThreeBounce(
              color: isDark ? Colors.white70 : Colors.purple[700],
              size: 16,
            ),
            SizedBox(width: 8),
            Text(
              'Thinking...',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.purple[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Format message timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }

  // Show assistant info dialog
  void _showAssistantInfoDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.psychology, color: Colors.purple),
            ),
            SizedBox(width: 16),
            Text("About AI Assistant"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.insights, color: Colors.blue),
              title: Text("Personalized Insights"),
              subtitle: Text(
                  "Get custom health and productivity insights based on your data"),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: Icon(Icons.trending_up, color: Colors.green),
              title: Text("Progress Tracking"),
              subtitle: Text("Ask about your progress on any of your goals"),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: Icon(Icons.tips_and_updates, color: Colors.orange),
              title: Text("Smart Recommendations"),
              subtitle:
                  Text("Receive tailored suggestions to improve your habits"),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: Icon(Icons.star, color: Colors.amber),
              title: Text("Earn XP"),
              subtitle:
                  Text("Earn experience points by engaging with the assistant"),
              contentPadding: EdgeInsets.zero,
            ),
            Divider(),
            Text(
              "Your data is processed securely and never shared with third parties.",
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("GOT IT"),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

// Message data class
class Message {
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final bool hasInsight;
  final int xpReward;

  Message({
    required this.text,
    required this.sender,
    required this.timestamp,
    this.hasInsight = false,
    this.xpReward = 0,
  });
}

// Message sender enum
enum MessageSender {
  user,
  ai,
}
