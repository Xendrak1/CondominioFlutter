import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/guard/data/guard_repository.dart';

final dotenvProvider = FutureProvider<void>((ref) async {
  await dotenv.load(fileName: '.env');
});

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository());

final guardRepositoryProvider =
    Provider<GuardRepository>((ref) => GuardRepository());
