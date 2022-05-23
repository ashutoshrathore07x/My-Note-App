import 'dart:math';

import 'package:myapp/serices/auth/auth_exceptions.dart';
import 'package:myapp/serices/auth/auth_provider.dart';
import 'package:myapp/serices/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('should not be intilaised to begin with', () {
      expect(provider.isInitialized, false);
    });
    test('cannot logout if not initialised', () {
      expect(
        'cannot log out if not initialized',
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });
    test('should be able to initilized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });
    test('user should be null after initialised ', () {
      expect(provider.currentUser, null);
    });

    test(
      'should be able to initilaised in less tham 2 seconds',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );
    test('create user should delegate to login function', () async {
      final badEmailuser = provider.createUser(
          email: 'ashutosh@gmail.com', password: 'ashutosh');
      expect(badEmailuser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));
      final badPassworduser = provider.createUser(
        email: 'ashutoshsingh@gmail.com',
        password: 'ashutosh1',
      );
      expect(badPassworduser,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));
      final user = await provider.createUser(
        email: 'ashu',
        password: 'tosh',
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });
    test('logged in user should be able to get verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });
    test('should be able to logout and login again', () async {
      await provider.logOut();
      await provider.logIn(
        email: 'email',
        password: 'password',
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'ashutosh@gmail.com') throw UserNotFoundAuthException();
    if (password == 'ashutosh') throw WrongPasswordAuthException();
    const user = AuthUser(
      isEmailVerified: false,
      email: 'foo@bar.com',
    );
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(
      isEmailVerified: true,
      email: 'foo@bar.com',
    );
    _user = newUser;
  }
}
