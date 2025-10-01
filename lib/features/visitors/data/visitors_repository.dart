import 'package:postgres/postgres.dart';
import '../../../core/database/postgres_service.dart';

class VisitorsRepository {
  Future<List<Map<String, dynamic>>> getVisitors() async {
    try {
      print('👥 [VISITANTES] Obteniendo visitantes...');
      final conn = await PostgresService.instance.connection;

      // Estructura real: visitantes + visitas
      final results = await conn.execute(
        '''SELECT v.id, vt.nombres, vt.apellidos, vt.num_doc, 
           v.entrada, v.salida, v.medio, 
           viv.codigo as vivienda_codigo
           FROM visitas v
           JOIN visitantes vt ON v.visitante_id = vt.id
           JOIN viviendas viv ON v.vivienda_destino_id = viv.id
           ORDER BY v.entrada DESC 
           LIMIT 50''',
      );

      print('👥 [VISITANTES] Query ejecutado. Filas: ${results.length}');

      return results.map((row) {
        return {
          'id': row[0] as int,
          'nombres': row[1] as String, // nombres separado
          'apellidos': row[2] as String?, // apellidos separado
          'nombre': '${row[1]} ${row[2] ?? ''}', // nombre completo
          'num_doc': row[3] as String?,
          'documento': row[3] as String?,
          'fecha_visita': row[4] as DateTime?, // Para compatibilidad con UI
          'fecha': row[4] as DateTime?,
          'hora_entrada': row[4], // entrada completa
          'hora_salida': row[5], // salida (puede ser null)
          'qr_code': 'VISIT-${row[0]}', // Generar QR code simple
          'estado': row[5] == null ? 'EN_PROPIEDAD' : 'SALIO',
          'vivienda': row[7] as String?,
        };
      }).toList();
    } catch (e, stackTrace) {
      print('❌ [VISITANTES] Error obteniendo visitantes: $e');
      print('❌ [VISITANTES] StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> generateVisitorQR({
    required String nombre,
    required String documento,
    required DateTime fecha,
  }) async {
    try {
      print('➕ [CREAR VISITANTE] Creando visitante...');
      final conn = await PostgresService.instance.connection;

      // Separar nombre en nombres y apellidos (simplificado)
      final partes = nombre.split(' ');
      final nombres = partes.isNotEmpty ? partes[0] : nombre;
      final apellidos = partes.length > 1 ? partes.sublist(1).join(' ') : '';

      // Insertar visitante (usar Sql.named para parámetros)
      final visitanteResult = await conn.execute(
        Sql.named('''INSERT INTO visitantes (nombres, apellidos, num_doc) 
           VALUES (@nombres, @apellidos, @num_doc) 
           RETURNING id'''),
        parameters: {
          'nombres': nombres,
          'apellidos': apellidos,
          'num_doc': documento,
        },
      );

      final visitanteId = visitanteResult.first[0] as int;

      // Crear visita programada (vivienda_id = 1 por defecto) usando Sql.named
      final visitaResult = await conn.execute(
        Sql.named(
            '''INSERT INTO visitas (visitante_id, vivienda_destino_id, entrada, medio) 
           VALUES (@visitante_id, 1, @fecha, 'QR') 
           RETURNING id'''),
        parameters: {
          'visitante_id': visitanteId,
          'fecha': fecha,
        },
      );

      final visitaId = visitaResult.first[0] as int;
      final qrCode = 'VISIT-$visitaId';

      print(
          '✅ [CREAR VISITANTE] Visitante creado: ID $visitanteId, Visita ID $visitaId');

      return {
        'id': visitaId,
        'qr_code': qrCode,
        'nombre': nombre,
        'documento': documento,
        'fecha': fecha,
      };
    } catch (e, stackTrace) {
      print('❌ [CREAR VISITANTE] Error: $e');
      print('❌ [CREAR VISITANTE] StackTrace: $stackTrace');
      rethrow;
    }
  }
}
