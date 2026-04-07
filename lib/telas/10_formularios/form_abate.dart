import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../modelos/animal.dart';
import '../../modelos/eventos/abate.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../servicos/banco_dados_servico.dart';

class FormAbate extends StatefulWidget {
  final Animal? animal;
  const FormAbate({super.key, this.animal});

  @override
  State<FormAbate> createState() => _FormAbateState();
}

class _FormAbateState extends State<FormAbate> {
  final _formKey = GlobalKey<FormState>();
  final _pesoVivoController = TextEditingController();
  final _pesoCarcacaController = TextEditingController();
  final _obsController = TextEditingController();

  DateTime _dataSelecionada = DateTime.now();
  String? _animalIdSelecionado;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    if (widget.animal != null) {
      _animalIdSelecionado = widget.animal!.id;
    }
  }

  @override
  void dispose() {
    _pesoVivoController.dispose();
    _pesoCarcacaController.dispose();
    _obsController.dispose();
    super.dispose();
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
      final abate = Abate(
        animalId: _animalIdSelecionado!,
        data: _dataSelecionada,
        pesoVivoKg: double.parse(_pesoVivoController.text),
        pesoCarcacaKg: double.parse(_pesoCarcacaController.text),
        observacao: _obsController.text.isEmpty ? null : _obsController.text,
      );

      await BancoDadosServico.instancia.salvarAbate(abate.toMap());

      if (mounted) {
        context.read<ProvedorFazenda>().carregarPropriedades();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro de abate salvo com sucesso!'),
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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(
              'Registrar Abate',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            backgroundColor: Colors.green,
            surfaceTintColor: Colors.transparent,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Animal',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              initialValue: _animalIdSelecionado,
                              decoration: const InputDecoration(
                                labelText: 'Selecione o animal',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.pets),
                              ),
                              items: listaAnimais
                                  .where((a) => a.isAtivo)
                                  .map(
                                    (animal) => DropdownMenuItem(
                                      value: animal.id,
                                      child: Text(
                                        '${animal.brinco} - ${animal.nome ?? animal.raca}',
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (valor) {
                                setState(() => _animalIdSelecionado = valor);
                              },
                              validator: (valor) =>
                                  valor == null ? 'Selecione um animal' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dados do Abate',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () => _selecionarData(context),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Data do Abate',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(_dataSelecionada),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _pesoVivoController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Peso Vivo (kg)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.scale),
                              ),
                              validator: (valor) {
                                if (valor == null || valor.isEmpty) {
                                  return 'Informe o peso vivo';
                                }
                                if (double.tryParse(valor) == null) {
                                  return 'Peso inválido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _pesoCarcacaController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Peso Carcaça (kg)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.scale_outlined),
                              ),
                              validator: (valor) {
                                if (valor == null || valor.isEmpty) {
                                  return 'Informe o peso carcaça';
                                }
                                if (double.tryParse(valor) == null) {
                                  return 'Peso inválido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _obsController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Observação (opcional)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.note),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _salvando ? null : _salvar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                        ),
                        child: _salvando
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'SALVAR REGISTRO',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
      });
    }
  }
}
