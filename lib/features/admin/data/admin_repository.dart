import '../../../core/database/postgres_service.dart';

class AdminRepository {
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final conn = await PostgresService.instance.connection;

      // Viviendas
      final totalViviendas =
          await conn.execute('SELECT COUNT(*) FROM viviendas');
      final viviendasOcupadas = await conn
          .execute('SELECT COUNT(*) FROM viviendas WHERE activo = true');

      // Residentes
      final residentes = await conn
          .execute('SELECT COUNT(*) FROM usuarios WHERE activo = true');

      // Expensas
      final expensasPendientes = await conn.execute(
        "SELECT COUNT(*) FROM expensas WHERE estado = 'PENDIENTE'::expensa_estado",
      );
      final expensasPagadas = await conn.execute(
        "SELECT COUNT(*) FROM expensas WHERE estado = 'PAGADA'::expensa_estado",
      );
      final totalCobrar = await conn.execute(
        "SELECT COALESCE(SUM(monto), 0) FROM expensas WHERE estado = 'PENDIENTE'::expensa_estado",
      );
      final totalCobrado = await conn.execute(
        "SELECT COALESCE(SUM(monto), 0) FROM expensas WHERE estado = 'PAGADA'::expensa_estado",
      );

      // Reservas
      final reservasActivas = await conn.execute(
        "SELECT COUNT(*) FROM reservas WHERE estado IN ('CONFIRMADA'::reserva_estado, 'PENDIENTE'::reserva_estado)",
      );

      // Visitantes hoy (de la tabla visitas, no visitantes)
      final visitantesHoy = await conn.execute(
        "SELECT COUNT(*) FROM visitas WHERE DATE(entrada) = CURRENT_DATE",
      );

      return {
        'total_viviendas': totalViviendas.first[0] as int,
        'viviendas_ocupadas': viviendasOcupadas.first[0] as int,
        'total_residentes': residentes.first[0] as int,
        'expensas_pendientes': expensasPendientes.first[0] as int,
        'expensas_pagadas': expensasPagadas.first[0] as int,
        'total_cobrar':
            (totalCobrar.first[0] as num?)?.toStringAsFixed(2) ?? '0.00',
        'total_cobrado':
            (totalCobrado.first[0] as num?)?.toStringAsFixed(2) ?? '0.00',
        'reservas_activas': reservasActivas.first[0] as int,
        'visitantes_hoy': visitantesHoy.first[0] as int,
      };
    } catch (e) {
      print('Error obteniendo estadísticas: $e');
      return {
        'total_viviendas': 0,
        'viviendas_ocupadas': 0,
        'total_residentes': 0,
        'expensas_pendientes': 0,
        'expensas_pagadas': 0,
        'total_cobrar': '0.00',
        'total_cobrado': '0.00',
        'reservas_activas': 0,
        'visitantes_hoy': 0,
      };
    }
  }

  Future<List<Map<String, dynamic>>> getResidents() async {
    try {
      final conn = await PostgresService.instance.connection;
      final results = await conn.execute(
        '''SELECT u.id, u.nombre_completo, u.email, u.telefono, 
           v.codigo as vivienda, u.activo
           FROM usuarios u
           LEFT JOIN viviendas v ON u.vivienda_id = v.id
           WHERE u.activo = true
           ORDER BY u.nombre_completo
           LIMIT 100''',
      );

      return results.map((row) {
        return {
          'id': row[0] as int,
          'nombre': row[1] as String,
          'email': row[2] as String,
          'telefono': row[3],
          'vivienda': row[4],
        };
      }).toList();
    } catch (e) {
      print('Error obteniendo residentes: $e');
      rethrow;
    }
  }
}
