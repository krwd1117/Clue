import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _charactersFuture;

  @override
  void initState() {
    super.initState();
    _charactersFuture = _fetchCharacters();
  }

  Future<List<Map<String, dynamic>>> _fetchCharacters() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('FeedScreen: No authenticated user. Returning empty list.');
        return [];
      }
      final response = await _supabase
          .from('characters_with_user_info')
          .select()
          .eq('user_id', user.id) // user_id가 현재 로그인한 사용자와 일치하는 경우만 필터링
          .order('created_at', ascending: false);
      return response as List<Map<String, dynamic>>;
    } catch (e) {
      print('Error fetching characters for feed: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('피드'),
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
                  Icon(Icons.sentiment_dissatisfied, size: 50, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    '아직 공유된 캐릭터가 없어요.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '새로운 캐릭터를 만들고 공유해보세요!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.7, // Adjust as needed
            ),
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];
              return Card(
                elevation: 1, // Add a subtle elevation
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), // More rounded corners
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.auto_awesome, // A more generic, appealing icon
                            size: 60,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0), // Increased padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            character['name'] ?? '이름 없음',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith( // Larger title
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6), // Increased spacing
                          Text(
                            character['profile'] ?? '프로필 정보가 없습니다.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith( // Medium body text
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10), // Increased spacing
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              'by ${character['user_email'] ?? '알 수 없음'}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith( // Smaller label text
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
