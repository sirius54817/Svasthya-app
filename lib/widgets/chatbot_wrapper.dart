import 'package:flutter/material.dart';
import '../widgets/floating_chatbot.dart';

class ChatbotWrapper extends StatelessWidget {
  final Widget child;

  const ChatbotWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        const FloatingChatbot(),
      ],
    );
  }
}