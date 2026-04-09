import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../estilos/icones.dart';
import '../../estilos/tema.dart';
import '../../modelos/animal.dart';
import '../../modelos/lote.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../servicos/banco_dados_servico.dart';
import '../10_formularios/form_pesagem.dart';
import '../10_formularios/form_reprodutivo.dart';
import '../10_formularios/form_leite.dart';
import '../10_formularios/form_sanitario.dart';
import 'form_animal.dart';

class TelaDetalhesAnimal extends StatefulWidget {
  final Animal animal;

  const TelaDetalhesAnimal({super.key, required this.animal});

  @override
  State<TelaDetalhesAnimal> createState() => _TelaDetalhesAnimalState();
}

class _TelaDetalhesAnimalState extends State<TelaDetalhesAnimal> {
  List<Map<String, dynamic>> _historico = [];
  bool _carregandoHistorico = true;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    final animalId = widget.animal.id;
    final db = BancoDadosServico.instancia;
    
    final pesagens = await db.getPesagensPorAnimal(animalId);
    final reprodutivos = await db.getEventosReprodutivosPorAnimal(animalId);
    final leite = await db.getProducaoLeitePorAnimal(animalId);
    final sanitarios = await db.getEventosSanitariosPorAnimal(animalId);
    final abates = await db.getAbatesPorAnimal(animalId);

    List<Map<String, dynamic>> temp = [];

    for (var p in pesagens) {
      temp.add({'tipo': 'Pesagem', 'data': p.data, 'desc': '${p.pesoKg} kg'});
    }
    for (var r in reprodutivos) {
      temp.add({'tipo': 'Reprodutivo', 'data': r.data, 'desc': '${r.tipo} ${r.resultado != null ? '(${r.resultado})' : ''}'});
    }
    for (var l in leite) {
      temp.add({'tipo': 'Leite', 'data': l.data, 'desc': '${l.litros} L - ${l.periodo}'});
    }
    for (var s in sanitarios) {
      temp.add({'tipo': 'Sanitário', 'data': DateTime.parse(s['data'].toString()), 'desc': '${s['tipo']} ${s['nomeMedicamento'] ?? ''}'});
    }
    for (var a in abates) {
      temp.add({'tipo': 'Abate', 'data': DateTime.parse(a['data'].toString()), 'desc': '${a['pesoCarcacaKg']} kg carcaça'});
    }

    temp.sort((a, b) => (b['data'] as DateTime).compareTo(a['data'] as DateTime));

