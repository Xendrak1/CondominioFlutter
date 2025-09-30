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
      _connection = await Connection.open(
        Endpoint(
          host: EnvConfig.dbHost,
          port: EnvConfig.dbPort,
          database: EnvConfig.dbName,
          username: EnvConfig.dbUser,
          password: EnvConfig.dbPassword,
        ),
        settings: const ConnectionSettings(sslMode: SslMode.disable),
      );
    }
    return _connection!;
  }

  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}
