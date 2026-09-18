// Teste básico do projeto.
//
// Não testamos o app inteiro (ClubeDoLivroApp) aqui porque ele inicializa
// Firebase dentro do main() — para testar telas que dependem do Firebase
// (Auth/Firestore) seria necessário configurar mocks (ex.: com o pacote
// `firebase_auth_mocks` / `fake_cloud_firestore`). Por enquanto, mantemos
// um smoke test simples que garante que o tema do app é construído sem erros.

import 'package:flutter_test/flutter_test.dart';
import 'package:clube_do_livro/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AppTheme.light é construído sem erros', () {
    final tema = AppTheme.light;
    expect(tema.useMaterial3, isTrue);
  });
}
