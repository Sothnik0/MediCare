import 'package:medicare/features/auth/apresentacao/paginas/tela_login.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../core/temas/cores_app.dart';
import '../../../../core/servicos/auth_service.dart';
import '../../../agenda/apresentacao/componentes/recortes_nuvem.dart';
import '../../../agenda/apresentacao/paginas/tela_agenda_medica.dart';
import '../../../medicamentos/apresentacao/paginas/tela_medicamentos.dart';
import '../../../buscar/apresentacao/paginas/tela_buscar.dart';
import '../componentes/banner_destaque.dart';
import '../componentes/botao_navegacao_home.dart';
import '../componentes/cartao_horizontal.dart';

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final nomeUsuario = user?.email?.split('@').first.toUpperCase() ?? 'USUÁRIO';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: CoresApp.gradienteBackground),
        child: SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(context, nomeUsuario),
              ),
              const SliverToBoxAdapter(child: BannerDestaque()),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: _buildNavegacao(context),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 4)),
              SliverToBoxAdapter(
                child: _buildCabecalhoSecao('FAVORITOS'),
              ),
              SliverToBoxAdapter(
                child: _buildCarrossel([
                  const CartaoHorizontal(
                    label: 'WEARABLE',
                    imgPath: 'assets/images/card_wearble.png',
                  ),
                  const CartaoHorizontal(
                    label: 'PRONTUÁRIO',
                    imgPath: 'assets/images/card_prontuario.png',
                  ),
                ]),
              ),
              SliverToBoxAdapter(
                child: _buildRodapeSecao(),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: _buildCabecalhoSecao('FUNCIONALIDADES'),
              ),
              SliverToBoxAdapter(
                child: _buildCarrossel([
                  CartaoHorizontal(
                    label: 'AGENDA',
                    imgPath: 'assets/images/card_agendamento.png',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TelaAgendaMedica()),
                    ),
                  ),
                  CartaoHorizontal(
                    label: 'MEDICAMENTOS',
                    imgPath: 'assets/images/card_remedios.png',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GerenciarMedicamentosPage()),
                    ),
                  ),
                  CartaoHorizontal(
                    label: 'BUSCAR',
                    imgPath: 'assets/images/card_emergencia.png',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TelaBuscar()),
                    ),
                  ),
                ]),
              ),
              SliverToBoxAdapter(
                child: _buildRodapeSecao(),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String nomeUsuario) {
    return ClipPath(
      clipper: RecorteNuvemSuperior(),
      child: Container(
        height: 130,
        color: CoresApp.fundoCreme,
        padding: const EdgeInsets.fromLTRB(20, 44, 20, 36),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/Logo.png',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 48,
                  height: 48,
                  color: CoresApp.azulCard,
                  child: const Icon(Icons.local_hospital, color: Colors.white),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'BEM-VINDO',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: CoresApp.textoSecundario,
                    fontFamily: 'Serif',
                  ),
                ),
                Text(
                  nomeUsuario,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CoresApp.textoForte,
                    fontFamily: 'Serif',
                  ),
                ),
              ],
            ),
            _BotaoSair(context: context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavegacao(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BotaoNavegacaoHome(
            icon: Icons.home_outlined,
            tooltip: 'Início',
            onTap: () {},
          ),
          BotaoNavegacaoHome(
            icon: Icons.search,
            tooltip: 'Buscar',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TelaBuscar()),
            ),
          ),
          BotaoNavegacaoHome(
            icon: Icons.assignment_outlined,
            tooltip: 'Agenda Médica',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TelaAgendaMedica()),
            ),
          ),
          BotaoNavegacaoHome(
            icon: Icons.medication_outlined,
            tooltip: 'Gerenciar Medicamentos',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GerenciarMedicamentosPage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCabecalhoSecao(String titulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipPath(
          clipper: RecorteNuvemInferior(),
          child: Container(height: 50, color: CoresApp.fundoCreme),
        ),
        Container(
          width: double.infinity,
          color: CoresApp.fundoCreme,
          padding: const EdgeInsets.only(left: 20, top: 4, bottom: 10),
          child: Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CoresApp.textoForte,
              fontFamily: 'Serif',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarrossel(List<Widget> cards) {
    return Container(
      color: CoresApp.fundoCreme,
      height: 145,
      width: double.infinity,
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
        ),
        child: CarouselSlider(
          options: CarouselOptions(
            height: 135,
            viewportFraction: 0.48,
            initialPage: 0,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            reverse: false,
            padEnds: false,
          ),
          items: cards,
        ),
      ),
    );
  }

  Widget _buildRodapeSecao() {
    return ClipPath(
      clipper: RecorteNuvemSuperior(),
      child: Container(height: 50, color: CoresApp.fundoCreme),
    );
  }
}

class _BotaoSair extends StatefulWidget {
  final BuildContext context;
  const _BotaoSair({required this.context});

  @override
  State<_BotaoSair> createState() => _BotaoSairState();
}

class _BotaoSairState extends State<_BotaoSair> {
  bool _hovering = false;

  void _onEnter(PointerEvent e) => setState(() => _hovering = true);
  void _onExit(PointerEvent e) => setState(() => _hovering = false);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        // INÍCIO
        onTap: () async {
          final confirma = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('Sair do app', style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold)),
              content: const Text('Deseja encerrar sua sessão?', style: TextStyle(fontFamily: 'Serif')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Não, Cancelar', style: TextStyle(color: Colors.grey, fontFamily: 'Serif', fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Sim, Sair', style: TextStyle(color: Colors.white, fontFamily: 'Serif')),
                ),
              ],
            ),
          );

          if (confirma == true) {
            await AuthService().logout();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const TelaLogin()),
                (Route<dynamic> route) => false,
              );
            }
          }
        },
        // FIM
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _hovering ? Colors.red.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.logout,
            color: _hovering ? Colors.red : CoresApp.textoForte,
            size: 26,
          ),
        ),
      ),
    );
  }
}