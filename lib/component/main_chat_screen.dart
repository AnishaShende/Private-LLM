// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:groq_sdk/groq_sdk.dart';
// import 'package:shared_preferences/shared_preferences.dart' as prefs;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:window_manager/window_manager.dart';
// import 'package:http/http.dart' as http;
// import 'package:universal_html/html.dart' as html;

// import '../models/message.dart';
// import '../services/gemma_service.dart';
// import '../services/platform_service.dart';
// import '../utils/gradient.dart';
// import '../widgets/message_bubble.dart';
// import '../widgets/feedback_dialog.dart';
// import 'package:typewritertext/typewritertext.dart';

// class MainChatScreen extends StatefulWidget {
//   bool isMainChatScreen;
//   String screenType;
//   // Map<String, List<String>> initialMessages = {
//   //   'Education': [
//   //     "Tell me about Anisha's education history.",
//   //     "Tell me about Anisha's education history.",
//   //     "Tell me about Anisha's education history.",
//   //     "Tell me about Anisha's education history.",
//   //   ],
//   //   'Projects': [
//   //     "What projects has Anisha worked on?",
//   //     "What projects has Anisha worked on?",
//   //     "What projects has Anisha worked on?",
//   //     "What projects has Anisha worked on?",
//   //   ],
//   //   'Experience': [
//   //     "What is Anisha's work history?",
//   //     "What is Anisha's work history?",
//   //     "What is Anisha's work history?",
//   //     "What is Anisha's work history?",
//   //   ],
//   //   'Skills': [
//   //     "Tell me about Anisha's technical skills",
//   //     "Tell me about Anisha's technical skills",
//   //     "Tell me about Anisha's technical skills",
//   //     "Tell me about Anisha's technical skills",
//   //   ],
//   // };

//   MainChatScreen(
//       {this.isMainChatScreen = true, this.screenType = "Main", super.key});

//   @override
//   State<MainChatScreen> createState() => _MainChatScreenState();
// }

// class _MainChatScreenState extends State<MainChatScreen> with WindowListener {
//   final gemmaService = GemmaService(
//       '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',
//       'gemma2-9b-it');

//   String _selectedTab = 'Main';
//   static const int MAX_API_CALLS = 3;
//   int _apiCallCount = 0;
//   DateTime? _lastApiCallTime;
//   bool _initialMessageSent = false;
//   Timer? _resetTimer;

//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode _focusNode = FocusNode();
//   final List<Message> _messages = [];
//   final List<String> _ollamaMessages = [];
//   bool _isLoading = false;
//   bool _isGenerating = false;
//   // late final Ollama _ollama;
// //   final String _systemPrompt = """
// // You are AIsha, an AI assistant trained on the data of Anisha Shende, a 20-year-old tech enthusiast, Flutter developer, and AI researcher from India. You embody Anisha's friendly, knowledgeable, and professional personality while reflecting her expertise and unique character.
// // Your purpose is to provide accurate, professional, and engaging responses to questions about Anisha's personal background, academic achievements, skills, projects, career aspirations, and other relevant topics.
// // Response Guidelines:
// // Perspective: Always refer to Anisha in the third person, as you are her virtual representation.
// // Tone:
// // Use a friendly and casual tone for personal or fun questions.
// // Be concise and professional for queries from recruiters or collaborators.
// // Provide detailed and technical explanations for questions about her projects, skills, or expertise.
// // Stay informative and concise while maintaining a warm and approachable tone.
// // Knowledge Representation: Showcase Anisha's technical expertise, achievements, and interests when relevant.
// // Limitations: For questions outside your training data, politely acknowledge your limitations and suggest contacting Anisha directly for further details. For fun or playful questions, you can respond with humor, such as saying, “Well, it's a secret. 😉”
// // Engagement: Maintain Anisha's enthusiastic personality in all responses. Use casual phrases like "bro" or emojis when appropriate for informal conversations, ensuring your tone aligns with Anisha's approachable demeanor.
// // Remember: Short responses for general queries, comprehensive details for technical/project questions, and polite deflection for irrelevant topics.
// // Primary Objective: Your goal is to provide accurate, helpful, and engaging responses that reflect Anisha's work, projects, skills, and aspirations, enhancing the user's understanding while staying true to her personality.
// // """;

