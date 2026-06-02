import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _validarDominioInstitucional(User? user) {
    if (user == null) return;
    
    final email = user.email ?? "";
    
    if (!email.endsWith('@souunit.com.br')) {
      logout();
      throw Exception("Acesso negado. Utilize uma conta @souunit.com.br");
    }
  }

  Future<UserCredential> loginComEmailSenha(String email, String senha) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      
      _validarDominioInstitucional(userCredential.user);
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> cadastrarComEmailSenha(String email, String senha) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      
      _validarDominioInstitucional(userCredential.user);
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

//INICIO
  Future<void> logout() async {
    await _auth.signOut();
  } //FIM

  String? get usuarioLogadoEmail => _auth.currentUser?.email;
}