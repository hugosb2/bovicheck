import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../estilos/icones.dart';
import '../../../estilos/tema.dart';
import '../../../modelos/propriedade.dart';
import '../../../provedores/provedor_fazenda.dart';
import '../../../servicos/banco_dados_servico.dart';

// Importando o arquivo original do formulário
import '../../2_configuracao_inicial/form_dados_fazenda.dart';

class TelaDetalhesFazenda extends StatefulWidget {
  const TelaDetalhesFazenda({super.key});

  @override
  State<TelaDetalhesFazenda> createState() => _TelaDetalhesFazendaState();
}

class _TelaDetalhesFazendaState extends State<TelaDetalhesFazenda> {
  Future<void> _exportarFazenda(BuildContext context, Propriedade fazenda) async {
    try {
      final jsonStr = await BancoDadosServico.instancia.exportarFazendaJson(fazenda.id);
      final bytes = utf8.encode(jsonStr);
      final dataStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final nomeArquivo = 'BoviCheck_Fazenda_${fazenda.nomeFazenda}_$dataStr.fbvk';

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$nomeArquivo');
      await file.writeAsBytes(bytes);

      if (context.mounted) {
        final xFile = XFile(file.path);
        await Share.shareXFiles(
          [xFile],
          text: 'Backup da fazenda ${fazenda.nomeFazenda}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar fazenda: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provedor = context.watch<ProvedorFazenda>();
    final fazenda = provedor.propriedadeAtiva;

    if (fazenda == null) {
      return const Scaffold(
          body: Center(child: Text("Nenhuma fazenda selecionada.")));
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBarPadrao(
        titulo: fazenda.nomeFazenda,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Exportar Fazenda',
            onPressed: () => _exportarFazenda(context, fazenda),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Cabeçalho Simplificado (estilo Detalhes Animal)
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
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      fazenda.nomeFazenda.isNotEmpty
                          ? fazenda.nomeFazenda[0].toUpperCase()
                          : 'F',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 16),
                Text(
                  fazenda.nomeFazenda,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ).animate().fadeIn(delay: 200.ms),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Dados da Fazenda
          _InfoCard(
            label: "Nome da Fazenda",
            valor: fazenda.nomeFazenda,
            icon: IconesApp.fazenda,
          ),

          const SizedBox(height: 16),

          _InfoCard(
            label: "Proprietário",
            valor: fazenda.nomeProprietario,
            icon: Icons.person,
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  label: "Cidade",
                  valor: fazenda.cidade,
                  icon: Icons.location_city,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InfoCard(
                  label: "UF",
                  valor: fazenda.estado,
                  icon: Icons.map,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  label: "Sistema",
                  valor: fazenda.sistemaProducao,
                  icon: Icons.settings_input_component,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InfoCard(
                  label: "Área (ha)",
                  valor: fazenda.areaTotalHectares
                      .toString()
                      .replaceAll('.', ','),
                  icon: Icons.aspect_ratio,
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          Center(
            child: SelectableText(
              "ID: ${fazenda.id}",
              style: TextStyle(
                  color: Colors.grey.withValues(alpha: 0.5),
                  fontSize: 12),
            ),
          ),

          const SizedBox(height: 24),

          _botaoDanger(theme, fazenda),

          const SizedBox(height: 100),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // Usa o formulário original para editar
              builder: (_) => FormDadosFazenda(propriedadeExistente: fazenda),
            ),
          );
        },
        icon: const Icon(Icons.edit),
        label: const Text("EDITAR DADOS"),
      ),
    );
  }

  Widget _botaoDanger(ThemeData theme, Propriedade fazenda) {
    return Card(
      elevation: 0,
      color: Colors.red.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: () => _confirmarDelecao(context, fazenda),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete_forever, color: Colors.red, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DELETAR FAZENDA',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Remover esta fazenda e todos os dados',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.red.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.red),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  void _confirmarDelecao(BuildContext context, Propriedade fazenda) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deletar fazenda?'),
        content: Text(
          'Tem certeza que deseja deletar "${fazenda.nomeFazenda}"? '
          'Todos os dados serão perdidos permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETAR'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    await BancoDadosServico.instancia.deletePropriedade(fazenda.id);
    
    if (!mounted) return;
    
    final provedor = context.read<ProvedorFazenda>();
    await provedor.carregarPropriedades();
    
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${fazenda.nomeFazenda}" deletada')),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icon;

  const _InfoCard(
      {required this.label, required this.valor, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                  child: Icon(icon, size: 16, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              valor,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}
