import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../estilos/icones.dart';
import '../../estilos/tema.dart';
import '../../provedores/provedor_fazenda.dart';
import 'form_piquete.dart';
import 'tela_detalhes_piquete.dart';

class TelaListaPiquetes extends StatefulWidget {
  const TelaListaPiquetes({super.key});

  @override
  State<TelaListaPiquetes> createState() => _TelaListaPiquetesState();
}

class _TelaListaPiquetesState extends State<TelaListaPiquetes> {
  final TextEditingController _buscaController = TextEditingController();
  String _filtroTexto = '';

  @override
  void initState() {
    super.initState();
    _buscaController.addListener(() {
      setState(() {
        _filtroTexto = _buscaController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provedor = context.watch<ProvedorFazenda>();
    
    final piquetesFiltrados = provedor.piquetes.where((piquete) {
      return piquete.nome.toLowerCase().contains(_filtroTexto) ||
             piquete.descricao.toLowerCase().contains(_filtroTexto) ||
             piquete.tipo.toLowerCase().contains(_filtroTexto);
    }).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const AppBarPadrao(titulo: 'Piquetes & Pastos', centralizar: true),
      body: Column(
        children: [
          // 1. Barra de Busca Moderna
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                hintText: 'Buscar piquete ou pasto...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _filtroTexto.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => _buscaController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ),

          // 2. Lista de Piquetes
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => await provedor.carregarPropriedades(),
              child: provedor.piquetes.isEmpty
                  ? _EstadoVazioPiquetes(theme: theme)
                  : piquetesFiltrados.isEmpty
                      ? _EstadoVazioBuscaPiquetes(filtro: _filtroTexto, theme: theme)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          physics: const BouncingScrollPhysics(),
                          itemCount: piquetesFiltrados.length,
                          itemBuilder: (context, index) {
                            final piquete = piquetesFiltrados[index];
                            final qtdAnimais = provedor.animais.where((a) => a.loteId == piquete.id).length;
                            return _CardPiqueteModerno(piquete: piquete, qtd: qtdAnimais, index: index);
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: BotaoFlutuanteBovi(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FormPiquete())),
        icone: Icons.add_location_alt_rounded,
        label: 'NOVO PIQUETE',
      ),
    );
  }
}

class _CardPiqueteModerno extends StatelessWidget {
  final dynamic piquete;
  final int qtd;
  final int index;

  const _CardPiqueteModerno({required this.piquete, required this.qtd, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasAnimais = qtd > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TelaDetalhesPiquete(piquete: piquete))),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(IconesApp.piquete, color: theme.colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(piquete.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(piquete.descricao.isNotEmpty ? piquete.descricao : 'Tipo: ${piquete.tipo}', 
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: hasAnimais ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$qtd',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: hasAnimais ? Colors.white : theme.colorScheme.outline,
                      ),
                    ),
                    Text(
                      'animais',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: hasAnimais ? Colors.white.withValues(alpha: 0.8) : theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0),
    );
  }
}

class _EstadoVazioPiquetes extends StatelessWidget {
  final ThemeData theme;
  const _EstadoVazioPiquetes({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 80, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const Text('Nenhum piquete ou pasto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Organize seu rebanho dividindo a fazenda em áreas de manejo.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            BotaoPadrao(
              label: 'CRIAR PIQUETE AGORA',
              icone: Icons.add_location_alt_rounded,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FormPiquete())),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoVazioBuscaPiquetes extends StatelessWidget {
  final String filtro;
  final ThemeData theme;
  const _EstadoVazioBuscaPiquetes({required this.filtro, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_rounded, size: 64, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            'Nenhum piquete encontrado para "$filtro"',
            style: TextStyle(color: theme.colorScheme.outline, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
