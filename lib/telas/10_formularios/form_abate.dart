import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../estilos/icones.dart';
import '../../modelos/animal.dart';
import '../../modelos/eventos/abate.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../servicos/banco_dados_servico.dart';

class FormAbate extends StatefulWidget {
  final Animal? animalPreSelecionado;

  const FormAbate({super.key, this.animalPreSelecionado});

  @override
  State<FormAbate> createState() => _FormAbateState();
}

class _FormAbateState extends State<FormAbate> {
  final _formKey = GlobalKey<FormState>();
  final _pesoVivoController = TextEditingController();
  final _pesoCarcacaController = TextEditingController();
  final _observacaoController = TextEditingController();

  DateTime _dataAbate = DateTime.now();
  String? _animalIdSelecionado;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    if (widget.animalPreSelecionado != null) {
      _animalIdSelecionado = widget.animalPreSelecionado!.id;
      _pesoVivoController.text = widget.animalPreSelecionado!.pesoAtualKg.toString();
    }
  }

  @override
  void dispose() {
    _pesoVivoController.dispose();
    _pesoCarcacaController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? colhida = await showDatePicker(
      context: context,
      initialDate: _dataAbate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (colhida != null && colhida != _dataAbate) {
      setState(() => _dataAbate = colhida);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_animalIdSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um animal')),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      final abate = Abate(
        id: const Uuid().v4(),
        animalId: _animalIdSelecionado!,
        data: _dataAbate,
        pesoVivoKg: double.parse(_pesoVivoController.text.replaceAll(',', '.')),
        pesoCarcacaKg: double.parse(_pesoCarcacaController.text.replaceAll(',', '.')),
        observacao: _observacaoController.text,
      );

      // Usando o método correto do banco
      await BancoDadosServico.instancia.salvarAbate(abate.toMap());

      if (mounted) {
        final provedor = context.read<ProvedorFazenda>();
        await provedor.carregarAnimais(provedor.propriedadeAtiva!.id);
        
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Abate registrado com sucesso!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
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
      appBar: AppBar(
        title: const Text('Registrar Abate'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informações do Animal',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _animalIdSelecionado,
                        decoration: InputDecoration(
                          labelText: 'Selecione o animal',
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(IconesApp.animal),
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
                        onChanged: (val) {
                          setState(() {
                            _animalIdSelecionado = val;
                            if (val != null) {
                              final animal = listaAnimais.firstWhere((a) => a.id == val);
                              _pesoVivoController.text = animal.pesoAtualKg.toString();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Dados do Abate',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Data do Abate'),
                subtitle: Text('${_dataAbate.day}/${_dataAbate.month}/${_dataAbate.year}'),
                trailing: TextButton(
                  onPressed: () => _selecionarData(context),
                  child: const Text('ALTERAR'),
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pesoVivoController,
                      decoration: const InputDecoration(
                        labelText: 'Peso Vivo (kg) *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.monitor_weight_outlined),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => (val == null || val.isEmpty) ? 'Obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _pesoCarcacaController,
                      decoration: const InputDecoration(
                        labelText: 'Carcaça (kg) *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.fitness_center),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => (val == null || val.isEmpty) ? 'Obrigatório' : null,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              TextFormField(
                controller: _observacaoController,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _salvando ? null : _salvar,
                  child: _salvando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('REGISTRAR ABATE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
