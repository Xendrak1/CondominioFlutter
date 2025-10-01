import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../reservations/data/reservations_repository.dart';

final adminReservationsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ReservationsRepository();
  return await repo.getMyReservations();
});

class AdminReservationsPage extends ConsumerWidget {
  const AdminReservationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationsAsync = ref.watch(adminReservationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestión de Reservas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: reservationsAsync.when(
        data: (reservations) {
          if (reservations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy_rounded,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay reservas registradas',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // Agrupar por estado
          final confirmadas =
              reservations.where((r) => r['estado'] == 'CONFIRMADA').toList();
          final pendientes =
              reservations.where((r) => r['estado'] == 'PENDIENTE').toList();
          final canceladas =
              reservations.where((r) => r['estado'] == 'CANCELADA').toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSection('Confirmadas', confirmadas, AppColors.success),
              const SizedBox(height: 20),
              _buildSection('Pendientes', pendientes, AppColors.warning),
              const SizedBox(height: 20),
              _buildSection('Canceladas', canceladas, AppColors.error),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Error al cargar reservas',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(adminReservationsProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
      String title, List<Map<String, dynamic>> items, Color color) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIconForStatus(title),
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$title (${items.length})',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((reservation) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.event_rounded,
                    color: color,
                  ),
                ),
                title: Text(
                  reservation['area_nombre'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.qr_code_2_rounded,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(reservation['codigo'] as String),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          (reservation['fecha'] as DateTime)
                              .toString()
                              .split(' ')[0],
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time_rounded,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${reservation['hora_inicio']} - ${reservation['hora_fin']}',
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    reservation['estado'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  IconData _getIconForStatus(String status) {
    switch (status) {
      case 'Confirmadas':
        return Icons.check_circle_rounded;
      case 'Pendientes':
        return Icons.pending_rounded;
      case 'Canceladas':
        return Icons.cancel_rounded;
      default:
        return Icons.event_rounded;
    }
  }
}
