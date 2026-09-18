import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/participante.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Cria a conta no Auth e o documento correspondente em /participantes.
  /// O primeiro participante cadastrado no clube vira admin automaticamente.
  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
    final uid = cred.user!.uid;

    final participantesExistentes = await _db.collection('participantes').limit(1).get();
    final ehPrimeiro = participantesExistentes.docs.isEmpty;

    final participante = Participante(
      id: uid,
      nome: nome,
      isAdmin: ehPrimeiro,
    );

    await _db.collection('participantes').doc(uid).set(participante.toMap());
    await cred.user!.updateDisplayName(nome);
  }

  Future<void> entrar({required String email, required String senha}) async {
    await _auth.signInWithEmailAndPassword(email: email.trim(), password: senha);
  }

  Future<void> recuperarSenha(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> sair() async {
    await _auth.signOut();
  }
}