//   // final List<String> _availableModels = [
//   //   // 'llama3.2-vision',
//   //   // 'gemma2',
//   //   // 'mistral-nemo',
//   //   // 'llama3.1',
//   //   'llama3_8b',
//   //   'gemma_7b',
//   //   'mixtral8_7b',
//   //   'whisper_large_v3'
//   // ];

//   final Map<String, String> _availableModels = {
//     'Llama 3 (8B)': 'lama3-8b-8192',
//     'Gemma 2 (9B)': 'gemma2-9b-it',
//     'Mixtral 8 (7B)': 'mixtral-8x7b-32768',
//   };

//   String? _currentModel;
//   bool _isLoadingModels = false;

//   // Add this list of starter questions
//   final List<String> _starterQuestions = [
//     "Tell me about Anisha's technical skills",
//     "What projects has Anisha worked on?",
//     "What are Anisha's career aspirations?",
//     "Tell me about Anisha's education",
//     "What programming languages does Anisha know?",
//     "What are Anisha's achievements?",
//     "How can I collaborate with Anisha?",
//     "What are Anisha's research interests?",
//   ];

//   final Map<String, List<String>> initialMessages = {
//     'Education': [
//       "Tell me about Anisha's education history.",
//       "Tell me about Anisha's education history.",
//       "Tell me about Anisha's education history.",
//       "Tell me about Anisha's education history.",
//     ],
//     'Projects': [
//       "What projects has Anisha worked on?",
//       "What projects has Anisha worked on?",
//       "What projects has Anisha worked on?",
//       "What projects has Anisha worked on?",
//     ],
//     'Experience': [
//       "What is Anisha's work history?",
//       "What is Anisha's work history?",
//       "What is Anisha's work history?",
//       "What is Anisha's work history?",
//     ],
//     'Skills': [
//       "Tell me about Anisha's technical skills",
//       "Tell me about Anisha's technical skills",
//       "Tell me about Anisha's technical skills",
//       "Tell me about Anisha's technical skills",
//     ],
//   };

//   // final bool _isQuestionsExpanded = false;

//   // Add this method to handle question selection
//   void _onQuestionTap(String question) {
//     _messageController.text = question;
//     handleSubmitted(question);
//   }

//   Future<List<Map<String, dynamic>>> fetchRelevantDocuments(
//       // List<Map<String, dynamic>> res;
//       String queryText) async {
//     try {
//       final url = Uri.parse("http://127.0.0.1:8080/query/");
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"query_text": queryText}),
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> results = jsonDecode(response.body)["results"];
//         return results.map((result) {
//           return {
//             "question": result["question"],
//             "answer": result["answer"],
//           };
//         }).toList();
//       } else {
//         throw Exception("Failed to fetch relevant documents");
//       }
//     } catch (e) {
//       print("Error fetching documents: $e");
//       return [];
//     }
//   }

//   bool _showDropdown = true;
//   final ScrollController _mainScrollController = ScrollController();
//   static const String _storageKey = 'chat_history';
//   late final prefs.SharedPreferences _preferences;

//   @override
//   void initState() {
//     super.initState();
//     _loadApiCallCount();
//     _setupResetTimer();
//     _currentModel = _availableModels['Gemma 2 (9B)'];
//     if (PlatformService.isDesktop) {
//       windowManager.addListener(this);
//     } else if (PlatformService.isWeb) {
//       _setupWebBeforeUnload();
//     }
//     _initializePreferences(); // Move this first
//     // _initOllama();
//     _loadAvailableModels();

