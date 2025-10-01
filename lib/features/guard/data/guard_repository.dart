import '../../../core/database/postgres_service.dart';

class GuardRepository {
  Future<Map<String, dynamic>> validateQR(String qrCode) async {
    try {
      print('🔍 [VALIDAR QR] Validando: $qrCode');
      final conn = await PostgresService.instance.connection;

      // Buscar en reservas (qr_reserva)
      final reservas = await conn.execute(
        '''SELECT r.id, r.codigo, r.estado::text, r.fecha, r.hora_inicio, r.hora_fin,
           ac.nombre as area_nombre, p.nombres || ' ' || p.apellidos as persona_nombre
           FROM reservas r
           JOIN areas_comunes ac ON r.area_id = ac.id
           JOIN personas p ON r.persona_id = p.id
           WHERE r.qr_reserva = @qr_code
           LIMIT 1''',
        parameters: {'qr_code': qrCode},
      );

      if (reservas.isNotEmpty) {
        final row = reservas.first;
        print('✅ [VALIDAR QR] Reserva encontrada: ${row[1]}');
        return {
          'valido': true,
          'tipo': 'RESERVA',
          'id': row[0],
          'codigo': row[1],
          'estado': row[2],
          'fecha': row[3],
          'hora_inicio': row[4],
          'hora_fin': row[5],
          'area': row[6],
          'usuario': row[7],
          'mensaje': 'Reserva válida para ${row[6]}',
        };
      }

      // Buscar en visitas (generar QR como VISIT-{id})
      final visitaId = qrCode.replaceAll('VISIT-', '');
      if (visitaId != qrCode && int.tryParse(visitaId) != null) {
        final visitas = await conn.execute(
          '''SELECT v.id, vt.nombres, vt.apellidos, vt.num_doc, v.entrada, v.salida,
             viv.codigo as vivienda_codigo
             FROM visitas v
             JOIN visitantes vt ON v.visitante_id = vt.id
             JOIN viviendas viv ON v.vivienda_destino_id = viv.id
             WHERE v.id = @visita_id
             LIMIT 1''',
          parameters: {'visita_id': int.parse(visitaId)},
        );

        if (visitas.isNotEmpty) {
          final row = visitas.first;
          print('✅ [VALIDAR QR] Visitante encontrado: ${row[1]} ${row[2]}');
          return {
            'valido': true,
            'tipo': 'VISITANTE',
            'id': row[0],
            'nombre': '${row[1]} ${row[2]}',
            'documento': row[3],
            'fecha': row[4],
            'estado': row[5] == null ? 'EN_PROPIEDAD' : 'SALIO',
            'vivienda': row[6],
            'mensaje': 'Visitante autorizado para ${row[6]}',
          };
        }
      }

      print('❌ [VALIDAR QR] QR no encontrado');
      return {
        'valido': false,
        'tipo': null,
        'mensaje': 'QR no encontrado en el sistema',
      };
    } catch (e, stackTrace) {
      print('❌ [VALIDAR QR] Error: $e');
      print('❌ [VALIDAR QR] StackTrace: $stackTrace');
      return {
        'valido': false,
        'tipo': null,
        'mensaje': 'Error al validar: $e',
      };
    }
  }

  Future<void> registerAccess({
    required String qrCode,
    required String tipo,
    required int id,
  }) async {
    try {
      print('📝 [REGISTRAR ACCESO] Tipo: $tipo, ID: $id');
      final conn = await PostgresService.instance.connection;

      // Actualizar estado según tipo
      if (tipo == 'RESERVA') {
        await conn.execute(
          "UPDATE reservas SET estado = 'CONFIRMADA'::reserva_estado WHERE id = @id",
          parameters: {'id': id},
        );
        print('✅ [REGISTRAR ACCESO] Reserva confirmada');
      } else if (tipo == 'VISITANTE') {
        // Marcar entrada si aún no tiene hora de salida
        await conn.execute(
          "UPDATE visitas SET entrada = CURRENT_TIMESTAMP WHERE id = @id AND salida IS NULL",
          parameters: {'id': id},
        );
        print('✅ [REGISTRAR ACCESO] Entrada de visitante registrada');
      }
    } catch (e, stackTrace) {
      print('❌ [REGISTRAR ACCESO] Error: $e');
      print('❌ [REGISTRAR ACCESO] StackTrace: $stackTrace');
    }
  }
}