    if (mounted) {
      setState(() {
        _historico = temp;
        _carregandoHistorico = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provedor = context.watch<ProvedorFazenda>();
    final animalAtual = provedor.animais
        .firstWhere((a) => a.id == widget.animal.id, orElse: () => widget.animal);
    final Lote? lote = provedor.lotes.isEmpty
        ? null
        : provedor.lotes.cast<Lote?>().firstWhere(
            (l) => l?.id == animalAtual.loteId,
            orElse: () => null,
          );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBarPadrao(
        titulo: animalAtual.nome != null && animalAtual.nome!.isNotEmpty
            ? animalAtual.nome!
            : 'Detalhes do Animal',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    IconesApp.iconAnimalSvg,
                    width: 40,
                    height: 48,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.onPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Brinco: ${animalAtual.brinco}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _badge(
                      animalAtual.sexo == 'M' ? 'Macho' : 'Fêmea',
                      Colors.white,
                      theme,
                    ),
                    const SizedBox(width: 8),
                    _badge(animalAtual.categoria, Colors.white, theme),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn().scale(),

          const SizedBox(height: 24),

          if (!animalAtual.isAtivo)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Este animal está inativo/morto.',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),

          _cartaoInfo(
            theme: theme,
            icon: Icons.fence_outlined,
            titulo: 'Lote',
            valor: lote?.nome ?? 'Lote não encontrado',
            subtitulo: lote?.tipo,
          ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1, end: 0),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _cartaoInfo(
                  theme: theme,
                  icon: Icons.pets,
                  titulo: 'Raça',
                  valor: animalAtual.raca,
                ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _cartaoInfo(
                  theme: theme,
                  icon: Icons.cake_outlined,
                  titulo: 'Idade',
                  valor: '${animalAtual.calcularIdadeMeses()} meses',
                ).animate().fadeIn(delay: 250.ms).slideX(begin: 0.1, end: 0),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            'PESO',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  IconesApp.peso,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Text(
                      '${animalAtual.pesoAtualKg}',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'kg',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 350.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),

          const SizedBox(height: 24),

          Text(
            'DATAS',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 12),

          _cartaoInfo(
            theme: theme,
            icon: Icons.calendar_today,
            titulo: 'Data de Nascimento',
            valor: DateFormat('dd/MM/yyyy').format(animalAtual.dataNascimento),
          ).animate().fadeIn(delay: 450.ms).slideX(begin: 0.1, end: 0),

          const SizedBox(height: 12),

          _cartaoInfo(
            theme: theme,
            icon: Icons.numbers,
            titulo: 'ID do Animal',
            valor: animalAtual.id,
            pequeno: true,
          ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0),

          const SizedBox(height: 32),

          Text(
            'AÇÕES RÁPIDAS',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ).animate().fadeIn(delay: 550.ms),
          const SizedBox(height: 12),
          
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _botaoAcao(
                  theme: theme,
                  icone: IconesApp.peso,
                  label: 'Pesagem',
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => FormPesagem(animalPreSelecionado: animalAtual)));
                    _carregarHistorico();
                  },
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(width: 12),
                _botaoAcao(
                  theme: theme,
                  icone: Icons.favorite,
                  label: 'Reprodutivo',
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => FormReprodutivo(animalPreSelecionado: animalAtual)));
                    _carregarHistorico();
                  },
                ).animate().fadeIn(delay: 650.ms),
                const SizedBox(width: 12),
                if (animalAtual.sexo == 'F') ...[
                  _botaoAcao(
                    theme: theme,
                    icone: Icons.water_drop,
                    label: 'Leite',
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => FormLeite(animalPreSelecionado: animalAtual)));
                      _carregarHistorico();
                    },
                  ).animate().fadeIn(delay: 700.ms),
                  const SizedBox(width: 12),
                ],
                _botaoAcao(
                  theme: theme,
                  icone: Icons.medical_services,
                  label: 'Sanitário',
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const FormSanitario()));
                    _carregarHistorico();
                  },
                ).animate().fadeIn(delay: 750.ms),
              ],
            ),
          ),

          const SizedBox(height: 32),
          
          Text(
            'REGISTROS POR CATEGORIA',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ).animate().fadeIn(delay: 800.ms),
          const SizedBox(height: 24),

          if (_carregandoHistorico)
            const Center(child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ))
          else if (_historico.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: const Center(
                child: Text('Nenhum registro encontrado.'),
              ),
            )
          else ...[
            _buildCategoriaRegistro('Pesagens', IconesApp.peso, 'Pesagem', theme),
            _buildCategoriaRegistro('Reprodutivo', Icons.favorite, 'Reprodutivo', theme),
            _buildCategoriaRegistro('Produção de Leite', Icons.water_drop, 'Leite', theme),
            _buildCategoriaRegistro('Sanitário', Icons.medical_services, 'Sanitário', theme),
            _buildCategoriaRegistro('Abates', Icons.restaurant, 'Abate', theme),
          ],

          const SizedBox(height: 100),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FormAnimal(animalExistente: animalAtual),
            ),
          );
        },
        icon: const Icon(Icons.edit),
        label: const Text('EDITAR'),
      ),
    );
  }

  Widget _badge(String texto, Color cor, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cor.withValues(alpha: 0.5)),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: cor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _cartaoInfo({
    required ThemeData theme,
    required IconData icon,
    required String titulo,
    required String valor,
    String? subtitulo,
    bool pequeno = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: pequeno
                      ? theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        )
                      : theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                ),
                if (subtitulo != null)
                  Text(
                    subtitulo,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaRegistro(String titulo, IconData icone, String tipoEvento, ThemeData theme) {
    final eventosFiltrados = _historico.where((e) => e['tipo'] == tipoEvento).toList();
    if (eventosFiltrados.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icone, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                titulo.toUpperCase(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...eventosFiltrados.map((evento) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        evento['desc'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy').format(evento['data'] as DateTime),
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _botaoAcao({
    required ThemeData theme,
    required IconData icone,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, color: theme.colorScheme.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
