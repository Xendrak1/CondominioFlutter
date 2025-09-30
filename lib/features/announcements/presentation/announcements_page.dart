import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/announcements_repository.dart';
import '../../../app/theme.dart';
import '../../../common/widgets/empty_state.dart';

final announcementsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = AnnouncementsRepository();
  return await repo.getAnnouncements();
});

class AnnouncementsPage extends ConsumerWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Comunicados'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: announcementsAsync.when(
        data: (announcements) {
          if (announcements.isEmpty) {
            return const EmptyState(
              icon: Icons.announcement_rounded,
              title: 'No hay comunicados',
              subtitle: 'Aquí aparecerán los comunicados del condominio',
            );
          }

          final unread =
              announcements.where((a) => a['leido'] == false).toList();
          final read = announcements.where((a) => a['leido'] == true).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (unread.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.mark_email_unread_rounded,
                          color: AppColors.primary, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Nuevos',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${unread.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...unread.map((announcement) => _AnnouncementCard(
                        announcement: announcement,
                        ref: ref,
                      )),
                  if (read.isNotEmpty) const SizedBox(height: 24),
                ],
                if (read.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.mark_email_read_rounded,
                          color: Colors.grey[600], size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Leídos',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...read.map((announcement) => _AnnouncementCard(
                        announcement: announcement,
                        ref: ref,
                      )),
                ],
              ],
            ),
          );
        },
        loading: () => const LoadingState(message: 'Cargando comunicados...'),
        error: (error, stack) => ErrorState(
          error: error.toString(),
          onRetry: () => ref.refresh(announcementsProvider),
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Map<String, dynamic> announcement;
  final WidgetRef ref;

  const _AnnouncementCard({required this.announcement, required this.ref});

  @override
  Widget build(BuildContext context) {
    final leido = announcement['leido'] as bool;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: leido ? 1 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: !leido
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.announcements.withOpacity(0.1),
                    AppColors.announcements.withOpacity(0.05)
                  ],
                )
              : null,
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (leido ? Colors.grey : AppColors.announcements)
                    .withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                leido
                    ? Icons.mark_email_read_rounded
                    : Icons.mark_email_unread_rounded,
                color: leido ? Colors.grey : AppColors.announcements,
                size: 24,
              ),
            ),
            title: Text(
              announcement['titulo'] as String,
              style: TextStyle(
                fontWeight: leido ? FontWeight.w500 : FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    (announcement['fecha'] as DateTime)
                        .toString()
                        .split(' ')[0],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            trailing: !leido
                ? Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  )
                : null,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        announcement['contenido'] as String,
                        style: const TextStyle(fontSize: 15, height: 1.6),
                      ),
                    ),
                    if (!leido) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () async {
                            final repo = AnnouncementsRepository();
                            await repo.markAsRead(announcement['id'] as int);
                            ref.refresh(announcementsProvider);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded,
                                        color: Colors.white),
                                    SizedBox(width: 12),
                                    Text('Marcado como leído'),
                                  ],
                                ),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Marcar como Leído'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
