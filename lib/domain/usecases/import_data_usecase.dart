import '../repositories/i_settings_repository.dart';

/// UseCase để import data
/// Tuân thủ Single Responsibility Principle
class ImportDataUseCase {
  final ISettingsRepository _repository;

  ImportDataUseCase(this._repository);

  /// Execute the use case
  Future<void> execute(Map<String, dynamic> data) async {
    await _repository.importFromJson(data);
  }
}
