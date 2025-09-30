import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:condominio_roles/features/auth/presentation/auth_providers.dart';
import 'package:condominio_roles/core/storage/secure_storage.dart';

@GenerateMocks([SecureStorage])
import 'auth_provider_test.mocks.dart';

void main() {
  group('AuthNotifier', () {
    late MockSecureStorage mockStorage;
    late ProviderContainer container;

    setUp(() {
      mockStorage = MockSecureStorage();
      container = ProviderContainer(
        overrides: [
          // Override with mock storage
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should set session and save tokens', () async {
      // Arrange
      when(mockStorage.saveTokens(access: anyNamed('access'), refresh: anyNamed('refresh')))
          .thenAnswer((_) async {});
      when(mockStorage.saveRole(any)).thenAnswer((_) async {});

      // Act
      final notifier = container.read(authStateProvider.notifier);
      await notifier.setSession(
        access: 'test-access',
        refresh: 'test-refresh',
        role: 'RESIDENTE',
      );

      // Assert
      final state = container.read(authStateProvider);
      expect(state.accessToken, 'test-access');
      expect(state.refreshToken, 'test-refresh');
      expect(state.role, 'RESIDENTE');
      expect(state.isAuthenticated, true);
    });

    test('should logout and clear storage', () async {
      // Arrange
      when(mockStorage.clear()).thenAnswer((_) async {});

      // Act
      final notifier = container.read(authStateProvider.notifier);
      await notifier.logout();

      // Assert
      final state = container.read(authStateProvider);
      expect(state.accessToken, null);
      expect(state.refreshToken, null);
      expect(state.role, null);
      expect(state.isAuthenticated, false);
    });
  });
}
