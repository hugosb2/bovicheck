import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../estilos/icones.dart';
import '../../modelos/lote.dart';
import '../../provedores/provedor_fazenda.dart';

class FormLote extends StatefulWidget {
  final Lote? loteExistente;

  const FormLote({super.key, this.loteExistente});

  @override
  State<FormLote> createState() => _FormLoteState();
}

class _FormLoteState extends State<FormLote> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descController = TextEditingController();

  String _tipoSelecionado = 'Pasto';
  bool _salvando = false;

  final List<String> _tipos = [
    'Pasto',
    'Confinamento',
    'Maternidade',
    'Curral',
    'Outro'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.loteExistente != null) {
      _nomeController.text = widget.loteExistente!.nome;
      _descController.text = widget.loteExistente!.descricao;
      if (_tipos.contains(widget.loteExistente!.tipo)) {
        _tipoSelecionado = widget.loteExistente!.tipo;
      }
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    final provedor = context.read<ProvedorFazenda>();

    try {
      final novoLote = Lote(
        id: widget.loteExistente?.id, // Se for edição, mantém o ID
        propriedadeId: provedor.propriedadeAtiva!.id,
        nome: _nomeController.text.trim(),
        descricao: _descController.text.trim(),
        tipo: _tipoSelecionado,
      );

      await provedor.adicionarLote(
          novoLote); // O método no provedor deve lidar com Insert ou Update (ajustaremos se necessário)

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Lote salvo com sucesso!'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdicao = widget.loteExistente != null;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
              expandedTitleScale: 1.6,
              title: Text(
                isEdicao ? 'Editar Lote' : 'Novo Lote',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
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
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _secaoTitulo('Dados do Lote'),
                      const SizedBox(height: 12),
                      
                      TextFormField(
                        controller: _nomeController,
                        decoration: InputDecoration(
                          labelText: 'Nome do Lote/Pasto',
                          hintText: 'Ex: Pasto do Fundo, Piquete 1',
                          prefixIcon: const Icon(IconesApp.lote),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        ),
                        validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        value: _tipoSelecionado,
                        decoration: InputDecoration(
                          labelText: 'Tipo de Instalação',
                          prefixIcon: const Icon(Icons.category_outlined),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        ),
                        items: _tipos
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (v) => setState(() => _tipoSelecionado = v!),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _descController,
                        decoration: InputDecoration(
                          labelText: 'Descrição (Opcional)',
                          hintText: 'Ex: Capacidade para 50 cabeças, capim Braquiária',
                          prefixIcon: const Icon(Icons.notes),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        ),
                        maxLines: 3,
                      ),
                      
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: _salvando ? null : _salvar,
                          child: _salvando
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(IconesApp.salvar),
                                    const SizedBox(width: 8),
                                    Text(isEdicao ? 'SALVAR ALTERAÇÕES' : 'CRIAR LOTE'),
                                  ],
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _secaoTitulo(String texto) {
    final theme = Theme.of(context);
    return Text(
      texto.toUpperCase(),
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}
