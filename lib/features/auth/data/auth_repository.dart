class AuthRepository {
  // LOGIN SIMPLIFICADO - Solo usuarios mock por ahora
  // La conexión a PostgreSQL se hará en los otros módulos
  Future<({String access, String refresh, String role})> login(
      {required String email, required String password}) async {
    print('🔐 [LOGIN] Intentando login para: $email');
    await Future.delayed(const Duration(milliseconds: 300));

    // Usuarios de prueba
    final users = {
      'juanperez': {'password': 'adminJUAN', 'role': 'ADMIN'},
      'anaperez': {'password': 'adminANA', 'role': 'GUARDIA'},
      'pedroquispe': {'password': 'adminPEDRO', 'role': 'ADMIN'},
      'mariolopez': {'password': 'adminMARIO', 'role': 'RESIDENTE'},
    };

    final user = users[email];

    if (user == null) {
      print('❌ [LOGIN] Usuario no encontrado: $email');
      throw Exception('Usuario no encontrado');
    }

    if (user['password'] != password) {
      print('❌ [LOGIN] Contraseña incorrecta');
      throw Exception('Contraseña incorrecta');
    }

    final userId = email.hashCode.toString();
    final userRole = user['role'] as String;

    // Generar tokens
    final accessToken =
        'access_${userId}_${DateTime.now().millisecondsSinceEpoch}';
    final refreshToken =
        'refresh_${userId}_${DateTime.now().millisecondsSinceEpoch}';

    print('✅ [LOGIN] Login exitoso como $userRole');

    return (
      access: accessToken,
      refresh: refreshToken,
      role: userRole,
    );
  }

  Future<String?> refresh(String refreshToken) async {
    final userId = refreshToken.split('_')[1];
    return 'access_${userId}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> logout() async {
    print('👋 [LOGOUT] Cerrando sesión');
  }
}
