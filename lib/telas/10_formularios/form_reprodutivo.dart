import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../estilos/icones.dart';
import '../../modelos/animal.dart';
import '../../modelos/eventos/evento_reprodutivo.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../servicos/banco_dados_servico.dart';

class FormReprodutivo extends StatefulWidget {
  final Animal? animalPreSelecionado;

  const FormReprodutivo({super.key, this.animalPreSelecionado});

  @override
  State<FormReprodutivo> createState() => _FormReprodutivoState();
}

class _FormReprodutivoState extends State<FormReprodutivo> {
  final _formKey = GlobalKey<FormState>();
  final _resultadoController = TextEditingController();
  final _obsController = TextEditingController();
  final _dataController = TextEditingController();

  late DateTime _dataSelecionada;
  String? _animalIdSelecionado;
  String _tipoSelecionado = 'Inseminação (IA)';
  bool _salvando = false;

  final List<String> _tipos = [
    'Inseminação (IA)',
    'Monta Natural',
    'Diagnóstico Gestação',
    'Parto',
    'Aborto',
    'Cio',
  ];

  @override
  void initState() {
    super.initState();
    _dataSelecionada = DateTime.now();
    _dataController.text = DateFormat('dd/MM/yyyy').format(_dataSelecionada);

    if (widget.animalPreSelecionado != null) {
      _animalIdSelecionado = widget.animalPreSelecionado!.id;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione um animal')));
      return;
    }

    setState(() => _salvando = true);

    try {
      final evento = EventoReprodutivo(
        animalId: _animalIdSelecionado!,
        data: _dataSelecionada,
        tipo: _tipoSelecionado,
        resultado: _resultadoController.text.isEmpty
            ? null
            : _resultadoController.text,
        observacao: _obsController.text.isEmpty ? null : _obsController.text,
      );

      await BancoDadosServico.instancia.salvarEventoReprodutivo(evento);

      if (mounted) {
        context.read<ProvedorFazenda>().carregarPropriedades();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evento reprodutivo salvo!'),
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
                'Reprodução',
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
                      _secaoTitulo('Data'),
                      const SizedBox(height: 12),
                      
                      TextFormField(
                        controller: _dataController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Data do Evento',
                          prefixIcon: const Icon(Icons.calendar_today),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        ),
                        onTap: _selecionarData,
                      ),
                      
                      const SizedBox(height: 24),
                      _secaoTitulo('Animal'),
                      const SizedBox(height: 12),

                      if (widget.animalPreSelecionado == null)
                        DropdownButtonFormField<String>(
                          value: _animalIdSelecionado,
                          decoration: InputDecoration(
                            labelText: 'Fêmea',
                            prefixIcon: const Icon(IconesApp.animal),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(IconesApp.animal, color: theme.colorScheme.primary),
                              const SizedBox(width: 12),
                              Text(
                                widget.animalPreSelecionado!.brinco,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),
                      _secaoTitulo('Detalhes'),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: _tipoSelecionado,
                        decoration: InputDecoration(
                          labelText: 'Tipo de Evento',
                          prefixIcon: const Icon(IconesApp.reproducao),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        ),
                        items: _tipos
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _tipoSelecionado = v!),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _resultadoController,
                        decoration: InputDecoration(
                          labelText: _getLabelResultado(),
                          prefixIcon: const Icon(Icons.info_outline),
                          hintText: _getHintResultado(),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _obsController,
                        decoration: InputDecoration(
                          labelText: 'Observação',
                          prefixIcon: const Icon(Icons.notes),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                                    const Text('SALVAR EVENTO'),
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

  String _getLabelResultado() {
    if (_tipoSelecionado.contains('Inseminação')) return 'Touro / Sêmen';
    if (_tipoSelecionado.contains('Diagnóstico'))
      return 'Resultado (Prenhe/Vazia)';
    if (_tipoSelecionado.contains('Parto')) return 'Sexo da Cria';
    return 'Resultado / Detalhe';
  }

  String _getHintResultado() {
    if (_tipoSelecionado.contains('Parto')) return 'Ex: Macho vivo';
    return '';
  }
}
