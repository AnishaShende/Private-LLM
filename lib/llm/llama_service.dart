import 'package:groq_sdk/groq_sdk.dart';
import 'package:private_llm/llm/prompts.dart';

class LlamaService {
  final Groq _groq;
  String modelId;
  late final GroqChat _chat;
  final List<Map<String, String>> _conversationHistory = [];

  LlamaService(String apiKey, this.modelId) : _groq = Groq(apiKey) {
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

    _chat.addMessageWithoutSending(Prompts.systemPrompt);
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
              content: msg['content']!,
            ))
        .toList();

    // debugPrint("printing conversation history: $_conversationHistory");

    // debugPrint('Heres the enhanced prompt: $enhancedPrompt');
    messages.add(GroqMessage(
      role: GroqMessageRole.assistant,
      content: enhancedPrompt,
    ));

    // debugPrint("Here are the messages: $messages");

    _chat.addMessageWithoutSending(enhancedPrompt);

    final (response, _) =
        await _chat.sendMessage(prompt, role: GroqMessageRole.user);
    final responseText = response.choices.first.message;

    _conversationHistory.add({
      'role': 'assistant',
      'content': responseText,
    });

    return responseText;
  }
}
