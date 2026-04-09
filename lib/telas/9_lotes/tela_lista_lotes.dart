import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../estilos/icones.dart';
import '../../estilos/tema.dart';
import '../../provedores/provedor_fazenda.dart';
import 'form_lote.dart';
import 'tela_detalhes_lote.dart';

class TelaListaLotes extends StatefulWidget {
  const TelaListaLotes({super.key});

  @override
  State<TelaListaLotes> createState() => _TelaListaLotesState();
}

class _TelaListaLotesState extends State<TelaListaLotes> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provedor = context.watch<ProvedorFazenda>();
    final lotes = provedor.lotes;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const AppBarPadrao(
        titulo: 'Lotes & Pastos',
      ),
      body: lotes.isEmpty
          ? EstadoVazioPadrao(
              icone: IconesApp.lote,
              titulo: 'Nenhum lote cadastrado',
              mensagem: 'Crie um lote para organizar seus animais',
              textoBotao: 'CRIAR LOTE',
              onPressedBotao: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FormLote()),
                );
              },
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lotes.length,
              itemBuilder: (context, index) {
                final lote = lotes[index];
                final qtdAnimais = provedor.animais
                    .where((a) => a.loteId == lote.id)
                    .length;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CartaoPadrao(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TelaDetalhesLote(lote: lote),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            IconesApp.lote,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lote.nome,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lote.descricao.isNotEmpty
                                    ? lote.descricao
                                    : lote.tipo,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$qtdAnimais',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (index * 50).ms).slideX(),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormLote()),
          );
        },
        icon: const Icon(IconesApp.adicionar),
        label: const Text('NOVO LOTE'),
      ),
    );
  }
}
