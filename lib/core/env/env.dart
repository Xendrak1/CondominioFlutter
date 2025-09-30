import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get dbHost => dotenv.env['DB_HOST'] ?? 'localhost';
  static int get dbPort =>
      int.tryParse(dotenv.env['DB_PORT'] ?? '5432') ?? 5432;
  static String get dbName => dotenv.env['DB_NAME'] ?? 'Condominio';
  static String get dbUser => dotenv.env['DB_USER'] ?? 'postgres';
  static String get dbPassword => dotenv.env['DB_PASSWORD'] ?? '';
}
