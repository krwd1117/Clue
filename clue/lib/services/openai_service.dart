import 'package:supabase_flutter/supabase_flutter.dart';

class OpenAIService {
  final SupabaseClient _supabase;

  OpenAIService(this._supabase);

  Future<String> createCharacterProfile(Map<String, dynamic> characterData) async {
    try {
      final response = await _supabase.functions.invoke(
        'create-character', // Edge Function 이름
        body: characterData,
      );

      if (response.status != 200) {
        throw 'Failed to create character profile: ${response.data}';
      }

      return response.data['profile'];
    } catch (e) {
      throw 'Error calling Edge Function: $e';
    }
  }
}
