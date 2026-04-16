import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../estilos/icones.dart';
import '../../../estilos/tema.dart';
import '../../2_configuracao_inicial/tela_restaurar.dart';
import 'tela_exportacao_avancada.dart';

class TelaConfigDados extends StatefulWidget {
  const TelaConfigDados({super.key});

  @override
  State<TelaConfigDados> createState() => _TelaConfigDadosState();
}

class _TelaConfigDadosState extends State<TelaConfigDados> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const AppBarPadrao(titulo: 'Dados & Backup'),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Banner Informativo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Exporte seus dados para backup ou compartilhe registros específicos de fazendas e animais.',
                    style: TextStyle(height: 1.4),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(),

          const SizedBox(height: 32),

          // Card Exportar (Unificado)
          _CardAcaoDados(
            titulo: 'Exportar Dados (Backup)',
            descricao: 'Crie um backup completo ou exporte apenas fazendas, lotes e animais selecionados.',
            icone: Icons.cloud_upload_outlined,
            cor: Colors.blue,
            textoBotao: 'CONFIGURAR EXPORTAÇÃO',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TelaExportacaoAvancada()),
              );
            },
          ),

          const SizedBox(height: 24),

          // Card Importar (Unificado)
          _CardAcaoDados(
            titulo: 'Importar Dados (Restaurar)',
            descricao: 'Restaure um backup completo ou adicione dados de arquivos .bvk exportados.',
            icone: Icons.cloud_download_outlined,
            cor: Colors.orange,
            textoBotao: 'SELECIONAR ARQUIVO',
            isOutlined: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TelaRestaurar()),
              );
            },
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

class _CardAcaoDados extends StatelessWidget {
  final String titulo;
  final String descricao;
  final IconData icone;
  final Color cor;
  final String textoBotao;
  final VoidCallback onTap;
  final bool isOutlined;

  const _CardAcaoDados({
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.cor,
    required this.textoBotao,
    required this.onTap,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icone, size: 40, color: cor),
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              descricao,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: isOutlined
                  ? OutlinedButton(onPressed: onTap, child: Text(textoBotao))
                  : FilledButton(
                      onPressed: onTap,
                      style: FilledButton.styleFrom(backgroundColor: cor),
                      child: Text(textoBotao)),
            ),
          ],
        ),
      ),
    ).animate().scale();
  }
}
