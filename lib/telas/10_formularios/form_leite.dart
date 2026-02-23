import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../estilos/icones.dart';
import '../../modelos/animal.dart';
import '../../modelos/eventos/producao_leite.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../servicos/banco_dados_servico.dart';

class FormLeite extends StatefulWidget {
  final Animal? animalPreSelecionado;

  const FormLeite({super.key, this.animalPreSelecionado});

  @override
  State<FormLeite> createState() => _FormLeiteState();
}

class _FormLeiteState extends State<FormLeite> {
  final _formKey = GlobalKey<FormState>();
  final _litrosController = TextEditingController();
  final _obsController = TextEditingController();
  final _dataController = TextEditingController();
  
  late ScrollController _scrollController;
  bool _isCollapsed = false;

  late DateTime _dataSelecionada;
  String? _animalIdSelecionado;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    
    _dataSelecionada = DateTime.now();
    _dataController.text = DateFormat('dd/MM/yyyy').format(_dataSelecionada);

    if (widget.animalPreSelecionado != null) {
      _animalIdSelecionado = widget.animalPreSelecionado!.id;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _litrosController.dispose();
    _obsController.dispose();
    _dataController.dispose();
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

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dataSelecionada = picked;
        _dataController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_animalIdSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um animal'))
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      final litros = double.parse(_litrosController.text.replaceAll(',', '.'));

      final producao = ProducaoLeite(
        animalId: _animalIdSelecionado!,
        data: _dataSelecionada,
        litros: litros,
        observacao: _obsController.text.isEmpty ? null : _obsController.text,
      );

      await BancoDadosServico.instancia.salvarProducaoLeite(producao);

      if (mounted) {
        context.read<ProvedorFazenda>().carregarPropriedades();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produção salva!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provedor = context.watch<ProvedorFazenda>();
    final femeas = provedor.animais.where((a) => a.sexo == 'F').toList();

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
                child: const Text('Produção de Leite'),
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
                      _secaoTitulo('Data'),
                      const SizedBox(height: 12),
                      
                      TextFormField(
                        controller: _dataController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Data da Ordenha',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: _selecionarData,
                      ),
                      
                      const SizedBox(height: 24),
                      _secaoTitulo('Animal'),
                      const SizedBox(height: 12),

                      if (widget.animalPreSelecionado == null)
                        DropdownButtonFormField<String>(
                          value: _animalIdSelecionado,
                          decoration: const InputDecoration(
                            labelText: 'Vaca',
                            prefixIcon: Icon(IconesApp.animal),
                          ),
                          items: femeas
                              .map((a) => DropdownMenuItem(value: a.id, child: Text(a.brinco)))
                              .toList(),
                          onChanged: (v) => setState(() => _animalIdSelecionado = v),
                          validator: (v) => v == null ? 'Obrigatório' : null,
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(IconesApp.animal, color: theme.colorScheme.primary),
                              const SizedBox(width: 12),
                              Text(
                                widget.animalPreSelecionado!.brinco,
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),
                      _secaoTitulo('Produção'),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _litrosController,
                        decoration: const InputDecoration(
                          labelText: 'Litros',
                          prefixIcon: Icon(IconesApp.leite),
                          suffixText: 'L',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          if (v!.isEmpty) return 'Obrigatório';
                          if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _obsController,
                        decoration: const InputDecoration(
                          labelText: 'Observação (Ex: Ordenha manhã)',
                          prefixIcon: Icon(Icons.notes),
                        ),
                        maxLines: 2,
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
                                    const Text('SALVAR PRODUÇÃO'),
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
