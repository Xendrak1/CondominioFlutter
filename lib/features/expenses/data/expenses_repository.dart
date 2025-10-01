import '../../../core/database/postgres_service.dart';

class ExpensesRepository {
  Future<List<Map<String, dynamic>>> getExpenses({int? viviendaId}) async {
    try {
      final conn = await PostgresService.instance.connection;

      String query = '''
        SELECT e.id, e.codigo, e.periodo, e.monto, e.vencimiento, 
               e.estado::text, v.codigo as vivienda_codigo
        FROM expensas e
        JOIN viviendas v ON e.vivienda_id = v.id
      ''';

      if (viviendaId != null) {
        query += ' WHERE e.vivienda_id = @vivienda_id';
      }

      query += ' ORDER BY e.vencimiento DESC LIMIT 50';

      final results = await conn.execute(
        query,
        parameters: viviendaId != null ? {'vivienda_id': viviendaId} : null,
      );

      return results.map((row) {
        return {
          'id': row[0] as int,
          'codigo': row[1] as String,
          'periodo': row[2] as String,
          'monto': row[3],
          'vencimiento': row[4] as DateTime,
          'estado': row[5] as String,
          'vivienda_codigo': row[6] as String,
        };
      }).toList();
    } catch (e) {
      print('Error obteniendo expensas: $e');
      rethrow;
    }
  }
}
