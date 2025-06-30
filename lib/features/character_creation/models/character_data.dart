class CharacterCategory {
  final int id;
  final int stepOrder;
  final String name;
  final String? description;
  final List<CharacterOption> options;

  CharacterCategory({
    required this.id,
    required this.stepOrder,
    required this.name,
    this.description,
    this.options = const [],
  });

  factory CharacterCategory.fromJson(Map<String, dynamic> json) {
    return CharacterCategory(
      id: json['id'] as int,
      stepOrder: json['step_order'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }
}

class CharacterOption {
  final int id;
  final int categoryId;
  final String value;
  final String? description;
  final bool isDefault;
  final int? displayOrder;

  CharacterOption({
    required this.id,
    required this.categoryId,
    required this.value,
    this.description,
    required this.isDefault,
    this.displayOrder,
  });

  factory CharacterOption.fromJson(Map<String, dynamic> json) {
    return CharacterOption(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      value: json['value'] as String,
      description: json['description'] as String?,
      isDefault: json['is_default'] as bool,
      displayOrder: json['display_order'] as int?,
    );
  }
}
