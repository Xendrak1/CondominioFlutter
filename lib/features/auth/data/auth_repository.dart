class AuthRepository {
  Future<({String access, String refresh, String role})> login(
      {required String email, required String password}) async {
    // Simulación de login sin PostgreSQL
    await Future.delayed(const Duration(milliseconds: 500));

    // Usuarios de prueba
    final users = {
      'juanperez': {'password': 'adminJUAN', 'role': 'ADMIN'},
      'anaperez': {'password': 'adminANA', 'role': 'GUARDIA'},
      'pedroquispe': {'password': 'adminPEDRO', 'role': 'ADMIN'},
      'mariolopez': {'password': 'adminMARIO', 'role': 'RESIDENTE'},
    };

    final user = users[email];

    if (user == null) {
      throw Exception('Usuario no encontrado');
    }

    if (user['password'] != password) {
      throw Exception('Contraseña incorrecta');
    }

    final userId = email.hashCode.toString();
    final userRole = user['role'] as String;

    // Generar tokens
    final accessToken =
        'access_${userId}_${DateTime.now().millisecondsSinceEpoch}';
    final refreshToken =
        'refresh_${userId}_${DateTime.now().millisecondsSinceEpoch}';

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
}
