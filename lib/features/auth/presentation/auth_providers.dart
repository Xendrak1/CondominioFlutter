import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/secure_storage.dart';

class AuthState {
  const AuthState({this.accessToken, this.refreshToken, this.role});
  final String? accessToken;
  final String? refreshToken;
  final String? role;
  bool get isAuthenticated => accessToken != null && accessToken!.isNotEmpty && role != null && role!.isNotEmpty;
  AuthState copyWith({String? accessToken, String? refreshToken, String? role}) => AuthState(
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        role: role ?? this.role,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._storage) : super(const AuthState()) {
    restore();
  }

  final SecureStorage _storage;

  Future<void> restore() async {
    final access = await _storage.access;
    final refresh = await _storage.refresh;
    final role = await _storage.role;
    if ((access ?? '').isNotEmpty && (role ?? '').isNotEmpty) {
      state = AuthState(accessToken: access, refreshToken: refresh, role: role);
    }
  }

  Future<void> setSession({required String access, required String refresh, required String role}) async {
    await _storage.saveTokens(access: access, refresh: refresh);
    await _storage.saveRole(role);
    state = AuthState(accessToken: access, refreshToken: refresh, role: role);
  }

  Future<void> logout() async {
    await _storage.clear();
    state = const AuthState();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(SecureStorage()));
