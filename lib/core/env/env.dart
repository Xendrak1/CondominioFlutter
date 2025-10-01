import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // URL del backend Django REST
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'https://tu-backend-django.azurewebsites.net';

  // Para desarrollo local (emulador Android)
  static const String localUrl = 'http://10.0.2.2:8000';

  // Para dispositivo físico (usa la IP de tu PC)
  static const String physicalDeviceUrl = 'http://192.168.1.50:8000';

  // Configuración de base de datos (ya no se usa - se conecta vía API)
  static String get dbHost => dotenv.env['DB_HOST'] ?? 'localhost';
  static int get dbPort =>
      int.tryParse(dotenv.env['DB_PORT'] ?? '5432') ?? 5432;
  static String get dbName => dotenv.env['DB_NAME'] ?? 'Condominio';
  static String get dbUser => dotenv.env['DB_USER'] ?? 'postgres';
  static String get dbPassword => dotenv.env['DB_PASSWORD'] ?? '';
}
