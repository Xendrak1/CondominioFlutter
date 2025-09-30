import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:condominio_roles/features/guard/data/guard_repository.dart';

@GenerateMocks([Dio])
import 'guard_repository_test.mocks.dart';

void main() {
  group('GuardRepository', () {
    late MockDio mockDio;
    late GuardRepository repository;

    setUp(() {
      mockDio = MockDio();
      repository = GuardRepository(mockDio);
    });

    test('should validate QR successfully', () async {
      // Arrange
      final responseData = {
        'valid': true,
        'message': 'QR válido',
        'data': {'details': 'Reserva confirmada'}
      };
      when(mockDio.post('/api/guardia/validar_qr', data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: '/api/guardia/validar_qr'),
              ));

      // Act
      final result = await repository.validateQR('test-qr-data');

      // Assert
      expect(result.isValid, true);
      expect(result.message, 'QR válido');
      expect(result.data, {'details': 'Reserva confirmada'});
    });

    test('should handle invalid QR', () async {
      // Arrange
      final responseData = {
        'valid': false,
        'message': 'QR expirado',
        'data': null
      };
      when(mockDio.post('/api/guardia/validar_qr', data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: '/api/guardia/validar_qr'),
              ));

      // Act
      final result = await repository.validateQR('expired-qr');

      // Assert
      expect(result.isValid, false);
      expect(result.message, 'QR expirado');
    });

    test('should handle network error', () async {
      // Arrange
      when(mockDio.post('/api/guardia/validar_qr', data: anyNamed('data')))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: '/api/guardia/validar_qr'),
            error: 'Network error',
          ));

      // Act
      final result = await repository.validateQR('test-qr');

      // Assert
      expect(result.isValid, false);
      expect(result.message, contains('Error de conexión'));
    });
  });
}
