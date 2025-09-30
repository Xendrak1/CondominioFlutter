import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../expenses/data/expenses_repository.dart';
import '../../reservations/data/reservations_repository.dart';
import '../../announcements/data/announcements_repository.dart';
import '../../../app/theme.dart';

final residentStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final expensesRepo = ExpensesRepository();
  final reservationsRepo = ReservationsRepository();
  final announcementsRepo = AnnouncementsRepository();

  final expenses = await expensesRepo.getExpenses();
  final reservations = await reservationsRepo.getMyReservations();
  final announcements = await announcementsRepo.getAnnouncements();

  final pendingExpenses =
      expenses.where((e) => e['estado'] == 'PENDIENTE').length;
  final unreadAnnouncements =
      announcements.where((a) => a['leido'] == false).length;
  final activeReservations =
      reservations.where((r) => r['estado'] == 'CONFIRMADA').length;
  final totalDebt = expenses
      .where((e) => e['estado'] == 'PENDIENTE')
      .fold<double>(0, (sum, e) => sum + (e['monto'] as num).toDouble());

  return {
    'pending_expenses': pendingExpenses,
    'total_debt': totalDebt,
    'unread_announcements': unreadAnnouncements,
    'active_reservations': activeReservations,
  };
});

class ResidentHomePage extends ConsumerWidget {
  const ResidentHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(residentStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Hogar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bienvenido',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu resumen de hoy',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _QuickStat(
                      label: 'Expensas\nPendientes',
                      value: '${stats['pending_expenses']}',
                      icon: Icons.receipt_long_rounded,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickStat(
                      label: 'Por Pagar',
                      value: 'Bs. ${stats['total_debt']}',
                      icon: Icons.attach_money_rounded,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickStat(
                      label: 'Reservas\nActivas',
                      value: '${stats['active_reservations']}',
                      icon: Icons.event_available_rounded,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickStat(
                      label: 'Comunicados\nNuevos',
                      value: '${stats['unread_announcements']}',
                      icon: Icons.notifications_active_rounded,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Servicios',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _ServiceCard(
                icon: Icons.receipt_long_rounded,
                title: 'Expensas',
                subtitle: 'Ver y pagar expensas',
                color: AppColors.expenses,
                badge: stats['pending_expenses'] > 0
                    ? '${stats['pending_expenses']}'
                    : null,
                onTap: () => context.go('/resident/expenses'),
              ),
              const SizedBox(height: 12),
              _ServiceCard(
                icon: Icons.event_available_rounded,
                title: 'Reservas',
                subtitle: 'Crear y gestionar reservas',
                color: AppColors.reservations,
                badge: stats['active_reservations'] > 0
                    ? '${stats['active_reservations']}'
                    : null,
                onTap: () => context.go('/resident/reservations'),
              ),
              const SizedBox(height: 12),
              _ServiceCard(
                icon: Icons.announcement_rounded,
                title: 'Comunicados',
                subtitle: 'Leer comunicados',
                color: AppColors.announcements,
                badge: stats['unread_announcements'] > 0
                    ? '${stats['unread_announcements']}'
                    : null,
                onTap: () => context.go('/resident/announcements'),
              ),
              const SizedBox(height: 12),
              _ServiceCard(
                icon: Icons.qr_code_2_rounded,
                title: 'Visitantes',
                subtitle: 'Generar QR para visitantes',
                color: AppColors.visitors,
                onTap: () => context.go('/resident/visitors'),
              ),
            ],
          ),
        ),
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _QuickStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (badge == null)
                Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
