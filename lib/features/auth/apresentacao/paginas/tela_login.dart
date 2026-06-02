import 'package:flutter/material.dart';
import '../../../../../core/temas/cores_app.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../painters/clouds_painter.dart';
import '../painters/landscape_painter.dart';
import 'tela_cadastro.dart';
import '../../../home/apresentacao/paginas/tela_inicial.dart';

class TelaLogin extends StatelessWidget {
  const TelaLogin({super.key});

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
                colors: [CoresApp.loginCianoClaro, CoresApp.loginCianoPrincipal],
              ),
            ),
          ),

          // Nuvens no topo
          Positioned(
            top: 0, left: 0, right: 0,
            child: CustomPaint(
              size: Size(width, 90),
              painter: CloudsPainter(),
            ),
          ),

          // Paisagem na base
          Positioned(
            bottom: 0, left: 0, right: 0,
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

                // Logo PNG circular
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

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    children: [
                      CustomButton(
                        label: 'ENTRAR',
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const TelaInicial()),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      CustomButton(
                        label: 'CADASTRAR',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TelaCadastro()),
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