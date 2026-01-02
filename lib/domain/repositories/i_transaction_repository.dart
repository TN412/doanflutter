import '../../models/transaction_model.dart';

/// Transaction Repository Interface
/// Tuân thủ Dependency Inversion Principle - High-level module không phụ thuộc vào low-level
abstract class ITransactionRepository {
  /// Get all transactions
  Future<List<TransactionModel>> getAllTransactions();

  /// Get transaction by index
  Future<TransactionModel?> getTransactionByIndex(int index);

  /// Add new transaction
  Future<void> addTransaction(TransactionModel transaction);

  /// Update existing transaction
  Future<void> updateTransaction(int index, TransactionModel transaction);

  /// Delete transaction
  Future<void> deleteTransaction(int index);

  /// Delete all transactions
  Future<void> deleteAllTransactions();

  /// Find transaction index by ID
  int findTransactionIndexById(String id);
}
