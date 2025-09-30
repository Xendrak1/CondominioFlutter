import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/admin/presentation/admin_home_page.dart';
import '../features/guard/presentation/guard_scanner_page.dart';
import '../features/dashboard/presentation/resident_home_page.dart';
import '../features/expenses/presentation/expenses_page.dart';
import '../features/reservations/presentation/reservations_page.dart';
import '../features/announcements/presentation/announcements_page.dart';
import '../features/visitors/presentation/visitors_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  String? redirect(BuildContext context, GoRouterState state) {
    final isLoggedIn = authState.isAuthenticated;
    final role = authState.role ?? '';
    final loggingIn = state.matchedLocation == '/login';

    if (!isLoggedIn) {
      return loggingIn ? null : '/login';
    }

    if (loggingIn) {
      return _roleHome(role);
    }

    if (state.matchedLocation.startsWith('/admin') && role != 'ADMIN')
      return _roleHome(role);
    if (state.matchedLocation.startsWith('/resident') && role != 'RESIDENTE')
      return _roleHome(role);
    if (state.matchedLocation.startsWith('/guard') && role != 'GUARDIA')
      return _roleHome(role);

    return null;
  }

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: RouterNotifier(ref),
    redirect: redirect,
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/login',
      ),
      GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
      GoRoute(
          path: '/admin',
          builder: (c, s) => const AdminHomePage(),
          routes: [
            GoRoute(path: 'expenses', builder: (c, s) => const ExpensesPage()),
          ]),
      GoRoute(
          path: '/resident',
          builder: (c, s) => const ResidentHomePage(),
          routes: [
            GoRoute(path: 'expenses', builder: (c, s) => const ExpensesPage()),
            GoRoute(
                path: 'reservations',
                builder: (c, s) => const ReservationsPage()),
            GoRoute(
                path: 'announcements',
                builder: (c, s) => const AnnouncementsPage()),
            GoRoute(path: 'visitors', builder: (c, s) => const VisitorsPage()),
          ]),
      GoRoute(path: '/guard', builder: (c, s) => const GuardScannerPage()),
    ],
  );
});

String _roleHome(String role) {
  switch (role) {
    case 'ADMIN':
      return '/admin';
    case 'RESIDENTE':
      return '/resident';
    case 'GUARDIA':
      return '/guard';
    default:
      return '/login';
  }
}

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
  final Ref ref;
}
