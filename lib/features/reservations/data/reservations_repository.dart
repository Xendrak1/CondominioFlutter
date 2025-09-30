class ReservationsRepository {
  Future<List<Map<String, dynamic>>> getAreas() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      {'id': 1, 'nombre': 'Piscina', 'requiere_pago': true, 'tarifa': 50.0},
      {'id': 2, 'nombre': 'Gimnasio', 'requiere_pago': false, 'tarifa': null},
      {
        'id': 3,
        'nombre': 'Parque Infantil',
        'requiere_pago': false,
        'tarifa': null
      },
      {
        'id': 4,
        'nombre': 'Salón de Juegos',
        'requiere_pago': true,
        'tarifa': 100.0
      },
      {
        'id': 5,
        'nombre': 'Terraza/Deck',
        'requiere_pago': true,
        'tarifa': 150.0
      },
      {'id': 6, 'nombre': 'Área de BBQ', 'requiere_pago': true, 'tarifa': 80.0},
      {
        'id': 7,
        'nombre': 'Cancha de Tenis',
        'requiere_pago': true,
        'tarifa': 50.0
      },
    ];
  }

  Future<List<Map<String, dynamic>>> getMyReservations() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      {
        'id': 1,
        'codigo': 'R-001',
        'area_nombre': 'Piscina',
        'fecha': DateTime(2025, 9, 15),
        'hora_inicio': '18:00',
        'hora_fin': '23:00',
        'estado': 'CONFIRMADA',
      },
      {
        'id': 2,
        'codigo': 'R-002',
        'area_nombre': 'Salón de Juegos',
        'fecha': DateTime(2025, 9, 20),
        'hora_inicio': '14:00',
        'hora_fin': '18:00',
        'estado': 'PENDIENTE',
      },
    ];
  }

  Future<Map<String, dynamic>> createReservation({
    required int areaId,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'id': DateTime.now().millisecondsSinceEpoch,
      'codigo': 'R-${DateTime.now().millisecondsSinceEpoch}',
      'qr_code': 'RESERVA-${DateTime.now().millisecondsSinceEpoch}',
      'estado': 'CONFIRMADA',
    };
  }

  Future<void> cancelReservation(int reservationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
