import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

/// Serviço central de autenticação do MediCare.
///
/// Responsabilidades:
/// - Login com e-mail/senha.
/// - Login com Google (web e mobile).
/// - Validação OBRIGATÓRIA do domínio institucional `@souunit.com.br`,
///   aplicada de forma centralizada a todos os fluxos de autenticação.
/// - Logout completo (FirebaseAuth + GoogleSignIn).
class AuthService {
  /// Único ponto de verdade do domínio institucional permitido.
  static const String dominioInstitucional = '@souunit.com.br';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _googleInicializado = false;

  String? get usuarioLogadoEmail => _auth.currentUser?.email;

  /// Garante que o usuário autenticado pertence ao domínio institucional.
  ///
  /// Caso o e-mail não termine em [dominioInstitucional], faz logout imediato
  /// e lança um [FirebaseAuthException] com `code: 'invalid-domain'`.
  Future<void> _validarDominioInstitucional(User? user) async {
    final email = (user?.email ?? '').toLowerCase();

    if (!email.endsWith(dominioInstitucional)) {
      await logout();
      throw FirebaseAuthException(
        code: 'invalid-domain',
        message: 'Utilize um e-mail $dominioInstitucional',
      );
    }
  }

  /// Inicializa o GoogleSignIn uma única vez (exigido pela API 7.x).
  Future<void> _garantirGoogleInicializado() async {
    if (_googleInicializado) return;
    await _googleSignIn.initialize();
    _googleInicializado = true;
  }

  Future<UserCredential> loginComEmailSenha(String email, String senha) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
    await _validarDominioInstitucional(userCredential.user);
    return userCredential;
  }

  Future<UserCredential> cadastrarComEmailSenha(
    String email,
    String senha,
  ) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
    await _validarDominioInstitucional(userCredential.user);
    return userCredential;
  }

  Future<UserCredential> loginComGoogle() async {
    final UserCredential userCredential;

    if (kIsWeb) {
      // Na web o google_sign_in 7.x NÃO suporta authenticate();
      // o fluxo recomendado é o popup nativo do FirebaseAuth.
      final googleProvider = GoogleAuthProvider();
      userCredential = await _auth.signInWithPopup(googleProvider);
    } else {
      // Mobile/desktop: fluxo do google_sign_in 7.x.
      await _garantirGoogleInicializado();

      final GoogleSignInAccount conta = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = conta.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      userCredential = await _auth.signInWithCredential(credential);
    }

    await _validarDominioInstitucional(userCredential.user);
    return userCredential;
  }

  /// Logout completo: encerra a sessão do Firebase e limpa o cache do Google.
  Future<void> logout() async {
    if (!kIsWeb) {
      try {
        await _garantirGoogleInicializado();
        await _googleSignIn.signOut();
      } catch (_) {
        // Ignora caso o GoogleSignIn ainda não tenha sido utilizado.
      }
    }
    await _auth.signOut();
  } //FIM

  String? get usuarioLogadoEmail => _auth.currentUser?.email;
}
