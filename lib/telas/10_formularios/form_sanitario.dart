import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import necessário para o SVG
import '../../estilos/icones.dart';
import '../../modelos/animal.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../servicos/banco_dados_servico.dart';

// Modelo Local (para garantir funcionamento isolado)
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

  DateTime _dataSelecionada = DateTime.now();
  String _tipoSelecionado = 'Vacina';
  String? _animalIdSelecionado;
  bool _salvando = false;

  final List<String> _tipos = [
    'Vacina',
    'Vermífugo',
    'Antibiótico',
    'Vitamina',
    'Outros'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.animal != null) {
      _animalIdSelecionado = widget.animal!.id;
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_animalIdSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um animal!')),
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
        nomeMedicamento: _medicamentoController.text,
        observacao: _obsController.text,
      );

      await BancoDadosServico.instancia.salvarEventoSanitario(evento.toMap());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Evento sanitário registrado!'),
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

  // Estilo "Caixa" (Outline) que você prefere
  InputDecoration _inputDecor(String label,
      {IconData? icon, Widget? customIcon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: customIcon ?? (icon != null ? Icon(icon) : null),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provedor = context.watch<ProvedorFazenda>();
    final listaAnimais = provedor.animais;

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
                'Sanidade',
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
                      _secaoTitulo('Animal'),
                      const SizedBox(height: 12),

                      if (widget.animal != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(IconesApp.iconAnimalSvg,
                                width: 32, height: 32,
                                colorFilter: ColorFilter.mode(theme.colorScheme.primary, BlendMode.srcIn)),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.animal!.brinco,
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  Text(widget.animal!.nome ?? 'Sem nome',
                                      style: theme.textTheme.bodyMedium),
                                ],
                              ),
                            ],
                          ),
                        )
                      else
                        DropdownButtonFormField<String>(
                          value: _animalIdSelecionado,
                          decoration: InputDecoration(
                            labelText: 'Selecione o Animal',
                            prefixIcon: SvgPicture.asset(IconesApp.iconAnimalSvg,
                              width: 24, height: 24,
                              colorFilter: ColorFilter.mode(theme.colorScheme.primary, BlendMode.srcIn)),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                          decoration: InputDecoration(
                            labelText: 'Data do Evento',
                            prefixIcon: const Icon(Icons.calendar_today),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          ),
                          child: Text(DateFormat('dd/MM/yyyy').format(_dataSelecionada)),
                        ),
                      ),

                      const SizedBox(height: 24),
                      _secaoTitulo('Informações'),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: _tipoSelecionado,
                        decoration: InputDecoration(
                          labelText: 'Tipo de Evento',
                          prefixIcon: const Icon(IconesApp.vacina),
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
                        controller: _medicamentoController,
                        decoration: InputDecoration(
                          labelText: 'Nome do Medicamento/Vacina',
                          prefixIcon: const Icon(Icons.medication),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        ),
                        validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _obsController,
                        decoration: InputDecoration(
                          labelText: 'Observações',
                          prefixIcon: const Icon(Icons.note),
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
