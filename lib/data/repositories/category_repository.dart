import '../../domain/repositories/i_category_repository.dart';
import '../../domain/entities/category_model.dart';
import '../../infrastructure/database_service.dart';

/// Category Repository Implementation
/// Tuân thủ Dependency Inversion
class CategoryRepository implements ICategoryRepository {
  @override
  Future<List<CategoryModel>> getAllCategories() async {
    return DatabaseService.getAllCategories();
  }

  @override
  Future<List<CategoryModel>> getExpenseCategories() async {
    return DatabaseService.getExpenseCategories();
  }

  @override
  Future<List<CategoryModel>> getIncomeCategories() async {
    return DatabaseService.getIncomeCategories();
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    await DatabaseService.addCategory(category);
  }

  @override
  Future<void> updateCategory(int index, CategoryModel category) async {
    await DatabaseService.updateCategory(index, category);
  }

  @override
  Future<void> deleteCategory(int index) async {
    await DatabaseService.deleteCategory(index);
  }

  @override
  bool isCategoryInUse(String categoryName) {
    return DatabaseService.isCategoryInUse(categoryName);
  }
}
