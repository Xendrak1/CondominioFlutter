import '../../../core/database/postgres_service.dart';

class AnnouncementsRepository {
  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    try {
      print('📢 [COMUNICADOS] Obteniendo comunicados...');
      final conn = await PostgresService.instance.connection;

      // Estructura real: id, titulo, cuerpo, fecha_publicacion, publico
      final results = await conn.execute(
        '''SELECT id, titulo, cuerpo, fecha_publicacion, publico 
           FROM comunicados 
           ORDER BY fecha_publicacion DESC 
           LIMIT 50''',
      );

      print('📢 [COMUNICADOS] Query ejecutado. Filas: ${results.length}');

      return results.map((row) {
        return {
          'id': row[0] as int,
          'titulo': row[1] as String,
          'contenido': row[2] as String, // cuerpo → contenido
          'fecha_publicacion': row[3] as DateTime,
          'prioridad':
              _mapPublicoToPrioridad(row[4] as String), // publico → prioridad
          'leido': false, // Por ahora todos sin leer
        };
      }).toList();
    } catch (e, stackTrace) {
      print('❌ [COMUNICADOS] Error obteniendo comunicados: $e');
      print('❌ [COMUNICADOS] StackTrace: $stackTrace');
      rethrow;
    }
  }

  String _mapPublicoToPrioridad(String publico) {
    // Mapear el campo "publico" a "prioridad" para mantener la UI
    switch (publico) {
      case 'TODOS':
        return 'ALTA';
      case 'RESIDENTES':
        return 'MEDIA';
      case 'PROPIETARIOS':
        return 'MEDIA';
      case 'GUARDIAS':
        return 'BAJA';
      default:
        return 'MEDIA';
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      print('✅ [COMUNICADOS] Marcando como leído: $id');
      // En una implementación real, insertarías en lecturas_comunicado
      // Por ahora solo log
    } catch (e) {
      print('❌ [COMUNICADOS] Error marcando como leído: $e');
    }
  }
}
