import 'package:groq_sdk/groq_sdk.dart';

class GemmaService {
  final Groq _groq;
  String modelId;
  late final GroqChat _chat;
  final List<Map<String, String>> _conversationHistory = [];
  final String _systemPrompt = """
    You are Anisha's AI Assistant, trained on the data of Anisha Shende, a 20-year-old tech enthusiast, Flutter developer, and AI researcher from India. You embody Anisha's friendly, knowledgeable, and professional personality while reflecting her expertise and unique character.

    Your purpose is to provide accurate, professional, and engaging responses to questions about Anisha's personal background, academic achievements, skills, projects, career aspirations, and other relevant topics. Don't make up any facts use proper relevant context to answer the questions asked by the user. 

    Response Guidelines:
    Perspective: Always refer to Anisha in the third person, as you are her virtual assistant.

    Tone:
    Use a friendly and casual tone for personal or fun questions.
    Be concise and professional for queries from recruiters or collaborators.
    Provide detailed and technical explanations for questions about her projects, skills, or expertise.
    Stay informative and concise while maintaining a warm and approachable tone.
    Knowledge Representation: Showcase Anisha's technical expertise, achievements, and interests when relevant.

    Limitations: For questions outside your training data, politely acknowledge your limitations and suggest contacting Anisha directly for further details. For fun or playful questions, you can respond with humor, such as saying, “Well, it's a secret. 😉”

    Engagement: Maintain Anisha's enthusiastic personality in all responses. Use casual phrases like "bro" or emojis when appropriate for informal conversations, ensuring your tone aligns with Anisha's approachable demeanor.

    Remember: Short responses for general queries, comprehensive details for technical/project questions, and polite deflection for irrelevant topics.

    Primary Objective: Your goal is to provide accurate, helpful, and engaging responses that reflect Anisha's work, projects, skills, and aspirations, enhancing the user's understanding while staying true to her personality.
  """;

  GemmaService(String apiKey, this.modelId) : _groq = Groq(apiKey) {
    _initChat();
  }

  void _initChat() {
    _chat = _groq.startNewChat(
      modelId,
      settings: GroqChatSettings(
        temperature: 0.7,
        maxTokens: 4096,
      ),
    );

    _chat.addMessageWithoutSending(_systemPrompt);
    // _conversationHistory.add({
    //   'role': 'system',
    //   'content': _systemPrompt,
    // });
  }

  void switchModel(String newModelId) {
    modelId = newModelId;
    _chat.switchModel(newModelId);
  }

  Future<String> generateResponse(
      String prompt, GroqMessageRole role, String enhancedPrompt) async {
    _conversationHistory.add({
      'role': 'user',
      'content': prompt,
    });

    final messages = _conversationHistory
        .map((msg) => GroqMessage(
              role: msg['role'] == 'system'
                  ? GroqMessageRole.system
                  : GroqMessageRole.user,
              // : msg['role'] == 'user'
              //     ? GroqMessageRole.user
              //     : GroqMessageRole.system,
              content: msg['content']!,
            ))
        .toList();

    // print("printing conversation history: $_conversationHistory");

    // final request = _groq.startNewChat(
    //   // messages: messages,
    //   modelId,
    //   settings: GroqChatSettings(
    //     temperature: 0.7,
    //     maxTokens: 4096,
    //   ),
    // );

    print('Heres the enhanced prompt: $enhancedPrompt');
    messages.add(GroqMessage(
      role: GroqMessageRole.assistant,
      content: enhancedPrompt,
    ));

    // print("Here are the messages: $messages");

    _chat.addMessageWithoutSending(enhancedPrompt);

    final (response, _) =
        await _chat.sendMessage(prompt, role: GroqMessageRole.user);
    // final response = await _groq.chatCompletion(request);
    final responseText = response.choices.first.message;

    _conversationHistory.add({
      'role': 'assistant',
      'content': responseText,
    });

    return responseText;
  }

  // void clearHistory() {
  //   _conversationHistory.clear();
  //   _conversationHistory.add({
  //     'role': 'system',
  //     'content': _systemPrompt,
  //   });
  // }
}
