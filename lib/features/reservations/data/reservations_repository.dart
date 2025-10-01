import 'package:postgres/postgres.dart';
import '../../../core/database/postgres_service.dart';

class ReservationsRepository {
  Future<List<Map<String, dynamic>>> getAreas() async {
    try {
      print('📍 [AREAS] Intentando obtener áreas comunes...');
      final conn = await PostgresService.instance.connection;
      print('📍 [AREAS] Conexión obtenida, ejecutando query...');

      // Ajustado a la estructura REAL de Azure
      final results = await conn.execute(
        'SELECT id, nombre, requiere_pago, tarifa FROM areas_comunes ORDER BY nombre',
      );

      print(
          '📍 [AREAS] Query ejecutado exitosamente. Filas: ${results.length}');

      final areas = results.map((row) {
        return {
          'id': row[0] as int,
          'nombre': row[1] as String,
          'requiere_pago': row[2] as bool,
          'tarifa': row[3],
        };
      }).toList();

      print('📍 [AREAS] Áreas procesadas: ${areas.length}');
      for (var area in areas) {
        print('   - ${area['nombre']} (ID: ${area['id']})');
      }

      return areas;
    } catch (e, stackTrace) {
      print('❌ [AREAS] Error obteniendo áreas: $e');
      print('❌ [AREAS] StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMyReservations() async {
    try {
      print('📅 [RESERVAS] Intentando obtener reservas...');
      final conn = await PostgresService.instance.connection;
      print('📅 [RESERVAS] Conexión obtenida, ejecutando query...');

      // Ajustado a la estructura REAL de Azure (con persona_id, qr_reserva, etc.)
      final results = await conn.execute(
        '''SELECT r.id, r.codigo, ac.nombre as area_nombre, r.fecha, 
           r.hora_inicio, r.hora_fin, r.estado::text 
           FROM reservas r 
           JOIN areas_comunes ac ON r.area_id = ac.id 
           ORDER BY r.fecha DESC, r.hora_inicio DESC 
           LIMIT 50''',
      );

      print(
          '📅 [RESERVAS] Query ejecutado exitosamente. Filas: ${results.length}');

      final reservas = results.map((row) {
        // Convertir timestamps a strings de hora (HH:MM)
        final horaInicio =
            (row[4] as DateTime).toIso8601String().substring(11, 16);
        final horaFin =
            (row[5] as DateTime).toIso8601String().substring(11, 16);

        return {
          'id': row[0] as int,
          'codigo': row[1] as String,
          'area_nombre': row[2] as String,
          'fecha': row[3] as DateTime,
          'hora_inicio': horaInicio,
          'hora_fin': horaFin,
          'estado': row[6] as String,
        };
      }).toList();

      print('📅 [RESERVAS] Reservas procesadas: ${reservas.length}');
      for (var reserva in reservas) {
        print(
            '   - ${reserva['codigo']}: ${reserva['area_nombre']} - ${reserva['estado']}');
      }

      return reservas;
    } catch (e, stackTrace) {
      print('❌ [RESERVAS] Error obteniendo reservas: $e');
      print('❌ [RESERVAS] StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createReservation({
    required int areaId,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
  }) async {
    try {
      print('➕ [CREAR RESERVA] Iniciando creación de reserva...');
      print('   Área ID: $areaId');
      print('   Fecha: $fecha');
      print('   Horario: $horaInicio - $horaFin');

      final conn = await PostgresService.instance.connection;
      print('➕ [CREAR RESERVA] Conexión obtenida');

      // Generar código único
      final codigo = 'R-${DateTime.now().millisecondsSinceEpoch}';
      final qrReserva = 'RESERVA-$codigo';

      // Convertir horas a timestamps
      final horaInicioTimestamp = DateTime(
          fecha.year,
          fecha.month,
          fecha.day,
          int.parse(horaInicio.split(':')[0]),
          int.parse(horaInicio.split(':')[1]));
      final horaFinTimestamp = DateTime(fecha.year, fecha.month, fecha.day,
          int.parse(horaFin.split(':')[0]), int.parse(horaFin.split(':')[1]));

      print('➕ [CREAR RESERVA] Código generado: $codigo');
      print('➕ [CREAR RESERVA] Ejecutando INSERT...');

      // Ajustado a la estructura REAL (persona_id, qr_reserva, etc.)
      // Usar sintaxis PostgreSQL directa sin parámetros nombrados
      final result = await conn.execute(
        Sql.named('''INSERT INTO reservas 
           (codigo, persona_id, area_id, vivienda_id, fecha, 
            hora_inicio, hora_fin, estado, qr_reserva) 
           VALUES (@codigo, 1, @area_id, 1, @fecha, @hora_inicio, @hora_fin, 'CONFIRMADA'::reserva_estado, @qr) 
           RETURNING id'''),
        parameters: {
          'codigo': codigo,
          'area_id': areaId,
          'fecha': fecha,
          'hora_inicio': horaInicioTimestamp,
          'hora_fin': horaFinTimestamp,
          'qr': qrReserva,
        },
      );

      final reservaId = result.first[0] as int;
      print('✅ [CREAR RESERVA] Reserva creada exitosamente!');
      print('   ID en BD: $reservaId');
      print('   Código: $codigo');

      return {
        'id': reservaId,
        'codigo': codigo,
        'qr_code': qrReserva,
        'estado': 'CONFIRMADA',
      };
    } catch (e, stackTrace) {
      print('❌ [CREAR RESERVA] Error creando reserva: $e');
      print('❌ [CREAR RESERVA] StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<void> cancelReservation(int reservationId) async {
    try {
      print('🚫 [CANCELAR] Cancelando reserva ID: $reservationId');
      final conn = await PostgresService.instance.connection;
      await conn.execute(
        Sql.named(
            "UPDATE reservas SET estado = 'CANCELADA'::reserva_estado WHERE id = @id"),
        parameters: {'id': reservationId},
      );
      print('✅ [CANCELAR] Reserva cancelada exitosamente');
    } catch (e, stackTrace) {
      print('❌ [CANCELAR] Error cancelando reserva: $e');
      print('❌ [CANCELAR] StackTrace: $stackTrace');
      rethrow;
    }
  }
}
