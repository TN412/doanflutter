import '../repositories/i_settings_repository.dart';

/// UseCase để export data
/// Tuân thủ Single Responsibility Principle
class ExportDataUseCase {
  final ISettingsRepository _repository;

  ExportDataUseCase(this._repository);

  /// Execute the use case
  Future<Map<String, dynamic>> execute() async {
    return await _repository.exportToJson();
  }
}
