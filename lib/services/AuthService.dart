import 'dart:async';

enum UserRole {
  admin,
  client,
  presseur,
  other,
}

class AuthService {
  Future<UserRole?> signInWithPhoneAndPassword(String phone, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (phone.isEmpty || password.isEmpty) {
      return null;
    }
    final normalized = phone.replaceAll(' ', '').toLowerCase();
    if (normalized.contains('admin')) return UserRole.admin;
    if (normalized.contains('client')) return UserRole.client;
    if (normalized.contains('benef')) return UserRole.presseur;
    return UserRole.other;
  }
}



