import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/guard/data/guard_repository.dart';
import '../features/expenses/data/expenses_repository.dart';
import '../features/reservations/data/reservations_repository.dart';
import '../features/announcements/data/announcements_repository.dart';
import '../features/visitors/data/visitors_repository.dart';

final dotenvProvider = FutureProvider<void>((ref) async {
  await dotenv.load(fileName: '.env');
  // Configurar ApiClient después de cargar variables de entorno
  ApiClient.configure();
});

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository());

final guardRepositoryProvider =
    Provider<GuardRepository>((ref) => GuardRepository());

final expensesRepositoryProvider =
    Provider<ExpensesRepository>((ref) => ExpensesRepository());

final reservationsRepositoryProvider =
    Provider<ReservationsRepository>((ref) => ReservationsRepository());

final announcementsRepositoryProvider =
    Provider<AnnouncementsRepository>((ref) => AnnouncementsRepository());

final visitorsRepositoryProvider =
    Provider<VisitorsRepository>((ref) => VisitorsRepository());
