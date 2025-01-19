import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:groq_sdk/groq_sdk.dart';
import 'package:private_llm/llm/llama_service.dart';
import 'package:private_llm/llm/mistral_service.dart';
import 'package:private_llm/utils/border_gradient.dart';
import 'package:shared_preferences/shared_preferences.dart' as prefs;
import 'package:sidebarx/sidebarx.dart';
import 'package:window_manager/window_manager.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;

import '../component/side_navbar.dart';
import '../llm/prompts.dart';
import '../models/message.dart';
import '../llm/gemma_service.dart';
import '../services/platform_service.dart';
import '../services/stream_service.dart';
import '../utils/gradient.dart';
import '../widgets/message_bubble.dart';
import '../widgets/feedback_dialog.dart';
import 'package:typewritertext/typewritertext.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';

class NewChatscreen extends StatefulWidget {
  const NewChatscreen({super.key});

  @override
  State<NewChatscreen> createState() => _NewChatscreenState();
}

class _NewChatscreenState extends State<NewChatscreen>
    with WindowListener, SingleTickerProviderStateMixin {
  int? _currentGeneratingIndex;
  final gemmaService =
      GemmaService(dotenv.env['GEMMA_API_KEY'] ?? '', 'gemma2-9b-it');
  final llamaService =
      LlamaService(dotenv.env['LLAMA_API_KEY'] ?? '', 'llama3-8b-8192');
  final mistralService =
      MistralService(dotenv.env['MISTRAL_API_KEY'] ?? '', 'mixtral-8x7b-32768');

  final _controller = SidebarXController(selectedIndex: 0, extended: true);

  final Map<int, List<Message>> _tabMessages = {};
  int _currentTabIndex = 0;

  final Map<int, ScrollController> _tabScrollControllers = {};
  final _key = GlobalKey<ScaffoldState>();

  static const int MAX_API_CALLS = 9;
  int _apiCallCount = 0;
  DateTime? _lastApiCallTime;
  final Map<int, bool> _initialMessageSentForTab = {};
  Timer? _resetTimer;

  late prefs.SharedPreferences _preferences;

  // state variable
  bool _showInitialQuestions = true;

  // key for positioning
  final GlobalKey _textFieldKey = GlobalKey();

  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializePreferences().then((_) {
      _loadApiCallCount();
      _setupResetTimer();
      _loadMessages();
    });
    _controller.addListener(_controllerListener);

    for (int i = 1; i <= 5; i++) {
      final controller = ScrollController();
      controller.addListener(() {
        // Handling scroll events for each tab
        if (controller.position.pixels == controller.position.maxScrollExtent) {
          _scrollToBottom();
        }
      });
      _tabScrollControllers[i] = controller;
    }

    windowManager.setPreventClose(true);
    windowManager.addListener(this);

    if (kIsWeb) {
      _setupWebBeforeUnload();
    }
  }

  void _controllerListener() {
    final newIndex = _controller.selectedIndex;
    if (newIndex != _currentTabIndex) {
      List<Message> updatedCurrentMessages = List.from(_messages);
      List<Message> newTabMessages = _tabMessages[newIndex] ?? [];
      setState(() {
        _tabMessages[_currentTabIndex] = updatedCurrentMessages;

        // Load messages for the new tab
        _messages.clear();
        _messages.addAll(newTabMessages);
        _currentTabIndex = newIndex;
      });
      _handleTabChange(newIndex);
      saveMessages();
    }
  }

  void _startNewChat() {
    setState(() {
      _messages.clear();
      _tabMessages[0]?.clear();
      _showInitialQuestions = true;
      _messageController.clear();
      _focusNode.requestFocus();
    });

    // Save empty state
    saveMessages();
  }

  void _handleTabChange(int tabIndex) {
    if (_initialMessageSentForTab[tabIndex] == true) return;

    String? sectionName;
    switch (tabIndex) {
      case 1:
        sectionName = 'Education';
        break;
      case 2:
        sectionName = 'Projects';
        break;
      case 3:
        sectionName = 'Experience';
        break;
      case 4:
        sectionName = 'Skills';
      case 5:
        sectionName = 'Fun';
        break;
      default:
        return;
    }

    final messages = initialMessages[sectionName];
    if (messages != null && messages.isNotEmpty) {
      sendMessage(messages[0]);
      _initialMessageSentForTab[tabIndex] = true;
    }
  }

  final FocusNode _focusNode = FocusNode();
  final List<Message> _messages = [];
  bool _isLoading = false;
  bool _isGenerating = false;

  final introController = TypeWriterController(
      text: "I am Anisha's AI assistant.",
      duration: const Duration(milliseconds: 90));

  final Map<String, String> _availableModels = {
    'Llama 3 (8B)': 'llama3-8b-8192',
    'Gemma 2 (9B)': 'gemma2-9b-it',
    'Mixtral 8 (7B)': 'mixtral-8x7b-32768',
  };

  String? _currentModel;

  final bool _showDropdown = true;
  final ScrollController _mainScrollController = ScrollController();
  static const String _storageKey = 'chat_history';

  // Add this list of starter questions
  final List<String> _starterQuestions = [
    "Tell me about Anisha's technical skills",
    "What projects has Anisha worked on?",
    "What are Anisha's career aspirations?",
    "What are Anisha's achievements?",
    "Tell me about Anisha's education",
    "How can I collaborate with Anisha?",
    "What programming languages does Anisha know?",
    "What are Anisha's research interests?",
  ];

  final Map<String, List<String>> initialMessages = {
    'Education': [
      "Tell me about Anisha's education history.",
      "What is Anisha's college major?",
      "Where did Anisha complete her diploma, and in what field?",
      "What is Anisha currently studying?",
    ],
    'Projects': [
      "What projects has Anisha worked on?",
      "What is Anisha's most notable academic project?",
      "What are Anisha's research projects?",
      "What is Anisha's AI-Driven Legal Research Engine project?",
    ],
    'Experience': [
      "What is Anisha's work history?",
      "Can you summarize Anisha's work as an intern at Aerovania?",
      "Tell me about Anisha's hackathon experience.",
      "What is Anisha's experience in team leadership?",
    ],
    'Skills': [
      "Which certifications has Anisha completed?",
      "What tools and frameworks is Anisha proficient in?",
      "Which programming languages does Anisha know?",
      "Tell me about Anisha's technical skills",
    ],
    'Fun': [
      "What's one fun fact about Anisha?",
      "What is her favorite anime?",
      "Can you decribe her is in one word?",
      "Who's her favorite author or book?",
      "What's the coolest tech gadget she owns?",
    ],
  };

  // map to store section indices
  final Map<String, int> sectionIndices = {
    'General': 0,
    'Education': 1,
    'Projects': 2,
    'Experience': 3,
    'Skills': 4,
    'Fun': 5,
  };