//     // Modify scroll listener to use proper scroll controller
//     _mainScrollController.addListener(() {
//       if (_mainScrollController.hasClients &&
//           _mainScrollController.position.hasPixels) {
//         if (_mainScrollController.position.userScrollDirection ==
//             ScrollDirection.reverse) {
//           if (_showDropdown) {
//             setState(() => _showDropdown = false);
//           }
//         } else if (_mainScrollController.position.userScrollDirection ==
//             ScrollDirection.forward) {
//           if (!_showDropdown) {
//             setState(() => _showDropdown = true);
//           }
//         }
//       }
//     });
//   }

//   Future<void> _loadApiCallCount() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _apiCallCount = prefs.getInt('api_call_count') ?? 0;
//       final lastCallTimeStr = prefs.getString('last_api_call_time');
//       _lastApiCallTime =
//           lastCallTimeStr != null ? DateTime.parse(lastCallTimeStr) : null;
//     });
//   }

//   void _setupResetTimer() {
//     // Reset API call count every hour
//     _resetTimer = Timer.periodic(const Duration(hours: 1), (timer) {
//       _resetApiCallCount();
//     });
//   }

//   Future<void> _resetApiCallCount() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('api_call_count', 0);
//     setState(() {
//       _apiCallCount = 0;
//     });
//   }

//   Future<bool> _canMakeApiCall() async {
//     if (_apiCallCount >= MAX_API_CALLS) {
//       final now = DateTime.now();
//       if (_lastApiCallTime != null &&
//           now.difference(_lastApiCallTime!).inHours < 1) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Rate limit reached. Please try again later.'),
//           ),
//         );
//         return false;
//       }
//       await _resetApiCallCount();
//     }
//     return true;
//   }

//   Future<void> _updateApiCallCount() async {
//     final prefs = await SharedPreferences.getInstance();
//     _apiCallCount++;
//     _lastApiCallTime = DateTime.now();
//     await prefs.setInt('api_call_count', _apiCallCount);
//     await prefs.setString(
//         'last_api_call_time', _lastApiCallTime!.toIso8601String());
//   }

//   void _setupWebBeforeUnload() {
//     html.window.onBeforeUnload.listen((event) async {
//       // Show the feedback dialog
//       final result = await showDialog<bool>(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const FeedbackDialog(),
//       );

//       if (result != true) {
//         event.preventDefault();
//       }
//     });
//   }

//   Future<void> _initializePreferences() async {
//     _preferences = await prefs.SharedPreferences.getInstance();
//     _loadMessages();
//   }

//   void _loadMessages() {
//     final String? messagesJson = _preferences.getString(_storageKey);
//     if (messagesJson != null) {
//       final List<dynamic> decoded = jsonDecode(messagesJson);
//       setState(() {
//         _messages.addAll(
//           decoded.map((msg) => Message.fromJson(msg)).toList(),
//         );
//         // Rebuild ollama messages for context
//         //   _ollamaMessages.clear();
//         //   if (_messages.isNotEmpty) {
//         //     // _ollamaMessages.add(ChatMessage(
//         //     //   role: 'system',
//         //     //   content: _systemPrompt,
//         //     // ));
//         //     // for (final message in _messages) {
//         //     //   // _ollamaMessages.add(ChatMessage(
//         //     //   //   role: message.isUser ? 'user' : 'assistant',
//         //     //   //   content: message.content,
//         //     //   // ));
//         //     // }
//         //   }
//       });
//     }
//   }

//   Future<void> saveMessages() async {
//     final String messagesJson =
//         jsonEncode(_messages.map((m) => m.toJson()).toList());
//     await _preferences.setString(_storageKey, messagesJson);
//   }

//   @override
//   void dispose() {
//     if (PlatformService.isDesktop) {
//       windowManager.removeListener(this);
//     }
//     _mainScrollController.dispose();
//     // helloController.dispose();
//     introController.dispose();
//     _resetTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _loadAvailableModels() async {
//     setState(() => _isLoadingModels = true);
//     try {
//       await Future.delayed(const Duration(seconds: 1));
//     } finally {
//       setState(() => _isLoadingModels = false);
//     }
//   }

