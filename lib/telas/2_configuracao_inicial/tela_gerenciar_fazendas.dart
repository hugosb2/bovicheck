import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../estilos/icones.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../modelos/propriedade.dart';
import '../../servicos/banco_dados_servico.dart';
import '../4_dashboard/tela_dashboard.dart';
import 'form_dados_fazenda.dart';
import '../../estilos/tema.dart';
import '../11_configuracoes/subtelas/tela_config_dados.dart';

class TelaGerenciarFazendas extends StatelessWidget {
  const TelaGerenciarFazendas({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provedor = context.watch<ProvedorFazenda>();
    final fazendas = provedor.propriedades;
    final fazendaAtiva = provedor.propriedadeAtiva;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBarPadrao(
        titulo: 'Minhas Fazendas',
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync_outlined),
            tooltip: 'Gerenciar Dados e Backup',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TelaConfigDados()),
              );
            },
          ),
        ],
      ),
      body: fazendas.isEmpty
          ? _estadoVazio(context, theme)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: fazendas.length,
              itemBuilder: (context, index) {
                final fazenda = fazendas[index];
                final isAtiva = fazenda.id == fazendaAtiva?.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _cartaoFazenda(
                    context,
                    theme,
                    fazenda,
                    isAtiva,
                    provedor,
                  ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormDadosFazenda()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('NOVA FAZENDA'),
      ),
    );
  }

  Widget _estadoVazio(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconesApp.fazenda,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma fazenda cadastrada',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Cadastre sua primeira fazenda para começar a gerenciar seu rebanho',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartaoFazenda(
    BuildContext context,
    ThemeData theme,
    Propriedade fazenda,
    bool isAtiva,
    ProvedorFazenda provedor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAtiva
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: isAtiva ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAtiva
              ? null
              : () async {
                  await provedor.selecionarFazenda(fazenda.id);
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const TelaDashboard()),
                      (route) => false,
                    );
                  }
                },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isAtiva
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      fazenda.nomeFazenda.isNotEmpty
                          ? fazenda.nomeFazenda[0].toUpperCase()
                          : 'F',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isAtiva
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              fazenda.nomeFazenda,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isAtiva)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'ATIVA',
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${fazenda.cidade} - ${fazenda.estado}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        fazenda.sistemaProducao,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'editar') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FormDadosFazenda(propriedadeExistente: fazenda),
                        ),
                      );
                    } else if (value == 'excluir') {
                      final confirmou = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Excluir Fazenda?'),
                          content: Text(
                            'Tem certeza que deseja excluir "${fazenda.nomeFazenda}"?\n\n'
                            'Isso também excluirá todos os lotes, animais e eventos desta fazenda.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('CANCELAR'),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('EXCLUIR'),
                            ),
                          ],
                        ),
                      );

                      if (confirmou == true && context.mounted) {
                        await BancoDadosServico.instancia
                            .deletePropriedade(fazenda.id);
                        await provedor.carregarPropriedades();

                        if (provedor.propriedadeAtiva?.id == fazenda.id) {
                          if (provedor.propriedades.isNotEmpty) {
                            await provedor
                                .selecionarFazenda(provedor.propriedades.first.id);
                          } else {
                            await provedor.selecionarFazenda('');
                          }
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fazenda excluída'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'excluir',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Excluir',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
