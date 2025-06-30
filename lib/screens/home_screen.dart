
import 'package:clue/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _charactersFuture;

  @override
  void initState() {
    super.initState();
    print('[HomeScreen] initState 호출됨');
    _charactersFuture = _fetchCharacters();
  }

  Future<List<Map<String, dynamic>>> _fetchCharacters() async {
    print('[_fetchCharacters] 함수 시작');
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('[_fetchCharacters] 인증된 사용자 없음. 빈 목록 반환.');
        return []; // Return empty list if no user is logged in
      }
      print('[_fetchCharacters] 사용자 ID: ${user.id}');

      final response = await _supabase
          .from('characters')
          .select()
          .order('created_at', ascending: false);

      print('[_fetchCharacters] Supabase 응답: $response');
      final characters = response as List<Map<String, dynamic>>;
      print('[_fetchCharacters] ${characters.length}개의 캐릭터 가져옴.');
      print('[_fetchCharacters] 함수 성공적으로 완료.');
      return characters;
    } catch (e) {
      print('[_fetchCharacters] 에러 발생: $e');
      rethrow; // 에러를 다시 던져 FutureBuilder에서 처리하도록 함
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 캐릭터 목록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _supabase.auth.signOut();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _charactersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
          }
          final characters = snapshot.data!;
          if (characters.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_alt_1, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    '아직 생성된 캐릭터가 없습니다.\n아래 + 버튼을 눌러 첫 캐릭터를 만들어보세요!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(
                    character['name'] ?? '이름 없음',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      character['profile'] ?? '프로필 정보가 없습니다.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ),
                  onTap: () {
                    // TODO: Navigate to character detail screen
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatScreen()));
          if (result == true) {
            setState(() {
              _charactersFuture = _fetchCharacters();
            });
          }
        },
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
