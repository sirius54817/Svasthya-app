import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotService {
  static const String _apiKey = 'AIzaSyCWyfg_wlLmTGiAjbK5lkNYbhehQn6FUGY';
  static const String _modelName = 'gemini-1.5-flash';
  
  late final GenerativeModel _model;
  late final ChatSession _chat;
  
  ChatbotService() {
    _model = GenerativeModel(
      model: _modelName,
      apiKey: _apiKey,
      systemInstruction: Content.system(
        'You are Svasthya AI, a helpful health and fitness assistant. '
        'You are part of the Svasthya app, which helps users with health tracking, '
        'exercise routines, and wellness guidance. Provide helpful, accurate, and '
        'supportive responses about health, fitness, nutrition, and wellness. '
        'Keep your responses concise but informative. Always encourage users to '
        'consult healthcare professionals for serious medical concerns.'
      ),
    );
    _chat = _model.startChat();
  }
  
  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text ?? 'Sorry, I could not process your request.';
    } catch (e) {
      print('Error sending message to chatbot: $e');
      return 'Sorry, I\'m having trouble connecting right now. Please try again later.';
    }
  }
  
  void clearHistory() {
    _chat = _model.startChat();
  }
}