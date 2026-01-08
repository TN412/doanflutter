import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 5)
class UserModel extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String password; // Lưu ý: Trong thực tế nên mã hóa password

  @HiveField(2)
  String fullName;

  UserModel({
    required this.username,
    required this.password,
    required this.fullName,
  });
}
