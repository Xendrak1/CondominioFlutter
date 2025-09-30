class AdminRepository {
  Future<Map<String, dynamic>> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'total_residentes': 20,
      'total_viviendas': 20,
      'viviendas_ocupadas': 10,
      'expensas_pendientes': 15,
      'expensas_pagadas': 5,
      'total_cobrar': 7500.00,
      'total_cobrado': 2250.00,
      'reservas_activas': 8,
      'reservas_mes': 25,
      'visitantes_hoy': 3,
      'comunicados_mes': 5,
    };
  }

  Future<List<Map<String, dynamic>>> getResidents() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      {
        'id': 1,
        'nombre': 'Juan Pérez',
        'vivienda': 'CN-001',
        'estado': 'ACTIVO'
      },
      {
        'id': 2,
        'nombre': 'Carlos Gutiérrez',
        'vivienda': 'CS-001',
        'estado': 'ACTIVO'
      },
      {
        'id': 3,
        'nombre': 'Pedro Quispe',
        'vivienda': 'CN-002',
        'estado': 'ACTIVO'
      },
      {
        'id': 4,
        'nombre': 'Mario Lopez',
        'vivienda': 'CS-002',
        'estado': 'ACTIVO'
      },
      {
        'id': 5,
        'nombre': 'Diego Torres',
        'vivienda': 'CE-002',
        'estado': 'ACTIVO'
      },
    ];
  }
}