// helper method to get index
  int getSectionIndex(String section) {
    return sectionIndices[section] ?? 0;
  }

  Future<void> _loadApiCallCount() async {
    setState(() {
      _apiCallCount = _preferences.getInt('api_call_count') ?? 0;
      final lastCallTimeStr = _preferences.getString('last_api_call_time');
      _lastApiCallTime =
          lastCallTimeStr != null ? DateTime.parse(lastCallTimeStr) : null;
    });
  }

  void _setupResetTimer() {
    // Reset API call count every hour
    _resetTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _resetApiCallCount();
    });
  }

  Future<void> _resetApiCallCount() async {
    await _preferences.setInt('api_call_count', 0);
    setState(() {
      _apiCallCount = 0;
    });
  }

  Future<bool> _canMakeApiCall() async {
    if (_apiCallCount >= MAX_API_CALLS) {
      final now = DateTime.now();
      if (_lastApiCallTime != null &&
          now.difference(_lastApiCallTime!).inMinutes < 1) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rate limit reached. Please try again later.'),
            ),
          );
        }
        return false;
      }
      await _resetApiCallCount();
    }
    return true;
  }

  Future<void> _updateApiCallCount() async {
    // final sharedPrefs = await prefs.SharedPreferences.getInstance();
    _apiCallCount++;
    _lastApiCallTime = DateTime.now();
    await _preferences.setInt('api_call_count', _apiCallCount);
    await _preferences.setString(
        'last_api_call_time', _lastApiCallTime!.toIso8601String());
  }

  void _setupWebBeforeUnload() {
    html.window.onBeforeUnload.listen((event) async {
      // Show the feedback dialog
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const FeedbackDialog(),
      );

      if (result != true) {
        event.preventDefault();
      }
    });
  }

  Future<void> _initializePreferences() async {
    _preferences = await prefs.SharedPreferences.getInstance();
    _loadMessages();
  }

  // Saving messages for current tab
  Future<void> saveMessages() async {
    final String messagesJson = jsonEncode(
        _tabMessages[_currentTabIndex]?.map((m) => m.toJson()).toList() ?? []);
    await _preferences.setString(
        '${_storageKey}_$_currentTabIndex', messagesJson);
  }

  // Loading messages for each tab
  void _loadMessages() {
    for (int i = 1; i <= 5; i++) {
      final String? messagesJson = _preferences.getString('${_storageKey}_$i');
      if (messagesJson != null) {
        final List<dynamic> decoded = jsonDecode(messagesJson);
        _tabMessages[i] = decoded.map((msg) => Message.fromJson(msg)).toList();
      }
    }

    // Loading messages for current tab
    _messages.addAll(_tabMessages[_currentTabIndex] ?? []);
  }

  // method to stop generation
  void _stopGeneration() {
    setState(() {
      _isGenerating = false;
      _isLoading = false;
      if (_currentGeneratingIndex != null &&
          _currentGeneratingIndex! < _messages.length) {
        _messages.removeAt(_currentGeneratingIndex!);
        _currentGeneratingIndex = null;
      }
      _messages.add(Message(
        content:
            "Sorry, my last response took too long. Feel free to ask another question!",
        isUser: false,
        timestamp: DateTime.now(),
        relevantDocs: null,
      ));
    });
    _scrollToBottom();
    // gemmaService.cancelGeneration();
  }

  // method to handle question selection
  void _onQuestionTap(String question) {
    _messageController.text = question;
    handleSubmitted(question);
  }

  Future<List<Map<String, dynamic>>> fetchRelevantDocuments(
      String queryText) async {
    try {
      final url = Uri.parse(
          "https://chroma-rag-production.up.railway.app/query/"); //// http://127.0.0.1:8001/query/
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "query_text": queryText,
          "where": {"question": queryText},
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body)["results"];
        return results.map((result) {
          return {
            "question": result["question"],
            "answer": result["answer"],
            "highlighted_text": result["highlighted_text"],
            "links": result["links"]
          };
        }).toList();
      } else {
        throw Exception("Failed to fetch relevant documents");
      }
    } catch (e) {
      debugPrint("Error fetching documents: $e");
      return [];
    }
  }

  Future<void> sendMessage(String content) async {
    if (!await _canMakeApiCall()) {
      setState(() {
        _isGenerating = false;
        _isLoading = false;
        _messages.add(Message(
          content:
              "Sorry, you've reached maximum API calls limit for a minute! Please have some patience and try again after some time.",
          isUser: false,
          timestamp: DateTime.now(),
          relevantDocs: null,
        ));
      });
      _scrollToBottom();
      return;
    }

    if (content.trim().isEmpty) return;
    final userMessage = Message(
      content: content.trim(),
      isUser: true,
      timestamp: DateTime.now(),
      relevantDocs: null,
    );

    setState(() {
      _messages.add(userMessage);
      _tabMessages[_currentTabIndex] = List.from(_messages);
      _isLoading = true;
      _isGenerating = true;
    });

    _messageController.clear();
    _scrollToBottom();
    await saveMessages();

    final startTime = DateTime.now();
    String enhancedPrompt = '';

    try {
      // API call
      try {
        final relevantDocs = await fetchRelevantDocuments(content);
        if (!mounted) return;

        // Enhanced prompt with relevant docs (context)
        if (relevantDocs.isNotEmpty) {
          enhancedPrompt += "\n\nRelevant context:\n";
          for (Map<String, dynamic> doc in relevantDocs) {
            final question = doc['question'] as String? ?? 'No question';
            final answer = doc['answer'] as String? ?? 'No answer';
            enhancedPrompt += "Q: $question\nA: $answer\n";
          }
          // debugPrint('enhancedprompt: $enhancedPrompt');
        }

        // Create empty assistant message first
        Message assistantMessage;
        assistantMessage = Message(
          content: '',
          isUser: false,
          timestamp: DateTime.now(),
          relevantDocs: null,
        );

        // Generate response
        if (_isGenerating) {
          final response = await gemmaService.generateResponse(
              content, GroqMessageRole.user, enhancedPrompt);
          // }
          // debugPrint('response $response');

          setState(() {
            // _messages.add(Message(
            //   content: content,
            //   isUser: true,
            //   timestamp: DateTime.now(),
            // ));
            _messages.add(assistantMessage);
            _currentGeneratingIndex = _messages.length - 1;
            _isLoading = false;
            _isGenerating = true;
          });

          // Simulate streaming
          // gemmaService.chat.stream.listen((event) {
          //   event.when(
          //       request: (requestEvent) {},
          //       response: (responseEvent) {
          //         print(
          //             'Received response: ${responseEvent.response.choices.first.message}');
          //       });
          // });
          await for (final chunk in StreamService.simulateStream(response)) {
            if (!mounted || !_isGenerating) break;
            // debugPrint("responseeeee: $relevantDocs");
            try {
              setState(() {
                // Update message content with new chunk
                assistantMessage.updateContent(chunk);

                // Check if relevantDocs exists and has the required fields
                // Safely extract highlighted text

                // Extract highlighted text and links once
                if (relevantDocs.isNotEmpty) {
                  final doc = relevantDocs.first;
                  if (doc.containsKey('highlighted_text') &&
                      doc.containsKey('links')) {
                    assistantMessage.highlightedText =
                        List<String>.from(doc['highlighted_text']);
                    assistantMessage.links = List<String>.from(doc['links']);
                    debugPrint(
                        'highlighted text: ${assistantMessage.highlightedText}');
                    debugPrint('links: ${assistantMessage.links}');
                  }
                }

                // if (relevantDocs[2] is List) {
                // List<String>.from(relevantDocs[''] as List<dynamic>);
                //   debugPrint('highlighttttt: ${relevantDocs[2]}');
                // }

                // // Safely extract links
                // if (relevantDocs[3] is List) {
                //       List<String>.from(relevantDocs[3] as List<dynamic>);
                //   debugPrint('linksssss: ${relevantDocs[3]}');
                // }
              });
            } catch (e) {
              debugPrint('Error processing response chunk: $e');
              continue;
            }
          }

          if (mounted && _isGenerating) {
            final endTime = DateTime.now();
            assistantMessage.generationTime = endTime.difference(startTime);

            setState(() {
              //   _messages.add(Message(
              //     content: response,
              //     isUser: false,
              //     timestamp: DateTime.now(),
              //     relevantDocs: null,
              //     generationTime: generationTime,
              //   ));
              _isGenerating = false;
            });

            await saveMessages();
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _messages.add(Message(
              content: 'Error: Failed to get response. Error: $e',
              isUser: false,
              timestamp: DateTime.now(),
              relevantDocs: null,
            ));
            _isGenerating = false;
          });
          await saveMessages();
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isGenerating = false;
          });
          _scrollToBottom();
          _focusNode.requestFocus();
        }
      }

      // Update the call count after successful API call
      await _updateApiCallCount();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void handleSubmitted(String text) {
    setState(() {
      _isGenerating = true;
    });
    // debugPrint('texttttt: $text');
    if (!_isLoading) {
      sendMessage(text);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = _tabScrollControllers[_currentTabIndex];

      if (_mainScrollController.hasClients) {
        _mainScrollController.animateTo(
          _mainScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }

      if (controller != null && controller.hasClients) {
        controller.animateTo(
          controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // method to handle first message and hide initial questions
  void _handleFirstMessage(String question, String type) {
    setState(() {
      _showInitialQuestions = false;
      _messageController.clear();
      _isGenerating = true;
    });

    if (!(type == 'General')) {
      String systemPrompt = '';
      switch (type) {
        case 'Education':
          systemPrompt = Prompts.educationPrompt;
          break;
        case 'Projects':
          systemPrompt = Prompts.projectsPrompt;
          break;
        case 'Experience':
          systemPrompt = Prompts.experiencePrompt;
          break;
        case 'Skills':
          systemPrompt = Prompts.skillsPrompt;
          break;
        case 'Fun':
          systemPrompt = Prompts.funPrompt;
          break;
        default:
          systemPrompt = Prompts.systemPrompt;
      }

      gemmaService.chat.addMessageWithoutSending(systemPrompt);
    }

    _onQuestionTap(question);
  }

  // method to show question popup
  void _showQuestionPopup(BuildContext context, RenderBox textFieldBox) {
    try {
      if (_starterQuestions.isEmpty) return;

      final RenderBox overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox;

      final buttonPosition =
          textFieldBox.localToGlobal(Offset.zero, ancestor: overlay);
      final position = RelativeRect.fromLTRB(
          buttonPosition.dx,
          buttonPosition.dy,
          buttonPosition.dx + textFieldBox.size.width,
          buttonPosition.dy);

      showMenu<String>(
        context: context,
        position: position,
        constraints: const BoxConstraints(
          maxWidth: 300,
          maxHeight: 240,
        ),
        items: _starterQuestions.map((String question) {
          return PopupMenuItem<String>(
            value: question,
            child: Text(
              question,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
      ).then((String? question) {
        if (question != null) {
          _onQuestionTap(question);
        }
      });
    } catch (e) {
      // debugPrint('Error showing question popup: $e');
    }
  }

  void _showQuestionPopupFotTab(
      BuildContext context, RenderBox buttonBox, String tab) async {
    try {
      final questions = initialMessages[tab] ?? [];
      if (questions.isEmpty) return;

      final RenderBox overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox;

      final buttonPosition =
          buttonBox.localToGlobal(Offset.zero, ancestor: overlay);
      final position = RelativeRect.fromLTRB(
          buttonPosition.dx,
          buttonPosition.dy,
          buttonPosition.dx + buttonBox.size.width,
          buttonPosition.dy);

      final String? selectedQuestion = await showMenu<String>(
        context: context,
        position: position,
        constraints: const BoxConstraints(
          maxWidth: 300,
          maxHeight: 240,
        ),
        items: questions.map((String question) {
          return PopupMenuItem<String>(
            value: question,
            child: Text(
              question,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
      );

      if (selectedQuestion != null && context.mounted) {
        _onQuestionTap(selectedQuestion);
      }
    } catch (e) {
      // debugPrint('Error showing question popup: $e');
    }
  }

  Widget _buildStopGenerationButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: ElevatedButton.icon(
          onPressed: _stopGeneration,
          icon: const Icon(Icons.stop_circle),
          label: const Text('stop generating'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onError,
            backgroundColor: Colors.redAccent.shade100,
          ),
        ),
      ),
    );
  }

  Future<void> _clearHistory() async {
    setState(() {
      _messages.clear();
      _tabMessages.clear();

      for (int i = 1; i <= 5; i++) {
        _tabMessages[i] = [];
        _initialMessageSentForTab[i] = false;
        _tabScrollControllers[i]!.jumpTo(0);
      }

      _isLoading = false;
      _isGenerating = false;
      _currentTabIndex = 0;

      _messageController.clear();
    });

    // Clear all stored messages from SharedPreferences
    final sharedPrefs = await prefs.SharedPreferences.getInstance();
    for (int i = 1; i < 5; i++) {
      await sharedPrefs.remove('${_storageKey}_$i');
    }
    await sharedPrefs.remove(_storageKey);
  }

  Future<bool> _onWillPop() async {
    if (PlatformService.isDesktop) {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const FeedbackDialog(),
      );
      return result ?? false;
    }
    return true;
  }

  @override
  void onWindowClose() async {
    if (PlatformService.isDesktop) {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const FeedbackDialog(),
      );
      if (result != null) {
        await _cleanupAllTabs();
        await windowManager.destroy();
      }
    }
  }

// async method for cleanup
  Future<void> _cleanupAllTabs() async {
    try {
      final sharedPrefs = await prefs.SharedPreferences.getInstance();
      // Clear all tab messages (0-5 for all possible tabs)
      for (int i = 0; i <= 5; i++) {
        await sharedPrefs.remove('${_storageKey}_$i');
      }
      // Clear main storage
      await sharedPrefs.remove(_storageKey);

      // Clear in-memory messages
      _messages.clear();
      _tabMessages.clear();
    } catch (e) {
      debugPrint('Error cleaning up tabs: $e');
    }
  }

  @override
  void dispose() {
    if (PlatformService.isDesktop) {
      windowManager.removeListener(this);
    }
    _controller.removeListener(() {});
    _controller.dispose();
    _mainScrollController.dispose();
    introController.dispose();
    _resetTimer?.cancel();

    for (var controller in _tabScrollControllers.values) {
      controller.removeListener(() {});
      controller.dispose();
    }

    _cleanupAllTabs();
    _resetApiCallCount();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Builder(
        builder: (context) {
          final isSmallScreen = MediaQuery.of(context).size.width < 600;

          return SafeArea(
            child: Scaffold(
              key: _key,
              drawer: SideNavbar(
                controller: _controller,
                onNewChat: _startNewChat,
                isSmallScreen: isSmallScreen,
              ),
              body: Row(
                children: [
                  if (!isSmallScreen)
                    SideNavbar(
                      controller: _controller,
                      onNewChat: _startNewChat,
                      isSmallScreen: isSmallScreen,
                    ),
                  Expanded(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          switch (_controller.selectedIndex) {
                            case 0:
                              _key.currentState?.closeDrawer();
                              return buildMainChatScreen(context);
                            // return buildTabContent('Education');
                            case 1:
                              _key.currentState?.closeDrawer();
                              return buildTabContent('Education');
                            case 2:
                              _key.currentState?.closeDrawer();
                              return buildTabContent('Projects');
                            case 3:
                              _key.currentState?.closeDrawer();
                              return buildTabContent('Experience');
                            case 4:
                              _key.currentState?.closeDrawer();
                              return buildTabContent('Skills');
                            case 5:
                              _key.currentState?.closeDrawer();
                              return buildTabContent('Fun');
                            default:
                              return buildMainChatScreen(context);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  buildAppBar(bool isMain) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      leading: MediaQuery.of(context).size.width < 600
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                _key.currentState?.openDrawer();
              },
            )
          : null,
      title: _showDropdown
          ? PreferredSize(
              preferredSize: const Size.fromHeight(45),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _currentModel,
                      isExpanded: false,
                      hint: const Text('Gemma 2 (9B)'),
                      items: _availableModels.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.value,
                          child: Text(entry.key),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _currentModel = newValue;
                            gemmaService.switchModel(newValue);
                            _messages.clear();
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
            )
          : null,
      actions: [
        if (isMain)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Clear History'),
                content: const Text(
                    'Are you sure you want to clear all chat history?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      _clearHistory();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  buildMainChatScreen(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: buildAppBar(true),
      body: Column(
        children: [
          if (_messages.isEmpty)
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GradientText(
                      'Hello!',
                      colors: const [
                        Color.fromARGB(233, 80, 172, 247),
                        Color.fromARGB(228, 249, 100, 100),
                      ],
                      style: TextStyle(
                        fontSize: isSmallScreen
                            ? MediaQuery.of(context).size.width * 0.087
                            : MediaQuery.of(context).size.width * 0.027,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TypeWriter(
                      controller: introController,
                      builder: (context, value) {
                        return GradientText(
                          value.text,
                          colors: const [
                            Color.fromARGB(233, 80, 172, 247),
                            Color.fromARGB(228, 249, 100, 100),
                          ],
                          style: TextStyle(
                            fontSize: isSmallScreen
                                ? MediaQuery.of(context).size.width * 0.077
                                : MediaQuery.of(context).size.width * 0.027,
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    BorderGradient(
                      child: Container(
                        height: MediaQuery.of(context).size.height *
                            (isSmallScreen ? 0.35 : 0.35),
                        width: MediaQuery.of(context).size.width *
                            (isSmallScreen ? 0.7 : 0.5),
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width * 0.02),
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.8),
                            width: MediaQuery.of(context).size.width * 0.003,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius:
                                  MediaQuery.of(context).size.width * 0.02,
                              offset: Offset(
                                  0, MediaQuery.of(context).size.width * 0.01),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontSize: isSmallScreen
                                        ? MediaQuery.of(context).size.width *
                                            0.045
                                        : MediaQuery.of(context).size.width *
                                            0.015),
                                textAlign: TextAlign.justify,
                                "And you've found Anisha's digital portfolio, and I'm here to help you explore it. Got a question about her research, certifications, or upcoming goals? Just ask me. I've got all the answers! Ask me anything, and I'll guide you through! 😊"),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            isSmallScreen
                                ? "Disclaimer: Responses may not always be \n accurate or complete."
                                : 'Disclaimer: Responses may not always be accurate or complete.',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: MediaQuery.of(context).size.width *
                                  (isSmallScreen ? 0.041 : 0.01),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _mainScrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length +
                  (_isGenerating ? 1 : 0) +
                  (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _messages.length) {
                  if (_isGenerating && index == _messages.length) {
                    return _buildStopGenerationButton();
                  }
                  if (_isLoading &&
                      index == _messages.length + (_isGenerating ? 1 : 0)) {
                    return Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SkeletonParagraph(
                        style: SkeletonParagraphStyle(
                          lines: 5,
                          spacing: 9,
                          lineStyle: SkeletonLineStyle(
                            randomLength: true,
                            height: 10,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            minLength: MediaQuery.of(context).size.width / 3,
                            maxLength: MediaQuery.of(context).size.width / 2,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }
                final message = _messages[index];
                return MessageBubble(message: message);
              },
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                if (_messages.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            'Not sure where to begin?',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              for (var question in _starterQuestions)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: ActionChip(
                                    label: Text(question),
                                    onPressed: () => _handleFirstMessage(
                                        question, "General"),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          if (!_showInitialQuestions)
                            IconButton(
                              icon: const Icon(Icons.quiz_outlined),
                              onPressed: () {
                                final RenderBox textField = _textFieldKey
                                    .currentContext!
                                    .findRenderObject() as RenderBox;
                                _showQuestionPopup(context, textField);
                              },
                            ),
                          Expanded(
                            child: TextField(
                              key: _textFieldKey,
                              controller: _messageController,
                              focusNode: _focusNode,
                              decoration: InputDecoration(
                                hintText: 'Try asking: \'Who is Anisha?\' ',
                                border: OutlineInputBorder(),
                                suffixIcon: _isGenerating
                                    ? IconButton(
                                        icon: const Icon(Icons.stop_circle),
                                        onPressed: _stopGeneration,
                                      )
                                    : null,
                              ),
                              maxLines: null,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (text) {
                                if (!_isLoading &&
                                    !_isGenerating &&
                                    text.trim().isNotEmpty) {
                                  handleSubmitted(text);
                                }
                              },
                              enabled: !_isLoading && !_isGenerating,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _isLoading
                                ? null
                                : () =>
                                    handleSubmitted(_messageController.text),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTabContent(String type) {
    final messages = initialMessages[type] ?? [];
    final tabIndex = getSectionIndex(type);

    return Scaffold(
      appBar: buildAppBar(false),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _tabScrollControllers[tabIndex],
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length +
                  (_isGenerating ? 1 : 0) +
                  (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _messages.length) {
                  if (_isGenerating && index == _messages.length) {
                    return _buildStopGenerationButton();
                  }
                  if (_isLoading &&
                      index == _messages.length + (_isGenerating ? 1 : 0)) {
                    return Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SkeletonParagraph(
                        style: SkeletonParagraphStyle(
                          lines: 5,
                          spacing: 9,
                          lineStyle: SkeletonLineStyle(
                            randomLength: true,
                            height: 10,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            minLength: MediaQuery.of(context).size.width / 3,
                            maxLength: MediaQuery.of(context).size.width / 2,
                          ),
                        ),
                      ),
                    );
                  }
                }
                final message = _messages[index];
                return MessageBubble(message: message);
              },
            ),
          ),
          if (messages.isEmpty && !_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Not sure where to begin?',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        for (var question in messages)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ActionChip(
                              label: Text(question),
                              onPressed: () =>
                                  _handleFirstMessage(question, type),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.quiz_outlined),
                onPressed: () {
                  final RenderBox textField = _textFieldKey.currentContext!
                      .findRenderObject() as RenderBox;
                  _showQuestionPopupFotTab(context, textField, type);
                },
              ),
              Expanded(
                child: TextField(
                  key: _textFieldKey,
                  controller: _messageController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: type == 'Fun'
                        ? 'Ask something funny'
                        : 'Ask about $type',
                    border: const OutlineInputBorder(),
                    suffixIcon: _isGenerating
                        ? IconButton(
                            icon: const Icon(Icons.stop_circle),
                            onPressed: _stopGeneration,
                          )
                        : null,
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: handleSubmitted,
                  enabled: !_isGenerating,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _isLoading
                    ? null
                    : () => handleSubmitted(_messageController.text),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
