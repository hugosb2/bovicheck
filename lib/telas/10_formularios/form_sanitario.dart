import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../estilos/icones.dart';
import '../../modelos/animal.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../servicos/banco_dados_servico.dart';

class EventoSanitario {
  final String id;
  final String animalId;
  final DateTime data;
  final String tipo;
  final String? nomeMedicamento;
  final String? observacao;

  EventoSanitario({
    required this.id,
    required this.animalId,
    required this.data,
    required this.tipo,
    this.nomeMedicamento,
    this.observacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animalId': animalId,
      'data': data.toIso8601String(),
      'tipo': tipo,
      'nomeMedicamento': nomeMedicamento,
      'observacao': observacao,
    };
  }
}

class FormSanitario extends StatefulWidget {
  final Animal? animal;
  const FormSanitario({super.key, this.animal});

  @override
  State<FormSanitario> createState() => _FormSanitarioState();
}

class _FormSanitarioState extends State<FormSanitario> {
  final _formKey = GlobalKey<FormState>();
  final _medicamentoController = TextEditingController();
  final _obsController = TextEditingController();
  
  late ScrollController _scrollController;
  bool _isCollapsed = false;

  DateTime _dataSelecionada = DateTime.now();
  String _tipoSelecionado = 'Vacina';
  String? _animalIdSelecionado;
  bool _salvando = false;

  final List<String> _tipos = [
    'Vacina',
    'Vermífugo',
    'Antibiótico',
    'Anti-inflamatório',
    'Anti-parasitário',
    'Vitaminas',
    'Castração',
    'Descarte',
    'Outro'
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    
    if (widget.animal != null) {
      _animalIdSelecionado = widget.animal!.id;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _medicamentoController.dispose();
    _obsController.dispose();
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
    if (_animalIdSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um animal'))
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      final evento = EventoSanitario(
        id: const Uuid().v4(),
        animalId: _animalIdSelecionado!,
        data: _dataSelecionada,
        tipo: _tipoSelecionado,
        nomeMedicamento: _medicamentoController.text.isEmpty ? null : _medicamentoController.text,
        observacao: _obsController.text.isEmpty ? null : _obsController.text,
      );

      await BancoDadosServico.instancia.salvarEventoSanitario(evento.toMap());

      if (mounted) {
        context.read<ProvedorFazenda>().carregarPropriedades();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro salvo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
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
    final listaAnimais = provedor.animais;

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
                child: const Text('Sanidade'),
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
                      _secaoTitulo('Animal'),
                      const SizedBox(height: 12),

                      if (widget.animal != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                IconesApp.iconAnimalSvg,
                                width: 32,
                                colorFilter: ColorFilter.mode(theme.colorScheme.primary, BlendMode.srcIn),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.animal!.brinco, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  Text(widget.animal!.nome ?? 'Sem nome', style: theme.textTheme.bodyMedium),
                                ],
                              ),
                            ],
                          ),
                        )
                      else
                        DropdownButtonFormField<String>(
                          value: _animalIdSelecionado,
                          decoration: const InputDecoration(
                            labelText: 'Selecione o Animal',
                            prefixIcon: Icon(IconesApp.animal),
                          ),
                          items: listaAnimais
                              .map((a) => DropdownMenuItem(
                                    value: a.id,
                                    child: Text("${a.brinco} - ${a.nome ?? ''}"),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _animalIdSelecionado = v),
                          validator: (v) => v == null ? 'Obrigatório' : null,
                        ),

                      const SizedBox(height: 24),
                      _secaoTitulo('Data'),
                      const SizedBox(height: 12),

                      InkWell(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _dataSelecionada,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (d != null) setState(() => _dataSelecionada = d);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Data do Evento',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(DateFormat('dd/MM/yyyy').format(_dataSelecionada)),
                        ),
                      ),

                      const SizedBox(height: 24),
                      _secaoTitulo('Informações'),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: _tipoSelecionado,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Evento',
                          prefixIcon: Icon(IconesApp.vacina),
                        ),
                        items: _tipos
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (v) => setState(() => _tipoSelecionado = v!),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _medicamentoController,
                        decoration: const InputDecoration(
                          labelText: 'Nome do Medicamento/Vacina',
                          prefixIcon: Icon(Icons.medication),
                        ),
                        validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _obsController,
                        decoration: const InputDecoration(
                          labelText: 'Observações',
                          prefixIcon: Icon(Icons.note),
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
                                    const Text('SALVAR REGISTRO'),
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
