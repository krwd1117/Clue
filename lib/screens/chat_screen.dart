import 'package:clue/models/message.dart';
import 'package:clue/services/openai_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  final OpenAIService _openAIService = OpenAIService(Supabase.instance.client);
  final Map<String, dynamic> _characterData = {};
  int _questionIndex = 0;

  final List<String> _questions = [
    '캐릭터의 이름은 무엇인가요?',
    '캐릭터의 나이는 몇 살인가요?',
    '캐릭터의 성격 키워드를 3가지 정도 알려주세요.',
    '캐릭터의 외모 특징을 설명해주세요.',
    '캐릭터의 배경 사건이나 중요한 과거를 알려주세요.',
  ];

  @override
  void initState() {
    super.initState();
    _postBotMessage(_questions[_questionIndex]);
  }

  void _postBotMessage(String text) {
    setState(() {
      _messages.add(Message(text, MessageSender.bot));
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final userMessage = _controller.text;
      setState(() {
        _messages.add(Message(userMessage, MessageSender.user));
        _controller.clear();
      });

      _processAnswer(userMessage);
    }
  }

  void _processAnswer(String answer) {
    switch (_questionIndex) {
      case 0:
        _characterData['name'] = answer;
        break;
      case 1:
        _characterData['age'] = answer;
        break;
      case 2:
        _characterData['personality'] = answer;
        break;
      case 3:
        _characterData['appearance'] = answer;
        break;
      case 4:
        _characterData['background'] = answer;
        break;
    }

    _questionIndex++;

    if (_questionIndex < _questions.length) {
      _postBotMessage(_questions[_questionIndex]);
    } else {
      _postBotMessage('모든 질문에 답해주셨습니다. 프로필 생성을 시작할까요?');
    }
  }

  Future<void> _generateProfile() async {
    _postBotMessage('프로필을 생성 중입니다...');
    try {
      final profile = await _openAIService.createCharacterProfile(_characterData);
      _postBotMessage('캐릭터 프로필이 생성되었습니다:\n$profile');
    } catch (e) {
      _postBotMessage('프로필 생성에 실패했습니다: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캐릭터 생성'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.sender == MessageSender.user
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: message.sender == MessageSender.user
                          ? Colors.blue[100]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(message.text),
                  ),
                );
              },
            ),
          ),
          if (_questionIndex >= _questions.length) // 모든 질문에 답한 후에만 버튼 표시
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _generateProfile,
                child: const Text('프로필 생성하기'),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '답변을 입력하세요...',}
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
