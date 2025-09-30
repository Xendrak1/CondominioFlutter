import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../../common/providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../../app/theme.dart';

class GuardScannerPage extends ConsumerStatefulWidget {
  const GuardScannerPage({super.key});

  @override
  ConsumerState<GuardScannerPage> createState() => _GuardScannerPageState();
}

class _GuardScannerPageState extends ConsumerState<GuardScannerPage>
    with SingleTickerProviderStateMixin {
  MobileScannerController? controller;
  bool isScanning = false;
  String? lastScannedData;
  String? validationResult;
  bool? isValid;
  late AnimationController animationController;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    animationController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (isScanning) return;

    setState(() {
      isScanning = true;
      lastScannedData = capture.barcodes.first.rawValue;
    });

    _validateScannedData(capture.barcodes.first.rawValue ?? '');
  }

  Future<void> _validateScannedData(String data) async {
    try {
      final guardRepo = ref.read(guardRepositoryProvider);
      final result = await guardRepo.validateQR(data);

      setState(() {
        validationResult = result.message;
        isValid = result.isValid;
        isScanning = false;
      });

      animationController.forward(from: 0);

      // Registrar acceso
      await guardRepo.registerAccess(
        type: 'qr',
        data: data,
        authorized: result.isValid,
        notes: result.data?['details'] as String?,
      );

      // Mostrar resultado por 4 segundos
      await Future.delayed(const Duration(seconds: 4));
      setState(() {
        validationResult = null;
        lastScannedData = null;
        isValid = null;
      });
    } catch (e) {
      setState(() {
        validationResult = 'Error: ${e.toString()}';
        isValid = false;
        isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Scanner de cámara
          MobileScanner(
            controller: controller!,
            onDetect: _onDetect,
          ),

          // Overlay oscuro
          Container(
            color: Colors.black.withOpacity(0.4),
          ),

          // AppBar personalizado
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              title: const Text('Escáner de Seguridad'),
              backgroundColor: Colors.transparent,
              elevation: 0,
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
          ),

          // Instrucciones superiores
          Positioned(
            top: 120,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.guard,
                      AppColors.guard.withOpacity(0.9),
                    ],
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.qr_code_scanner_rounded,
                        color: Colors.white, size: 44),
                    SizedBox(height: 12),
                    Text(
                      'Escanea el QR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Reservas, visitantes o placas',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Marco de escaneo central
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 4),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                ),
              ),
            ),
          ),

          // Resultado de validación
          if (validationResult != null)
            Positioned(
              bottom: 180,
              left: 20,
              right: 20,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: isValid == true
                            ? [
                                AppColors.success,
                                AppColors.success.withOpacity(0.9)
                              ]
                            : [
                                AppColors.error,
                                AppColors.error.withOpacity(0.9)
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isValid == true
                                  ? AppColors.success
                                  : AppColors.error)
                              .withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            isValid == true
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isValid == true
                                    ? 'ACCESO AUTORIZADO'
                                    : 'ACCESO DENEGADO',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                validationResult!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Botones inferiores
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    child: InkWell(
                      onTap: () => _showManualEntry(context),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.grey.shade50],
                          ),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.keyboard_rounded,
                                color: AppColors.primary, size: 32),
                            SizedBox(height: 8),
                            Text(
                              'Manual',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    child: InkWell(
                      onTap: () => _showPlateScanner(context),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.grey.shade50],
                          ),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.directions_car_rounded,
                                color: AppColors.primary, size: 32),
                            SizedBox(height: 8),
                            Text(
                              'Placas IA',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showManualEntry(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.keyboard_rounded, color: AppColors.primary, size: 28),
            SizedBox(width: 12),
            Text('Entrada Manual'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add_rounded, size: 64, color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Registro manual de acceso',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Funcionalidad en desarrollo. Permitirá registrar accesos manualmente cuando el QR no esté disponible.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showPlateScanner(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.directions_car_rounded,
                color: AppColors.primary, size: 28),
            SizedBox(width: 12),
            Expanded(child: Text('Escáner de Placas IA')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'Reconocimiento Automático',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text(
              'Esta función usará Inteligencia Artificial para reconocer placas de vehículos automáticamente.\n\nDatasets recomendados:\n• OpenALPR\n• UFPR-ALPR (Latinoamérica)\n• LPRNet',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
        actions: [
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
