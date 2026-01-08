import '../entities/transaction_model.dart';
import '../repositories/i_transaction_repository.dart';

/// UseCase để thêm transaction mới
/// Tuân thủ Single Responsibility Principle - chỉ lo thêm transaction
class AddTransactionUseCase {
  final ITransactionRepository _repository;

  AddTransactionUseCase(this._repository);

  /// Execute the use case
  Future<void> execute(TransactionModel transaction) async {
    await _repository.addTransaction(transaction);
  }
}
