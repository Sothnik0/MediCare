import 'package:flutter/material.dart';
import '../../../../../core/temas/cores_app.dart';
import 'tela_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/servicos/auth_service.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _nomeController = TextEditingController();
  final _nascimentoController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nomeController.dispose();
    _senhaController.dispose();
    _nascimentoController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Fundo marrom gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  CoresApp.soloClaro,
                  CoresApp.soloMarrom,
                  CoresApp.soloEscuro,
                ],
              ),
            ),
          ),

          // Topo verde com ondas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 260,
              child: Stack(
                children: [
                  // Grama (fica na frente)
                  CustomPaint(
                    size: Size(width, 190),
                    painter: _GrassTopPainter(),
                  ),
                ],
              ),
            ),
          ),

          // Conteúdo
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 26),

                  const Text(
                    'CADASTRO',
                    style: TextStyle(
                      fontSize: 42,
                      color: CoresApp.textoBranco,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Serif',
                    ),
                  ),

                  const SizedBox(height: 90),

                  _buildField(
                    label: 'NOME COMPLETO',
                    controller: _nomeController,
                  ),
                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          label: 'NASCIMENTO',
                          controller: _nascimentoController,
                          hint: '__ / __ / ____',
                          keyboard: TextInputType.datetime,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildField(
                          label: 'CPF',
                          controller: _cpfController,
                          hint: '___.___.___-__',
                          keyboard: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  _buildField(
                    label: 'E-MAIL',
                    controller: _emailController,
                    keyboard: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 22),

                  _buildField(
                    label: 'SENHA',
                    controller: _senhaController,
                    obscureText: true,
                  ),

                  const SizedBox(height: 44),
                  _buildConfirmButton(),
                  const SizedBox(height: 130),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboard,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipPath(
        clipper: RockFieldClipper(),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            24, // esquerda
            18, // topo
            24, // direita
            18, // baixo
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF9A8F80),
                Color(0xFF6D6358),
                Color(0xFF4C453F),
                Color(0xFF3A342F),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  letterSpacing: 1.4,
                  fontFamily: 'Serif',
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7E0D4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: keyboard,
                  obscureText: obscureText,
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: () async {
        try {
          if (!_emailController.text.trim().toLowerCase().endsWith(
            '@souunit.com.br',
          )) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Utilize um email @souunit.com.br')),
            );

            return;
          }

          if (_senhaController.text.trim().isEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Informe uma senha')));
            return;
          }

          await _authService.cadastrarComEmailSenha(
            _emailController.text.trim(),
            _senhaController.text.trim(),
          );

          if (!mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TelaConfirmacaoCadastro()),
          );
        } on FirebaseAuthException catch (e) {
          String mensagem = 'Erro ao cadastrar';

          if (e.code == 'email-already-in-use') {
            mensagem = 'Este email já está cadastrado';
          }

          if (e.code == 'weak-password') {
            mensagem = 'A senha deve ter pelo menos 6 caracteres';
          }

          if (e.code == 'invalid-domain') {
            mensagem = 'Utilize um email @souunit.com.br';
          }

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(mensagem)));
        }
      },
      child: Container(
        width: 210,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFFF6F1D7), Color(0xFFE7D8AA)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'CONFIRMAR',
            style: TextStyle(
              color: CoresApp.textoDark,
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
              fontFamily: 'Serif',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CoresApp.campoGray.withOpacity(0.95),
            CoresApp.campoGrayClaro.withOpacity(0.92),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(45),
          topRight: Radius.circular(45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 70,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.45),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TELA DE CONFIRMAÇÃO
// ─────────────────────────────────────────────
class TelaConfirmacaoCadastro extends StatelessWidget {
  const TelaConfirmacaoCadastro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CoresApp.soloClaro,
              CoresApp.soloMarrom,
              CoresApp.soloEscuro,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 280,
                height: 220,
                decoration: BoxDecoration(
                  color: CoresApp.campoGray,
                  borderRadius: BorderRadius.circular(34),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'CADASTRO\nCONFIRMADO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      color: CoresApp.textoBranco,
                      letterSpacing: 2,
                      fontFamily: 'Serif',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              GestureDetector(
                onTap: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const TelaLogin()),
                  (route) => false,
                ),
                child: Container(
                  width: 200,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF6F1D7), Color(0xFFE7D8AA)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'ENTRAR',
                      style: TextStyle(
                        color: CoresApp.textoDark,
                        fontSize: 16,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Serif',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PAINTER: Topo verde com ondas (grama)
// ─────────────────────────────────────────────
class _GrassTopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF388E3C), Color(0xFF1B5E20)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height * .72)
      ..quadraticBezierTo(
        size.width * .12,
        size.height * .92,
        size.width * .25,
        size.height * .72,
      )
      ..quadraticBezierTo(
        size.width * .40,
        size.height * .50,
        size.width * .55,
        size.height * .76,
      )
      ..quadraticBezierTo(
        size.width * .70,
        size.height * .98,
        size.width * .84,
        size.height * .70,
      )
      ..quadraticBezierTo(
        size.width * .93,
        size.height * .52,
        size.width,
        size.height * .74,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawShadow(path, Colors.black54, 8, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class RockFieldClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(size.width * 0.12, size.height * 0.04);

    // TOPO
    path.quadraticBezierTo(
      size.width * 0.28,
      size.height * 0.06,
      size.width * 0.50,
      size.height * 0.04,
    );

    path.quadraticBezierTo(
      size.width * 0.72,
      size.height * 0.02,
      size.width * 0.88,
      size.height * 0.04,
    );

    // ESPELHO EXATO DO CANTO SUPERIOR ESQUERDO
    path.quadraticBezierTo(
      size.width * 0.94,
      size.height * 0.06,
      size.width * 0.96,
      size.height * 0.12,
    );

    // ESPELHO EXATO DA LATERAL ESQUERDA
    path.quadraticBezierTo(
      size.width * 0.98,
      size.height * 0.20,
      size.width * 0.99,
      size.height * 0.42,
    );

    path.quadraticBezierTo(
      size.width,
      size.height * 0.64,
      size.width * 0.98,
      size.height * 0.84,
    );

    // ESPELHO EXATO DO CANTO INFERIOR ESQUERDO
    path.quadraticBezierTo(
      size.width * 0.94,
      size.height * 0.97,
      size.width * 0.78,
      size.height,
    );

    // BASE
    path.quadraticBezierTo(
      size.width * 0.60,
      size.height * 0.99,
      size.width * 0.44,
      size.height,
    );

    path.quadraticBezierTo(
      size.width * 0.40,
      size.height * 0.99,
      size.width * 0.22,
      size.height,
    );

    // CANTO INFERIOR ESQUERDO
    path.quadraticBezierTo(
      size.width * 0.06,
      size.height * 0.97,
      size.width * 0.02,
      size.height * 0.84,
    );

    // LATERAL ESQUERDA
    path.quadraticBezierTo(
      0,
      size.height * 0.64,
      size.width * 0.01,
      size.height * 0.42,
    );

    path.quadraticBezierTo(
      size.width * 0.02,
      size.height * 0.20,
      size.width * 0.04,
      size.height * 0.12,
    );

    // FECHAMENTO SUAVE
    path.quadraticBezierTo(
      size.width * 0.06,
      size.height * 0.06,
      size.width * 0.12,
      size.height * 0.04,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