//   // Add this method to stop generation
//   void _stopGeneration() {
//     setState(() {
//       _isGenerating = false;
//       _isLoading = false;
//       _messages.add(Message(
//         content:
//             "Sorry, my last response took too long. Feel free to ask another question!",
//         isUser: false,
//         timestamp: DateTime.now(),
//         relevantDocs: null,
//       ));
//     });
//     _scrollToBottom();
//   }

//   Future<void> sendMessage(String content) async {
//     if (content.trim().isEmpty) return;
//     // List<Map<String, dynamic>>? relevantDocs;
//     // ;
//     String enhancedPrompt = '';
//     final startTime = DateTime.now();

//     // First fetch relevant documents
//     final relevantDocs = await fetchRelevantDocuments(content);
//     if (!mounted) return; // Add mounted check
//     // print("printing relevant docs: $relevantDocs");
//     // Add user message
//     final userMessage = Message(
//       content: content.trim(),
//       isUser: true,
//       timestamp: DateTime.now(),
//       relevantDocs: relevantDocs,
//     );

//     setState(() {
//       _messages.add(userMessage);
//       _isLoading = true;
//       _isGenerating = true;
//       // _selectedTab = 'Main';
//       // Add user message with context from relevant documents
//       // enhancedPrompt = content;
//       // print("content: $content");
//       // if (relevantDocs.isNotEmpty) {
//       enhancedPrompt += "\n\nRelevant context:\n";
//       for (Map<String, dynamic> doc in relevantDocs) {
//         final question = doc['question'] as String? ?? 'No question';
//         final answer = doc['answer'] as String? ?? 'No answer';
//         enhancedPrompt += "Q: $question\nA: $answer\n";
//       }
//       // }
//     });

//     await saveMessages();
//     _messageController.clear();
//     _scrollToBottom();

//     try {
//       final response = await gemmaService.generateResponse(
//           content, GroqMessageRole.user, enhancedPrompt);

//       if (mounted && _isGenerating) {
//         final endTime = DateTime.now();
//         final generationTime = endTime.difference(startTime);

//         setState(() {
//           _messages.add(Message(
//             content: response,
//             isUser: false,
//             timestamp: DateTime.now(),
//             relevantDocs: null,
//             generationTime: generationTime,
//           ));
//         });

