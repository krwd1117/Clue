import 'package:flutter/material.dart';
import 'package:clue/features/character_creation/screens/chat_screen.dart';

class CharacterDetailScreen extends StatelessWidget {
  final Map<String, dynamic> character;

  const CharacterDetailScreen({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(character['name'] ?? '캐릭터 상세 정보'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              character['name'] ?? '이름 없음',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '성별: ${character['gender'] ?? '미상'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '나이: ${character['age'] ?? '미상'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '프로필:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              character['profile'] ?? '프로필 정보가 없습니다.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text(
              '연관 캐릭터',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            // TODO: Display related characters here
            Text(
              '아직 연관 캐릭터 정보가 없습니다.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(existingCharacter: character),
                    ),
                  );
                },
                child: const Text('연계 캐릭터 생성하기'),
              ),
            ),
            // TODO: Add more character details from 'character_data' if needed
          ],
        ),
      ),
    );
  }
}
