import 'package:clue/features/character_creation/models/message.dart';
import 'package:clue/features/character_creation/models/character_data.dart';
import 'package:clue/features/character_creation/services/openai_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic>? existingCharacter;

  const ChatScreen({super.key, this.existingCharacter});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  final GlobalKey<AnimatedListState> _animatedListKey =
      GlobalKey<AnimatedListState>();
  final ScrollController _scrollController = ScrollController();
  final OpenAIService _openAIService = OpenAIService(Supabase.instance.client);
  final Map<String, dynamic> _characterData = {};
  int _questionIndex = 0;
  bool _isGenerating = false;
  bool _isLoadingCategories = true;
  List<CharacterCategory> _categories = [];
  CharacterCategory? _currentCategory;

  @override
  void initState() {
    super.initState();
    _fetchCategoriesAndStartChat();
    if (widget.existingCharacter != null) {
      _postBotMessage(
          '${widget.existingCharacter!['name']}와(과) 연계된 캐릭터를 생성합니다. 어떤 관계인가요?');
    }
  }

  Future<void> _fetchCategoriesAndStartChat() async {
    try {
      _categories = await _openAIService.getCharacterCategoriesWithOptions();
      setState(() {
        _isLoadingCategories = false;
      });
      _moveToNextQuestion();
    } catch (e) {
      _messages.add(Message('카테고리 로딩 실패: $e', MessageSender.bot));
      _animatedListKey.currentState?.insertItem(_messages.length - 1);
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  void _postBotMessage(String text) {
    _messages.add(Message(text, MessageSender.bot));
    _animatedListKey.currentState?.insertItem(_messages.length - 1);
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final userMessage = _controller.text;
      _messages.add(Message(userMessage, MessageSender.user));
      _animatedListKey.currentState?.insertItem(_messages.length - 1);
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      _controller.clear();

      _processAnswer(userMessage);
    }
  }

  void _processAnswer(String answer) {
    if (_currentCategory != null) {
      _characterData[_currentCategory!.name] = answer;
    }
    setState(() { // setState 추가
      _moveToNextQuestion();
    });
  }

  void _moveToNextQuestion() {
    if (_questionIndex < _categories.length) {
      _currentCategory = _categories[_questionIndex];
      String questionText =
          _currentCategory!.description ?? _currentCategory!.name;
      _postBotMessage(questionText);
      _questionIndex++;
    } else {
      _postBotMessage('모든 질문에 답해주셨습니다. 아래 버튼을 눌러 프로필 생성을 시작하세요.');
    }
  }

  Future<void> _generateProfile() async {
    setState(() {
      _isGenerating = true;
    });
    _messages.add(Message('캐릭터 프로필을 생성 중입니다...', MessageSender.bot));
    _animatedListKey.currentState?.insertItem(_messages.length - 1);

    try {
      final profile = await _openAIService.createCharacterProfile(
        _characterData,
        existingCharacter: widget.existingCharacter,
      );

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('characters').insert({
          'user_id': user.id,
          'name': _characterData['name'],
          'gender': _characterData['gender'],
          'age': _characterData['age'],
          'appearance': _characterData['appearance'],
          'backstory': _characterData['backstory'],
          'conflict': _characterData['conflict'],
          'narrative': _characterData['narrative'],
          'profile': profile,
          'character_data': _characterData, // 모든 질문-답변 데이터를 저장
        });
      }

      _messages.add(Message('캐릭터 프로필이 생성되어 저장되었습니다!', MessageSender.bot));
      _animatedListKey.currentState?.insertItem(_messages.length - 1);

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CharacterDetailScreen(character: {
              'name': _characterData['name'],
              'gender': _characterData['gender'],
              'age': _characterData['age'],
              'profile': profile,
              'character_data': _characterData,
            }),
          ),
        );
      }
    } catch (e) {
      _messages.add(Message('프로필 생성 또는 저장에 실패했습니다: $e', MessageSender.bot));
      _animatedListKey.currentState?.insertItem(_messages.length - 1);
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('새 캐릭터 만들기')),
      body: Column(
        children: [
          Expanded(
            child: AnimatedList(
              key: _animatedListKey,
              controller: _scrollController,
              initialItemCount: _messages.length,
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (context, index, animation) {
                final message = _messages[index];
                return SizeTransition(
                  sizeFactor: animation,
                  child: _buildMessageBubble(message),
                );
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
          color: isUser
              ? Theme.of(context).colorScheme.primary.withOpacity(0.9)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final bool allQuestionsAnswered = _questionIndex >= _categories.length;

    if (_isLoadingCategories || _isGenerating) {
      print('[ChatScreen] _buildBottomBar: 로딩 중 또는 생성 중');
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (allQuestionsAnswered) {
      print('[ChatScreen] _buildBottomBar: 모든 질문에 답변 완료');
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _generateProfile,
          child: const Text('프로필 생성하기'),
        ),
      );
    }

    // Always show the text input field
    Widget textInputField = Container(
      padding: EdgeInsets.fromLTRB(
        8.0,
        8.0,
        8.0,
        8.0 + MediaQuery.of(context).padding.bottom,
      ),
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
            icon: Icon(
              Icons.send,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );

    // Conditionally show options above the text input field
    if (_currentCategory != null && _currentCategory!.options.isNotEmpty) {
      print('[ChatScreen] _buildBottomBar: 선택지 표시 (카테고리: ${_currentCategory!.name})');
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: _currentCategory!.options.map((option) {
                return ChoiceChip(
                  label: Text(option.value),
                  selected: false, // Always false as we don't track selection here
                  onSelected: (selected) {
                    _messages.add(Message(option.value, MessageSender.user));
                    _animatedListKey.currentState?.insertItem(_messages.length - 1);
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                    _processAnswer(option.value);
                  },
                );
              }).toList(),
            ),
          ),
          textInputField,
        ],
      );
    }

    print('[ChatScreen] _buildBottomBar: 텍스트 입력 필드만 표시 (카테고리: ${_currentCategory?.name ?? '없음'})');
    return textInputField;
  }
}
