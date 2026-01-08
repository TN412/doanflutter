import '../entities/transaction_model.dart';
import '../repositories/i_transaction_repository.dart';

/// UseCase để update transaction
/// Tuân thủ Single Responsibility Principle
class UpdateTransactionUseCase {
  final ITransactionRepository _repository;

  UpdateTransactionUseCase(this._repository);

  /// Execute the use case
  Future<void> execute(int index, TransactionModel transaction) async {
    await _repository.updateTransaction(index, transaction);
  }
}
