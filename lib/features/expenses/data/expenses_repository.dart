class ExpensesRepository {
  Future<List<Map<String, dynamic>>> getExpenses({int? viviendaId}) async {
    // Datos mock mientras configuramos PostgreSQL
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      {
        'id': 1,
        'codigo': 'EXP-001',
        'periodo': '2025-09',
        'monto': 500.00,
        'vencimiento': DateTime(2025, 9, 30),
        'estado': 'PENDIENTE',
        'vivienda_codigo': 'CN-001',
      },
      {
        'id': 2,
        'codigo': 'EXP-002',
        'periodo': '2025-09',
        'monto': 450.00,
        'vencimiento': DateTime(2025, 9, 30),
        'estado': 'PAGADA',
        'vivienda_codigo': 'CN-002',
      },
      {
        'id': 3,
        'codigo': 'EXP-003',
        'periodo': '2025-08',
        'monto': 500.00,
        'vencimiento': DateTime(2025, 8, 30),
        'estado': 'PAGADA',
        'vivienda_codigo': 'CN-001',
      },
    ];
  }
}
