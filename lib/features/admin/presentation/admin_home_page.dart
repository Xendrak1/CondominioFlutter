import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/admin_repository.dart';
import '../../../app/theme.dart';
import 'admin_reservations_page.dart';
import 'admin_expenses_page.dart';
import 'admin_announcements_page.dart';

final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = AdminRepository();
  return await repo.getDashboardStats();
});

class AdminHomePage extends ConsumerWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
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
                'Resumen del Condominio',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Stats cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Viviendas\nOcupadas',
                      value: '${stats['viviendas_ocupadas']}',
                      total: '/${stats['total_viviendas']}',
                      icon: Icons.home_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Residentes\nActivos',
                      value: '${stats['total_residentes']}',
                      icon: Icons.people_rounded,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Por Cobrar',
                      value: 'Bs.',
                      subtitle: '${stats['total_cobrar']}',
                      icon: Icons.trending_up_rounded,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Cobrado',
                      value: 'Bs.',
                      subtitle: '${stats['total_cobrado']}',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              const Text(
                'Gestión',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Módulos de gestión
              _ModuleCard(
                icon: Icons.people_rounded,
                title: 'Residentes',
                subtitle: '${stats['total_residentes']} residentes activos',
                count: '${stats['total_residentes']}',
                color: AppColors.primary,
                onTap: () => _showResidents(context),
              ),
              const SizedBox(height: 12),
              _ModuleCard(
                icon: Icons.receipt_long_rounded,
                title: 'Expensas',
                subtitle:
                    '${stats['expensas_pendientes']} pendientes, ${stats['expensas_pagadas']} pagadas',
                count: '${stats['expensas_pendientes']}',
                color: AppColors.expenses,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminExpensesPage(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _ModuleCard(
                icon: Icons.event_available_rounded,
                title: 'Reservas',
                subtitle: '${stats['reservas_activas']} activas este mes',
                count: '${stats['reservas_activas']}',
                color: AppColors.reservations,
                onTap: () => _showReservations(context),
              ),
              const SizedBox(height: 12),
              _ModuleCard(
                icon: Icons.security_rounded,
                title: 'Seguridad',
                subtitle: '${stats['visitantes_hoy']} visitantes hoy',
                count: '${stats['visitantes_hoy']}',
                color: AppColors.guard,
                onTap: () => _showSecurity(context),
              ),
              const SizedBox(height: 12),
              _ModuleCard(
                icon: Icons.analytics_rounded,
                title: 'Reportes',
                subtitle: 'Estadísticas y análisis',
                color: AppColors.info,
                onTap: () => _showReports(context),
              ),
            ],
          ),
        ),
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.refresh(adminStatsProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResidents(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.people_rounded,
                      color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Lista de Residentes',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _ResidentItem(name: 'Juan Pérez', vivienda: 'CN-001'),
                  _ResidentItem(name: 'Carlos Gutiérrez', vivienda: 'CS-001'),
                  _ResidentItem(name: 'Pedro Quispe', vivienda: 'CN-002'),
                  _ResidentItem(name: 'Mario Lopez', vivienda: 'CS-002'),
                  _ResidentItem(name: 'Diego Torres', vivienda: 'CE-002'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReservations(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminReservationsPage(),
      ),
    );
  }

  void _showSecurity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminAnnouncementsPage(),
      ),
    );
  }

  void _showReports(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.analytics_rounded,
                    size: 48, color: AppColors.info),
              ),
              const SizedBox(height: 16),
              const Text(
                'Reportes y Análisis',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Próximamente podrás ver:\n\n'
                '• Reportes de ingresos\n'
                '• Estadísticas de uso de áreas\n'
                '• Análisis de pagos\n'
                '• Gráficos de ocupación',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Entendido'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? total;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    this.total,
    this.subtitle,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (total != null)
                  Text(
                    total!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                if (subtitle != null)
                  Expanded(
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? count;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.count,
    required this.color,
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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (count != null && int.parse(count!) > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    count!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Icon(Icons.chevron_right_rounded,
                    color: Colors.grey[400], size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResidentItem extends StatelessWidget {
  final String name;
  final String vivienda;

  const _ResidentItem({required this.name, required this.vivienda});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.person_rounded, color: AppColors.primary),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Vivienda: $vivienda'),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
        onTap: () {},
      ),
    );
  }
}
