import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/participante.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

/// Mantém o usuário logado e o respectivo documento de Participante,
/// atualizando automaticamente quando o Firestore muda (ex.: virou admin).
class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? firebaseUser;
  Participante? participante;
  bool carregando = true;

  UserProvider() {
    _authService.authStateChanges.listen(_onAuthChanged);
  }

  bool get logado => firebaseUser != null;
  bool get isAdmin => participante?.isAdmin ?? false;

  Future<void> _onAuthChanged(User? user) async {
    firebaseUser = user;
    if (user == null) {
      participante = null;
      carregando = false;
      notifyListeners();
      return;
    }
    participante = await _firestoreService.getParticipante(user.uid);
    carregando = false;
    notifyListeners();
  }

  Future<void> recarregarParticipante() async {
    if (firebaseUser == null) return;
    participante = await _firestoreService.getParticipante(firebaseUser!.uid);
    notifyListeners();
  }
}
