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
  bool _isGenerating = false;

  final List<String> _questions = [
    '캐릭터의 이름은 무엇인가요?',
    '캐릭터의 나이는 몇 살인가요?',
    '캐릭터의 성격 키워드를 3가지 정도 알려주세요. (예: 용감한, 냉정한, 유머러스한)',
    '캐릭터의 외모 특징을 설명해주세요. (예: 흑발, 푸른 눈, 큰 키)',
    '캐릭터의 배경이나 중요한 과거 사건이 있다면 알려주세요.',
  ];

  @override
  void initState() {
    super.initState();
    _postBotMessage(_questions[_questionIndex]);
  }

  void _postBotMessage(String text) {
    setState(() {
      _messages.insert(0, Message(text, MessageSender.bot));
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final userMessage = _controller.text;
      setState(() {
        _messages.insert(0, Message(userMessage, MessageSender.user));
        _controller.clear();
      });

      _processAnswer(userMessage);
    }
  }

  void _processAnswer(String answer) {
    final keys = ['name', 'age', 'personality', 'appearance', 'background'];
    _characterData[keys[_questionIndex]] = answer;

    _questionIndex++;

    if (_questionIndex < _questions.length) {
      _postBotMessage(_questions[_questionIndex]);
    } else {
      _postBotMessage('모든 질문에 답해주셨습니다. 아래 버튼을 눌러 프로필 생성을 시작하세요.');
    }
  }

  Future<void> _generateProfile() async {
    setState(() {
      _isGenerating = true;
      _messages.insert(0, Message('캐릭터 프로필을 생성 중입니다...', MessageSender.bot));
    });

    try {
      final profile = await _openAIService.createCharacterProfile(_characterData);
      
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('characters').insert({
          'user_id': user.id,
          'name': _characterData['name'],
          'profile': profile,
          'character_data': _characterData,
        });
      }

      setState(() {
        _messages.insert(0, Message('캐릭터 프로필이 생성되어 저장되었습니다!', MessageSender.bot));
      });

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pop(context, true); // 홈 화면에 변경 알림
      }

    } catch (e) {
      setState(() {
        _messages.insert(0, Message('프로필 생성 또는 저장에 실패했습니다: $e', MessageSender.bot));
      });
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 캐릭터 만들기'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isUser = message.sender == MessageSender.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isUser ? Theme.of(context).colorScheme.primary.withOpacity(0.9) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final bool allQuestionsAnswered = _questionIndex >= _questions.length;

    if (_isGenerating) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (allQuestionsAnswered) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _generateProfile,
          child: const Text('프로필 생성하기'),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _sendMessage(),
              decoration: const InputDecoration(
                hintText: '답변을 입력하세요...',
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
