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
  
  late ScrollController _scrollController;
  bool _isCollapsed = false;

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
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    
    if (widget.loteExistente != null) {
      _nomeController.text = widget.loteExistente!.nome;
      _descController.text = widget.loteExistente!.descricao;
      if (_tipos.contains(widget.loteExistente!.tipo)) {
        _tipoSelecionado = widget.loteExistente!.tipo;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _nomeController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      bool deveColapsar = _scrollController.offset > 90;
      if (deveColapsar != _isCollapsed) {
        setState(() => _isCollapsed = deveColapsar);
      }
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    final provedor = context.read<ProvedorFazenda>();

    try {
      final novoLote = Lote(
        id: widget.loteExistente?.id,
        fazendaId: provedor.propriedadeAtiva!.id,
        nome: _nomeController.text.trim(),
        descricao: _descController.text.trim(),
        tipo: _tipoSelecionado,
      );

      await provedor.adicionarLote(novoLote);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.loteExistente != null 
                  ? 'Lote atualizado com sucesso!' 
                  : 'Lote criado com sucesso!'),
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

    final Color corAppBarBg =
        _isCollapsed ? theme.colorScheme.primary : theme.colorScheme.surface;
    final Color corElementos =
        _isCollapsed ? theme.colorScheme.onPrimary : theme.colorScheme.primary;
    final EdgeInsets paddingTitulo = _isCollapsed
        ? const EdgeInsets.only(left: 72, bottom: 16)
        : const EdgeInsets.only(left: 16, bottom: 16);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: corAppBarBg,
            foregroundColor: corElementos,
            iconTheme: IconThemeData(color: corElementos),
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: paddingTitulo,
              expandedTitleScale: 1.6,
              title: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: corElementos,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                child: Text(isEdicao ? 'Editar Lote' : 'Novo Lote'),
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
                        ),
                        validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        value: _tipoSelecionado,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Instalação',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: _tipos
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (v) => setState(() => _tipoSelecionado = v!),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição (Opcional)',
                          hintText: 'Ex: Capacidade para 50 cabeças, capim Braquiária',
                          prefixIcon: Icon(Icons.notes),
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