//         await saveMessages();
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _messages.add(Message(
//             content: 'Error: Failed to get response. Error: $e',
//             isUser: false,
//             timestamp: DateTime.now(),
//             relevantDocs: null,
//           ));
//         });
//         await saveMessages();
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _isGenerating = false;
//         });
//         _scrollToBottom();
//         _focusNode.requestFocus();
//       }
//     }
//   }

//   void handleSubmitted(String text) {
//     if (!_isLoading) {
//       sendMessage(text);
//     }
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_mainScrollController.hasClients) {
//         // Use mainScrollController instead
//         _mainScrollController.animateTo(
//           _mainScrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   bool _showInitialQuestions = true; // Add this state variable
//   final GlobalKey _textFieldKey = GlobalKey(); // Add this key for positioning

//   // Add this method to handle first message and hide initial questions
//   void _handleFirstMessage(String question) {
//     setState(() {
//       _showInitialQuestions = false;
//     });
//     _onQuestionTap(question);
//   }

//   // Add this method to show question popup
//   void _showQuestionPopup(BuildContext context, RenderBox textFieldBox) {
//     final RenderBox overlay =
//         Overlay.of(context).context.findRenderObject() as RenderBox;
//     final position = RelativeRect.fromRect(
//       Rect.fromPoints(
//         textFieldBox.localToGlobal(Offset(0, -textFieldBox.size.height),
//             ancestor: overlay),
//         textFieldBox.localToGlobal(textFieldBox.size.bottomRight(Offset.zero),
//             ancestor: overlay),
//       ),
//       Offset.zero & overlay.size,
//     );

//     showMenu<String>(
//       context: context,
//       position: position,
//       items: _starterQuestions.map((String question) {
//         return PopupMenuItem<String>(
//           value: question,
//           child: Text(question, style: const TextStyle(fontSize: 14)),
//         );
//       }).toList(),
//     ).then((String? question) {
//       if (question != null) {
//         _onQuestionTap(question);
//       }
//     });
//   }

//   Widget _buildStopGenerationButton() {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Center(
//         child: ElevatedButton.icon(
//           onPressed: _stopGeneration,
//           icon: const Icon(Icons.stop_circle),
//           label: const Text('Stop Generating'),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Theme.of(context).colorScheme.error,
//             foregroundColor: Theme.of(context).colorScheme.onError,
//           ),
//         ),
//       ),
//     );
//   }

//   // Add method to clear history
//   Future<void> _clearHistory() async {
//     setState(() {
//       _messages.clear();
//       _ollamaMessages.clear();
//     });
//     await _preferences.remove(_storageKey);
//   }

//   Future<bool> _onWillPop() async {
//     if (PlatformService.isDesktop) {
//       final result = await showDialog<bool>(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const FeedbackDialog(),
//       );
//       return result ?? false;
//     }
//     return true;
//   }

//   @override
//   void onWindowClose() async {
//     if (PlatformService.isDesktop) {
//       final result = await showDialog<bool>(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const FeedbackDialog(),
//       );
//       if (result != null) {
//         await windowManager.destroy();
//       }
//     }
//   }

//   // final valueController = TypeWriterController.fromValue(
//   //   TypeWriterValue([
//   //     'First Paragraph',
//   //     'Next Paragraph',
//   //     'Last Paragraph',
//   //   ]),
//   //   duration: const Duration(milliseconds: 50),
//   // );
//   // final helloController = TypeWriterController(
//   //     text: "Hello!", duration: const Duration(milliseconds: 60));

//   final introController = TypeWriterController(
//       text: "I am Anisha's AI assistant.",
//       duration: const Duration(milliseconds: 90));
// // valueController.add(TypeWriterValue(
// //   text: 'Hello!\n'
// //       "I am Anisha's AI assistant.\n"
// //       "Let's emerge in a conversation about her and try to understand her better.",
// //   duration: const Duration(milliseconds: 50),
// // ));
//   // final streamController =
//   //     TypeWriterController.fromStream(StreamController<String>().stream);

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         appBar: _buildAppBar(),
//         body: Builder(
//           builder: (context) {
//             final isSmallScreen = MediaQuery.of(context).size.width < 600;
//             return Row(
//               children: [
//                 // if (!isSmallScreen)
//                 // SideNavbar(controller: ,),
//                 // ationBar(

//                 //     // onChatInit: (String message) {
//                 //     //   // Handle chat initialization
//                 //     // },
//                 //     ),
//                 GestureDetector(
//                   onTap: () => FocusScope.of(context).unfocus(),
//                   child: Expanded(child: _buildContent()),
//                 ),
//               ],
//             );
//           },
//         ),
//         // GestureDetector(
//         //   onTap: () => FocusScope.of(context).unfocus(),
//         //   child: Expanded(child: _buildContent()),
//         // ),
//       ),
//     );
//   }

//   Widget _buildContent() {
//     if (!widget.isMainChatScreen && !_initialMessageSent) {
//       WidgetsBinding.instance.addPostFrameCallback((_) async {
//         if (await _canMakeApiCall() &&
//             initialMessages[_selectedTab]?.isNotEmpty == true) {
//           _initialMessageSent = true;
//           await _updateApiCallCount();
//           /////// sendMessage(widget.initialMessages[_selectedTab]![0]);
//         }
//       });
//     }

//     switch (_selectedTab) {
//       case 'Projects':
//         return _buildTabContent('Projects');
//       case 'Experience':
//         return _buildTabContent('Experience');
//       case 'Skills':
//         return _buildTabContent('Skills');
//       case 'Education':
//         return _buildTabContent('Education');
//       default:
//         return _buildMainChatScreen();
//     }
//   }

//   _buildTabContent(String type) {
//     // print('type is : ${widget.screenType}');
//     // print('list is : ${widget.initialMessages}');
//     // if (_messages.isNotEmpty) ..._buildMessages(),
//     return Column(
//       children: [
//         // if (_messages.isNotEmpty)
//         Expanded(
//           child: ListView.builder(
//             controller: _mainScrollController, // Use the new scroll controller
//             padding: const EdgeInsets.all(16),
//             itemCount: _messages.length + (_isGenerating ? 1 : 0),
//             itemBuilder: (context, index) {
//               if (index == _messages.length) {
//                 return _buildStopGenerationButton();
//               }
//               final message = _messages[index];
//               return MessageBubble(message: message);
//             },
//           ),
//         ),
//         /////// if (widget.initialMessages.isNotEmpty)
//         Container(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.surface,
//             border: Border(
//               top: BorderSide(
//                 color: Theme.of(context).colorScheme.outline,
//               ),
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: Text(
//                   'Start the conversation',
//                   style: Theme.of(context).textTheme.titleSmall,
//                 ),
//               ),
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.symmetric(horizontal: 8),
//                 child: Row(
//                   children: [
//                     ///// for (var question
//                     /////     in widget.initialMessages[_selectedTab]!)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 4),
//                       child: ActionChip(
//                         label: Text('question'), ////
//                         onPressed: () => _handleFirstMessage('question'), ////
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         if (_isLoading)
//           const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: LinearProgressIndicator(),
//           ),
//         SafeArea(
//           child: Stack(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8.0),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.surface,
//                   border: Border(
//                     top: BorderSide(
//                       color: Theme.of(context).colorScheme.outline,
//                     ),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     if (!_showInitialQuestions) // Add question button when initial questions are hidden
//                       IconButton(
//                         icon: const Icon(Icons.quiz_outlined),
//                         onPressed: () {
//                           final RenderBox textField =
//                               _textFieldKey.currentContext!.findRenderObject()
//                                   as RenderBox;
//                           _showQuestionPopup(context, textField);
//                         },
//                       ),
//                     Expanded(
//                       child: TextField(
//                         key: _textFieldKey,
//                         controller: _messageController,
//                         focusNode: _focusNode,
//                         decoration: InputDecoration(
//                           hintText:
//                               'Ask about her ${initialMessages[_selectedTab]!}',
//                           border: OutlineInputBorder(),
//                           suffixIcon: _isGenerating
//                               ? IconButton(
//                                   icon: const Icon(Icons.stop_circle),
//                                   onPressed: _stopGeneration,
//                                 )
//                               : null,
//                         ),
//                         maxLines: null,
//                         textInputAction: TextInputAction.send,
//                         onSubmitted: handleSubmitted,
//                         enabled: !_isGenerating, // Disable during generation
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     IconButton(
//                       icon: const Icon(Icons.send),
//                       onPressed: _isLoading
//                           ? null
//                           : () => handleSubmitted(_messageController.text),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   _buildAppBar() {
//     AppBar(
//       // title: const Text('Anisha\'s AI Assistant'),
//       centerTitle: true,
//       title: _showDropdown
//           ? PreferredSize(
//               preferredSize: const Size.fromHeight(45),
//               child: Padding(
//                 padding: const EdgeInsets.only(bottom: 5.0),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).colorScheme.surface,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: DropdownButtonHideUnderline(
//                     child: DropdownButton<String>(
//                       value: _currentModel,
//                       isExpanded: false,
//                       hint: const Text('Gemma 2 (9B)'),
//                       items: _availableModels.entries.map((entry) {
//                         return DropdownMenuItem<String>(
//                           value: entry.value,
//                           child: Text(entry.key),
//                         );
//                       }).toList(),
//                       onChanged: (String? newValue) {
//                         if (newValue != null) {
//                           setState(() {
//                             _currentModel = newValue;
//                             gemmaService.switchModel(newValue);
//                             _messages.clear();
//                             _ollamaMessages.clear();
//                           });
//                         }
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//             )
//           : null,
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.delete_outline),
//           onPressed: () => showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text('Clear History'),
//               content: const Text(
//                   'Are you sure you want to clear all chat history?'),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     _clearHistory();
//                     Navigator.pop(context);
//                   },
//                   child: const Text('Clear'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   _buildMainChatScreen() {
//     print('type is : ${widget.screenType}');
//     // print('list is : ${widget.initialMessages}');

//     return Column(
//       children: [
//         if (_messages.isEmpty)
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 GradientText(
//                   'Hello!',
//                   colors: const [
//                     // Color.fromARGB(162, 125, 179, 224),
//                     // Color.fromARGB(143, 200, 105, 98),
//                     // Color.fromARGB(152, 114, 192, 184)
//                     // Colors.orange,
//                     // Colors.green,
//                     // Colors.white
//                     // Colors.blue,
//                     // Colors.teal,
//                     // Colors.red,
//                     // Color.fromARGB(233, 33, 149, 243),
//                     // Color.fromARGB(229, 255, 82, 82)
//                     Color.fromARGB(233, 80, 172, 247),
//                     Color.fromARGB(228, 249, 100, 100)
//                   ],
//                   style: const TextStyle(
//                     fontSize: 35,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 15), // Spacing between lines
//                 TypeWriter(
//                   controller: introController,
//                   builder: (context, value) {
//                     return GradientText(
//                       value.text,
//                       // textAlign: TextAlign.center,
//                       colors: const [
//                         Color.fromARGB(233, 80, 172, 247),
//                         Color.fromARGB(228, 249, 100, 100)
//                       ],
//                       style: const TextStyle(
//                         fontSize: 25,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         Expanded(
//           child: ListView.builder(
//             controller: _mainScrollController, // Use the new scroll controller
//             padding: const EdgeInsets.all(16),
//             itemCount: _messages.length + (_isGenerating ? 1 : 0),
//             itemBuilder: (context, index) {
//               if (index == _messages.length) {
//                 return _buildStopGenerationButton();
//               }
//               final message = _messages[index];
//               return MessageBubble(message: message);
//             },
//           ),
//         ),
//         if (_showInitialQuestions)
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.surface,
//               border: Border(
//                 top: BorderSide(
//                   color: Theme.of(context).colorScheme.outline,
//                 ),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(10),
//                   child: Text(
//                     'Start the conversation',
//                     style: Theme.of(context).textTheme.titleSmall,
//                   ),
//                 ),
//                 SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   padding: const EdgeInsets.symmetric(horizontal: 8),
//                   child: Row(
//                     children: [
//                       for (var question in _starterQuestions)
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 4),
//                           child: ActionChip(
//                             label: Text(question),
//                             onPressed: () => _handleFirstMessage(question),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         if (_isLoading)
//           const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: LinearProgressIndicator(),
//           ),
//         SafeArea(
//           child: Stack(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8.0),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.surface,
//                   border: Border(
//                     top: BorderSide(
//                       color: Theme.of(context).colorScheme.outline,
//                     ),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     if (!_showInitialQuestions) // Add question button when initial questions are hidden
//                       IconButton(
//                         icon: const Icon(Icons.quiz_outlined),
//                         onPressed: () {
//                           final RenderBox textField =
//                               _textFieldKey.currentContext!.findRenderObject()
//                                   as RenderBox;
//                           _showQuestionPopup(context, textField);
//                         },
//                       ),
//                     Expanded(
//                       child: TextField(
//                         key: _textFieldKey,
//                         controller: _messageController,
//                         focusNode: _focusNode,
//                         decoration: InputDecoration(
//                           hintText: 'Ask something',
//                           border: OutlineInputBorder(),
//                           suffixIcon: _isGenerating
//                               ? IconButton(
//                                   icon: const Icon(Icons.stop_circle),
//                                   onPressed: _stopGeneration,
//                                 )
//                               : null,
//                         ),
//                         maxLines: null,
//                         textInputAction: TextInputAction.send,
//                         onSubmitted: handleSubmitted,
//                         enabled: !_isGenerating, // Disable during generation
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     IconButton(
//                       icon: const Icon(Icons.send),
//                       onPressed: _isLoading
//                           ? null
//                           : () => handleSubmitted(_messageController.text),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
