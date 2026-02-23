import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../estilos/icones.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../modelos/propriedade.dart';
import '../4_dashboard/tela_dashboard.dart';
import 'form_dados_fazenda.dart';

class TelaSelecionarFazenda extends StatefulWidget {
  const TelaSelecionarFazenda({super.key});

  @override
  State<TelaSelecionarFazenda> createState() => _TelaSelecionarFazendaState();
}

class _TelaSelecionarFazendaState extends State<TelaSelecionarFazenda> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProvedorFazenda>().carregarPropriedades();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provedor = context.watch<ProvedorFazenda>();
    final fazendas = provedor.propriedades;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      floatingActionButton: fazendas.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _mostrarOpcoesAdicionar(context),
              icon: const Icon(Icons.add),
              label: const Text('Nova Fazenda'),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              expandedTitleScale: 1.6,
              title: Text(
                'Fazendas',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                color: theme.colorScheme.surface,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/icon.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Center(
                    child: Text(
                      'BoviCheck',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Center(
                    child: Text(
                      'Selecione uma fazenda para continuar',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  if (fazendas.isEmpty) ...[
                    _estadoVazio(theme),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _mostrarOpcoesAdicionar(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Criar Primeira Fazenda'),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'MINHAS FAZENDAS',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    ...fazendas.asMap().entries.map((entry) {
                      final index = entry.key;
                      final fazenda = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _cartaoFazenda(
                          context,
                          theme,
                          fazenda,
                          provedor,
                        ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _estadoVazio(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.agriculture_outlined,
            size: 64,
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma fazenda cadastrada',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie sua primeira fazenda para começar a gerenciar seu rebanho',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _cartaoFazenda(
    BuildContext context,
    ThemeData theme,
    Propriedade fazenda,
    ProvedorFazenda provedor,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selecionarFazenda(context, fazenda, provedor),
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
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
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fazenda.nomeFazenda,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${fazenda.cidade} - ${fazenda.estado}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      fazenda.sistemaProducao,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selecionarFazenda(
    BuildContext context,
    Propriedade fazenda,
    ProvedorFazenda provedor,
  ) async {
    await provedor.selecionarFazenda(fazenda.id);
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TelaDashboard()),
      );
    }
  }

  void _criarNovaFazenda(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FormDadosFazenda()),
    );
  }

  void _mostrarOpcoesAdicionar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Adicionar Fazenda',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add_business,
                    color: Theme.of(ctx).colorScheme.primary,
                  ),
                ),
                title: const Text('Criar nova fazenda'),
                subtitle: const Text('Cadastrar uma nova propriedade'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FormDadosFazenda()),
                  );
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.file_upload,
                    color: Theme.of(ctx).colorScheme.secondary,
                  ),
                ),
                title: const Text('Importar backup'),
                subtitle: const Text('Restaurar de arquivo .bvk'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidade de importação em desenvolvimento')),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
