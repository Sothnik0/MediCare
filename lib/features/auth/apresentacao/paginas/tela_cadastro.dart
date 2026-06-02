import 'package:flutter/material.dart';
import '../../../../../core/temas/cores_app.dart';
import 'tela_login.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _nomeController       = TextEditingController();
  final _nascimentoController = TextEditingController();
  final _cpfController        = TextEditingController();
  final _emailController      = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
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
                colors: [CoresApp.soloClaro, CoresApp.soloMarrom, CoresApp.soloEscuro],
              ),
            ),
          ),

          // Topo verde com ondas
          Positioned(
            top: 0, left: 0, right: 0,
            child: CustomPaint(
              size: Size(width, 190),
              painter: _GrassTopPainter(),
            ),
          ),

          // Barra decorativa inferior
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomBar(),
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

                  _buildField(label: 'NOME COMPLETO', controller: _nomeController),
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: CoresApp.campoGray.withOpacity(0.78),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
            style: const TextStyle(
              fontSize: 12,
              color: CoresApp.textoBranco,
              letterSpacing: 1.4,
              fontFamily: 'Serif',
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: CoresApp.inputGray.withOpacity(0.95),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboard,
              style: const TextStyle(color: CoresApp.textoDark, fontSize: 15),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: CoresApp.textoDark.withOpacity(0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TelaConfirmacaoCadastro()),
        );
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
              fontSize: 17,
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
            colors: [CoresApp.soloClaro, CoresApp.soloMarrom, CoresApp.soloEscuro],
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
        colors: [Color(0xFF3F9142), Color(0xFF2E7D32), Color(0xFF1B5E20)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.10, size.height * 0.88, size.width * 0.22, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.52, size.width * 0.50, size.height * 0.74)
      ..quadraticBezierTo(size.width * 0.66, size.height * 0.96, size.width * 0.80, size.height * 0.70)
      ..quadraticBezierTo(size.width * 0.90, size.height * 0.52, size.width,         size.height * 0.74)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawShadow(path, Colors.black, 10, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}