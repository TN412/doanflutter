import '../repositories/i_transaction_repository.dart';

/// UseCase để xóa transaction
/// Tuân thủ Single Responsibility Principle
class DeleteTransactionUseCase {
  final ITransactionRepository _repository;

  DeleteTransactionUseCase(this._repository);

  /// Execute the use case
  Future<void> execute(int index) async {
    await _repository.deleteTransaction(index);
  }
}
