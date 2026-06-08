import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/temas/cores_app.dart';
import '../../../../core/widgets/custom_button.dart';
import '../painters/clouds_painter.dart';
import '../painters/landscape_painter.dart';
import 'tela_cadastro.dart';
import '../../../../core/servicos/auth_service.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _carregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _mostrarMensagem(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  /// Converte códigos de erro do Firebase em mensagens amigáveis.
  String _mensagemErroFirebase(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-domain':
        return 'Utilize um e-mail ${AuthService.dominioInstitucional}';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'E-mail ou senha inválidos.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'network-request-failed':
        return 'Falha de conexão. Verifique sua internet.';
      default:
        return 'Não foi possível entrar. Tente novamente.';
    }
  }

  Future<void> _loginComEmailSenha() async {
    if (_carregando) return;

    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      _mostrarMensagem('Preencha e-mail e senha.');
      return;
    }

    // Validação rápida de UX. A validação definitiva é feita no AuthService.
    if (!email.toLowerCase().endsWith(AuthService.dominioInstitucional)) {
      _mostrarMensagem('Utilize um e-mail ${AuthService.dominioInstitucional}');
      return;
    }

    setState(() => _carregando = true);
    try {
      await _authService.loginComEmailSenha(email, senha);
      // Não navega manualmente: o authStateChanges() no main.dart troca a tela.
    } on FirebaseAuthException catch (e) {
      _mostrarMensagem(_mensagemErroFirebase(e));
    } catch (_) {
      _mostrarMensagem('Não foi possível entrar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _loginComGoogle() async {
    if (_carregando) return;

    setState(() => _carregando = true);
    try {
      await _authService.loginComGoogle();
      // Não navega manualmente: o authStateChanges() no main.dart troca a tela.
    } on GoogleSignInException catch (e) {
      // Cancelamento pelo usuário (mobile) não é tratado como erro grave.
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      _mostrarMensagem('Falha no login com Google.');
    } on FirebaseAuthException catch (e) {
      // Cancelamento do popup (web) também não é erro grave.
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request' ||
          e.code == 'web-context-canceled') {
        return;
      }
      _mostrarMensagem(_mensagemErroFirebase(e));
    } catch (_) {
      _mostrarMensagem('Falha no login com Google.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _irParaCadastro() {
    if (_carregando) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TelaCadastro()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Gradiente de fundo ciano
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  CoresApp.loginCianoClaro,
                  CoresApp.loginCianoPrincipal,
                ],
              ),
            ),
          ),

          // Nuvens no topo
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomPaint(size: Size(width, 90), painter: CloudsPainter()),
          ),

          // Paisagem na base
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(width, 260),
              painter: LandscapePainter(),
            ),
          ),

          // Conteúdo
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),

                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: CoresApp.textoDark, width: 2),
                    color: CoresApp.nuvemBranco,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'MEDICARE',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w400,
                    color: CoresApp.textoDark,
                    letterSpacing: 2,
                    fontFamily: 'Serif',
                  ),
                ),

                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email institucional',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: TextField(
                    controller: _senhaController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Senha',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    children: [
                      CustomButton(
                        label: 'ENTRAR',
                        onPressed: _loginComEmailSenha,
                      ),
                      const SizedBox(height: 8),
                      CustomButton(
                        label: 'ENTRAR COM GOOGLE',
                        onPressed: _loginComGoogle,
                      ),
                      const SizedBox(height: 8),
                      CustomButton(
                        label: 'CADASTRAR',
                        onPressed: _irParaCadastro,
                      ),
                      if (_carregando)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
