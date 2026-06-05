import 'package:flutter/material.dart';
import '../../../../../core/temas/cores_app.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../painters/clouds_painter.dart';
import '../painters/landscape_painter.dart';
import 'tela_cadastro.dart';
import '../../../home/apresentacao/paginas/tela_inicial.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
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
                        onPressed: () async {
                          try {
                            final email = _emailController.text.trim();
                            final senha = _senhaController.text.trim();

                            if (email.isEmpty || senha.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Preencha email e senha'),
                                ),
                              );
                              return;
                            }

                            if (!email.toLowerCase().endsWith(
                              '@souunit.com.br',
                            )) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Utilize um email @souunit.com.br',
                                  ),
                                ),
                              );
                              return;
                            }

                            await _authService.loginComEmailSenha(email, senha);

                            if (!mounted) return;

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TelaInicial(),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Email ou senha inválidos'),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(height: 8),
                      CustomButton(
                        label: 'CADASTRAR',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TelaCadastro(),
                            ),
                          );
                        },
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
