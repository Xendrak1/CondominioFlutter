class AppConstants {
  // App Info
  static const String appName = 'Condominio KE';
  static const String appSlogan = 'Gestión Integral de Condominios';

  // Roles
  static const String roleAdmin = 'ADMIN';
  static const String roleResident = 'RESIDENTE';
  static const String roleGuard = 'GUARDIA';

  // Estados de Expensas
  static const String expensePending = 'PENDIENTE';
  static const String expensePaid = 'PAGADA';

  // Estados de Reservas
  static const String reservationConfirmed = 'CONFIRMADA';
  static const String reservationPending = 'PENDIENTE';
  static const String reservationCanceled = 'CANCELADA';

  // Mensajes
  static const String successLogin = '¡Bienvenido!';
  static const String errorLogin = 'Usuario o contraseña incorrectos';
  static const String errorNetwork = 'Error de conexión';
  static const String loadingData = 'Cargando datos...';

  // QR Prefixes
  static const String qrReservation = 'RESERVA-';
  static const String qrVisitor = 'VISITOR-';
  static const String qrPayment = 'PAYMENT-';

  // Timeouts
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // API Endpoints (si se usa backend)
  static const String apiLogin = '/api/auth/login';
  static const String apiRefresh = '/api/auth/refresh';
  static const String apiExpenses = '/api/expensas';
  static const String apiReservations = '/api/reservas';
  static const String apiAnnouncements = '/api/comunicados';
  static const String apiVisitors = '/api/visitantes';
  static const String apiValidateQR = '/api/guardia/validar_qr';
}
