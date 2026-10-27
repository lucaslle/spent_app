import 'package:equatable/equatable.dart';

import 'spend_category.dart';

class CategoryRule extends Equatable {
  const CategoryRule({required this.keyword, this.category});

  final String keyword;

  /// null = ignorer : l'opération est exclue des statistiques.
  final SpendCategory? category;

  bool get isIgnore => category == null;

  bool matches(String label) => label.toLowerCase().contains(keyword);

  @override
  List<Object?> get props => [keyword, category];
}

const defaultRules = [CategoryRule(keyword: 'offre confort')];
