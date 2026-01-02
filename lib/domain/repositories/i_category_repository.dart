import '../../models/category_model.dart';

/// Category Repository Interface
/// Tuân thủ Dependency Inversion Principle
abstract class ICategoryRepository {
  /// Get all categories
  Future<List<CategoryModel>> getAllCategories();

  /// Get expense categories
  Future<List<CategoryModel>> getExpenseCategories();

  /// Get income categories
  Future<List<CategoryModel>> getIncomeCategories();

  /// Add new category
  Future<void> addCategory(CategoryModel category);

  /// Update category
  Future<void> updateCategory(int index, CategoryModel category);

  /// Delete category
  Future<void> deleteCategory(int index);

  /// Check if category is in use
  bool isCategoryInUse(String categoryName);
}
