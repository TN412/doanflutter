import '../../domain/repositories/i_transaction_repository.dart';
import '../../domain/entities/transaction_model.dart';
import '../../infrastructure/database_service.dart';

/// Transaction Repository Implementation
/// Tuân thủ Dependency Inversion - Implement interface từ domain layer
class TransactionRepository implements ITransactionRepository {
  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    return DatabaseService.getAllTransactions();
  }

  @override
  Future<TransactionModel?> getTransactionByIndex(int index) async {
    return DatabaseService.getTransaction(index);
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    await DatabaseService.addTransaction(transaction);
  }

  @override
  Future<void> updateTransaction(
      int index, TransactionModel transaction) async {
    await DatabaseService.updateTransaction(index, transaction);
  }

  @override
  Future<void> deleteTransaction(int index) async {
    await DatabaseService.deleteTransaction(index);
  }

  @override
  Future<void> deleteAllTransactions() async {
    await DatabaseService.deleteAllTransactions();
  }

  @override
  int findTransactionIndexById(String id) {
    final transactions = DatabaseService.getAllTransactions();
    return transactions.indexWhere((t) => t.id == id);
  }
}
