class VisitorsRepository {
  Future<Map<String, dynamic>> generateVisitorQR({
    required String nombres,
    required String apellidos,
    required String numDoc,
    required DateTime fechaVisita,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final qrCode = 'VISITOR-${DateTime.now().millisecondsSinceEpoch}';

    return {
      'qr_code': qrCode,
      'nombres': nombres,
      'apellidos': apellidos,
      'num_doc': numDoc,
      'fecha_visita': fechaVisita,
      'valido_hasta': fechaVisita.add(const Duration(hours: 24)),
    };
  }

  Future<List<Map<String, dynamic>>> getMyVisitors() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      {
        'id': 1,
        'nombres': 'María',
        'apellidos': 'López',
        'num_doc': '20001',
        'fecha_visita': DateTime.now(),
        'qr_code': 'VISITOR-12345',
      },
      {
        'id': 2,
        'nombres': 'Pedro',
        'apellidos': 'Quispe',
        'num_doc': '20002',
        'fecha_visita': DateTime.now().add(const Duration(days: 1)),
        'qr_code': 'VISITOR-67890',
      },
    ];
  }
}
