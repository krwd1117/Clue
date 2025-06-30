import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clue/features/character_creation/models/character_data.dart';

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

  Future<List<CharacterCategory>> getCharacterCategoriesWithOptions() async {
    try {
      final List<Map<String, dynamic>> categoriesData = await _supabase
          .from('character_category')
          .select()
          .order('step_order', ascending: true);

      final List<Map<String, dynamic>> optionsData = await _supabase
          .from('character_option')
          .select()
          .order('display_order', ascending: true);

      final List<CharacterCategory> categories = categoriesData.map((categoryJson) {
        final category = CharacterCategory.fromJson(categoryJson);
        final categoryOptions = optionsData
            .where((optionJson) => optionJson['category_id'] == category.id)
            .map((optionJson) => CharacterOption.fromJson(optionJson))
            .toList();
        return CharacterCategory(
          id: category.id,
          stepOrder: category.stepOrder,
          name: category.name,
          description: category.description,
          options: categoryOptions,
        );
      }).toList();

      return categories;
    } catch (e) {
      throw 'Error fetching character categories and options: $e';
    }
  }
}
