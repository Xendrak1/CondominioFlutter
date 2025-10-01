import 'package:postgres/postgres.dart';
import '../env/env.dart';

class PostgresService {
  static PostgresService? _instance;
  Connection? _connection;

  PostgresService._();

  static PostgresService get instance {
    _instance ??= PostgresService._();
    return _instance!;
  }

  Future<Connection> get connection async {
    if (_connection == null || _connection!.isOpen == false) {
      print('🔌 Conectando a PostgreSQL Azure...');
      print('   Host: ${EnvConfig.dbHost}');
      print('   Database: ${EnvConfig.dbName}');
      print('   User: ${EnvConfig.dbUser}');

      try {
        _connection = await Connection.open(
          Endpoint(
            host: EnvConfig.dbHost,
            port: EnvConfig.dbPort,
            database: EnvConfig.dbName,
            username: EnvConfig.dbUser,
            password: EnvConfig.dbPassword,
          ),
          settings: const ConnectionSettings(
            sslMode: SslMode.require, // Azure requiere SSL
          ),
        );
        print('✅ Conexión exitosa a PostgreSQL Azure!');
      } catch (e) {
        print('❌ Error conectando a PostgreSQL Azure: $e');
        rethrow;
      }
    }
    return _connection!;
  }

  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}
