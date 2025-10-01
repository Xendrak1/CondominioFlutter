import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../data/visitors_repository.dart';
import '../../../app/theme.dart';
import '../../../common/widgets/empty_state.dart';

final visitorsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = VisitorsRepository();
  return await repo.getVisitors();
});

class VisitorsPage extends ConsumerWidget {
  const VisitorsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitorsAsync = ref.watch(visitorsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis Visitantes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: () => _showCreateVisitor(context, ref),
            tooltip: 'Nuevo visitante',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateVisitor(context, ref),
        icon: const Icon(Icons.qr_code_2_rounded),
        label: const Text('Generar QR'),
        backgroundColor: AppColors.visitors,
      ),
      body: visitorsAsync.when(
        data: (visitors) {
          if (visitors.isEmpty) {
            return EmptyState(
              icon: Icons.people_outline_rounded,
              title: 'No hay visitantes',
              subtitle:
                  'Genera un QR para que tus visitantes puedan ingresar al condominio',
              action: FilledButton.icon(
                onPressed: () => _showCreateVisitor(context, ref),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Agregar Visitante'),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            itemCount: visitors.length,
            itemBuilder: (context, index) {
              final visitor = visitors[index];
              final fechaVisita = visitor['fecha'] as DateTime?;
              final yaVisito = fechaVisita?.isBefore(DateTime.now()) ?? false;
              final esHoy = fechaVisita != null &&
                  fechaVisita.year == DateTime.now().year &&
                  fechaVisita.month == DateTime.now().month &&
                  fechaVisita.day == DateTime.now().day;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    childrenPadding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (yaVisito ? Colors.grey : AppColors.visitors)
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: yaVisito ? Colors.grey : AppColors.visitors,
                        size: 26,
                      ),
                    ),
                    title: Text(
                      '${visitor['nombres']} ${visitor['apellidos']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.badge_rounded,
                                  size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                'CI: ${visitor['num_doc']}',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded,
                                  size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                fechaVisita?.toString().split(' ')[0] ??
                                    'Sin fecha',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[600]),
                              ),
                              if (esHoy) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'HOY',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: QrImageView(
                                data: visitor['qr_code'] as String,
                                version: QrVersions.auto,
                                size: 200.0,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: AppColors.primary,
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: () {
                                  Share.share(
                                    'QR de Visitante - Condominio KE\n\n'
                                    'Nombre: ${visitor['nombres']} ${visitor['apellidos']}\n'
                                    'CI: ${visitor['num_doc']}\n'
                                    'Código: ${visitor['qr_code']}\n'
                                    'Fecha de visita: ${fechaVisita.toString().split(' ')[0]}\n\n'
                                    'Presentar este QR al guardia para ingresar.',
                                    subject: 'QR de Visitante',
                                  );
                                },
                                icon: const Icon(Icons.share_rounded),
                                label: const Text('Compartir QR'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.visitors,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const LoadingState(message: 'Cargando visitantes...'),
        error: (error, stack) => ErrorState(
          error: error.toString(),
          onRetry: () => ref.refresh(visitorsProvider),
        ),
      ),
    );
  }

  void _showCreateVisitor(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateVisitorSheet(ref: ref),
    );
  }
}

class _CreateVisitorSheet extends StatefulWidget {
  final WidgetRef ref;
  const _CreateVisitorSheet({required this.ref});

  @override
  State<_CreateVisitorSheet> createState() => _CreateVisitorSheetState();
}

class _CreateVisitorSheetState extends State<_CreateVisitorSheet> {
  final nombresCtrl = TextEditingController();
  final apellidosCtrl = TextEditingController();
  final numDocCtrl = TextEditingController();
  DateTime fechaVisita = DateTime.now();
  bool isCreating = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.visitors.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_add_rounded,
                    color: AppColors.visitors, size: 32),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Nuevo Visitante',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: nombresCtrl,
            decoration: const InputDecoration(
              labelText: 'Nombres',
              prefixIcon: Icon(Icons.badge_rounded, color: AppColors.primary),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: apellidosCtrl,
            decoration: const InputDecoration(
              labelText: 'Apellidos',
              prefixIcon: Icon(Icons.badge_rounded, color: AppColors.primary),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: numDocCtrl,
            decoration: const InputDecoration(
              labelText: 'Número de Documento',
              prefixIcon:
                  Icon(Icons.credit_card_rounded, color: AppColors.primary),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: fechaVisita,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 7)),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme:
                        const ColorScheme.light(primary: AppColors.primary),
                  ),
                  child: child!,
                ),
              );
              if (date != null) setState(() => fechaVisita = date);
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Fecha de visita',
                prefixIcon: Icon(Icons.calendar_today_rounded,
                    color: AppColors.primary),
              ),
              child: Row(
                children: [
                  Text(fechaVisita.toString().split(' ')[0]),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: isCreating
                  ? null
                  : () async {
                      if (nombresCtrl.text.isEmpty ||
                          apellidosCtrl.text.isEmpty ||
                          numDocCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.warning_rounded,
                                    color: Colors.white),
                                SizedBox(width: 12),
                                Text('Completa todos los campos'),
                              ],
                            ),
                            backgroundColor: AppColors.warning,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                        return;
                      }

                      setState(() => isCreating = true);
                      try {
                        final repo = VisitorsRepository();
                        final result = await repo.generateVisitorQR(
                          nombre: '${nombresCtrl.text} ${apellidosCtrl.text}',
                          documento: numDocCtrl.text,
                          fecha: fechaVisita,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          widget.ref.refresh(visitorsProvider);
                          _showSuccessDialog(context, result);
                        }
                      } finally {
                        if (mounted) setState(() => isCreating = false);
                      }
                    },
              icon: isCreating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.qr_code_2_rounded),
              label: Text(
                isCreating ? 'Generando...' : 'Generar QR',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.visitors,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    size: 60, color: AppColors.success),
              ),
              const SizedBox(height: 20),
              const Text(
                'QR Generado',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                (result['nombre'] as String?) ??
                    '${result['nombres'] ?? ''} ${result['apellidos'] ?? ''}'
                        .trim(),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'CI: ${result['num_doc'] ?? result['documento'] ?? '-'}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: result['qr_code'] as String,
                  version: QrVersions.auto,
                  size: 220.0,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.primary,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Share.share(
                      '📱 QR de Visitante - Condominio KE\n\n'
                              '👤 Nombre: ' +
                          ((result['nombre'] as String?) ??
                              '${result['nombres'] ?? ''} ${result['apellidos'] ?? ''}'
                                  .trim()) +
                          '\n'
                              '🆔 CI: ${result['num_doc'] ?? result['documento'] ?? '-'}\n'
                              '🔑 Código: ${result['qr_code']}\n'
                              '📅 Fecha de visita: ' +
                          (((result['fecha_visita'] as DateTime?) ??
                                  (result['fecha'] as DateTime?) ??
                                  DateTime.now())
                              .toString()
                              .split(' ')[0]) +
                          '\n\n'
                              '✅ Presentar este QR al guardia para ingresar.',
                      subject: 'QR de Visitante',
                    );
                  },
                  icon: const Icon(Icons.share_rounded),
                  label:
                      const Text('Compartir', style: TextStyle(fontSize: 16)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.visitors,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
