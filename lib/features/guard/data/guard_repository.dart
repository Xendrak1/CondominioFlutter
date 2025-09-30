class GuardRepository {
  Future<({bool isValid, String message, Map<String, dynamic>? data})>
      validateQR(String qrData) async {
    // Simulación de validación sin PostgreSQL
    await Future.delayed(const Duration(milliseconds: 500));

    // QR válido de ejemplo
    if (qrData == 'R-001' || qrData.startsWith('RESERVA-')) {
      return (
        isValid: true,
        message: 'Reserva válida',
        data: {
          'codigo': qrData,
          'area': 'Piscina',
          'vivienda': 'CN-001',
          'fecha': DateTime.now().toString(),
        },
      );
    }

    return (
      isValid: false,
      message: 'QR no válido',
      data: null,
    );
  }

  Future<void> registerAccess({
    required String type,
    required String data,
    required bool authorized,
    String? notes,
  }) async {
    // Mock: solo imprimir
    print('Acceso registrado: $type - $data - Autorizado: $authorized');
  }
}
