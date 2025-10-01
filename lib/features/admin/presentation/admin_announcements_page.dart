import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../announcements/data/announcements_repository.dart';

final adminAnnouncementsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = AnnouncementsRepository();
  return await repo.getAnnouncements();
});

class AdminAnnouncementsPage extends ConsumerWidget {
  const AdminAnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(adminAnnouncementsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestión de Comunicados'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showCreateDialog(context, ref),
            tooltip: 'Nuevo comunicado',
          ),
        ],
      ),
      body: announcementsAsync.when(
        data: (announcements) {
          if (announcements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign_rounded,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay comunicados',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateDialog(context, ref),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Crear Comunicado'),
                  ),
                ],
              ),
            );
          }

          // Agrupar por prioridad
          final alta =
              announcements.where((a) => a['prioridad'] == 'ALTA').toList();
          final media =
              announcements.where((a) => a['prioridad'] == 'MEDIA').toList();
          final baja =
              announcements.where((a) => a['prioridad'] == 'BAJA').toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (alta.isNotEmpty) ...[
                _buildSection('Alta Prioridad', alta, AppColors.error,
                    Icons.priority_high_rounded),
                const SizedBox(height: 20),
              ],
              if (media.isNotEmpty) ...[
                _buildSection('Media Prioridad', media, AppColors.warning,
                    Icons.info_rounded),
                const SizedBox(height: 20),
              ],
              if (baja.isNotEmpty) ...[
                _buildSection('Baja Prioridad', baja, AppColors.primary,
                    Icons.info_outline_rounded),
              ],
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
                'Error al cargar comunicados',
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
                onPressed: () => ref.refresh(adminAnnouncementsProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo'),
      ),
    );
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> items,
      Color color, IconData icon) {
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
              child: Icon(icon, color: color, size: 20),
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
        ...items.map((announcement) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ExpansionTile(
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.campaign_rounded,
                    color: color,
                  ),
                ),
                title: Text(
                  announcement['titulo'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        (announcement['fecha_publicacion'] as DateTime)
                            .toString()
                            .split(' ')[0],
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    announcement['prioridad'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcement['contenido'] as String,
                          style: const TextStyle(fontSize: 15, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.edit_rounded),
                              label: const Text('Editar'),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.delete_rounded),
                              label: const Text('Eliminar'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.campaign_rounded, color: AppColors.primary),
            SizedBox(width: 12),
            Text('Nuevo Comunicado'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Esta funcionalidad requiere conectar con el backend para crear comunicados.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
