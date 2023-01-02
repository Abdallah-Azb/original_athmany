import 'models.dart';

class TemporaryActions {
  final CategoriesAccessories categoriesAccessories;
  final bool action;

  TemporaryActions({
    this.categoriesAccessories,
    this.action,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TemporaryActions &&
        other.categoriesAccessories == categoriesAccessories &&
        other.action == action;
  }

  @override
  int get hashCode => categoriesAccessories.hashCode ^ action.hashCode;
}
