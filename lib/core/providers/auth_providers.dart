import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// ── Regular user auth (Supabase Auth) ─────────────────────────────
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  SupabaseClient get supabase => Supabase.instance.client;

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } on AuthException catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
        isAuthenticated: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
        isAuthenticated: false,
      );
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      final user = response.user;
      if (user != null) {
        // upsert (not insert) — a trigger or earlier test data may
        // already have created this row; upsert updates it instead
        // of failing on a duplicate primary key.
        await supabase.from('profiles').upsert({
          'id': user.id,
          'name': name,
        });
      }

      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } on AuthException catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
        isAuthenticated: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
        isAuthenticated: false,
      );
    }
  }

  void reset() {
    state = const AuthState();
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

// ── Admin auth (single static admin, no profiles/role table) ──────
// There is exactly one admin account. It was created once, manually, in
// Supabase Authentication → Users (email + password live only there,
// never in this codebase). We only need to confirm that the address
// which just signed in is that one known admin address.
class AdminIdentity {
  static const String email = 'admin@ecowise.com';
}

class AdminAuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  SupabaseClient get supabase => Supabase.instance.client;

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final signedInEmail = response.user?.email?.toLowerCase();

      if (signedInEmail == AdminIdentity.email.toLowerCase()) {
        state = state.copyWith(isLoading: false, isAuthenticated: true);
      } else {
        // Valid Supabase account, but not the admin account.
        await supabase.auth.signOut();
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'This account does not have admin access',
          isAuthenticated: false,
        );
      }
    } on AuthException catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
        isAuthenticated: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
        isAuthenticated: false,
      );
    }
  }

  void reset() {
    state = const AuthState();
  }
}

final adminAuthNotifierProvider = NotifierProvider<AdminAuthNotifier, AuthState>(
  AdminAuthNotifier.new,
);