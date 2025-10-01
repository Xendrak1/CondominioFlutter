import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../expenses/data/expenses_repository.dart';

final adminExpensesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ExpensesRepository();
  return await repo.getExpenses();
});

class AdminExpensesPage extends ConsumerWidget {
  const AdminExpensesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(adminExpensesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestión de Expensas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: expensesAsync.when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_rounded,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay expensas registradas',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // Agrupar por estado
          final pendientes =
              expenses.where((e) => e['estado'] == 'PENDIENTE').toList();
          final pagadas =
              expenses.where((e) => e['estado'] == 'PAGADA').toList();
          final vencidas =
              expenses.where((e) => e['estado'] == 'VENCIDA').toList();

          // Calcular totales
          final totalPendiente = pendientes.fold<double>(
              0, (sum, item) => sum + _parseDouble(item['monto']));
          final totalPagado = pagadas.fold<double>(
              0, (sum, item) => sum + _parseDouble(item['monto']));

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Estadísticas
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Pendiente',
                      'Bs. ${totalPendiente.toStringAsFixed(2)}',
                      pendientes.length,
                      AppColors.warning,
                      Icons.pending_actions_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Pagado',
                      'Bs. ${totalPagado.toStringAsFixed(2)}',
                      pagadas.length,
                      AppColors.success,
                      Icons.check_circle_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (vencidas.isNotEmpty) ...[
                _buildSection('Vencidas', vencidas, AppColors.error),
                const SizedBox(height: 20),
              ],
              _buildSection('Pendientes', pendientes, AppColors.warning),
              const SizedBox(height: 20),
              _buildSection('Pagadas', pagadas, AppColors.success),
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
                'Error al cargar expensas',
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
                onPressed: () => ref.refresh(adminExpensesProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String amount, int count, Color color, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              '$count expensas',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
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
                Icons.receipt_long_rounded,
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
        ...items.map((expense) => Card(
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
                    Icons.home_rounded,
                    color: color,
                  ),
                ),
                title: Text(
                  '${expense['vivienda_codigo']} - ${expense['periodo']}',
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
                        Icon(Icons.receipt_rounded,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(expense['codigo'] as String),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Vence: ${(expense['vencimiento'] as DateTime).toString().split(' ')[0]}',
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Bs. ${_parseDouble(expense['monto']).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        expense['estado'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
