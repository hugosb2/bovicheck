import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../estilos/icones.dart';
import '../../modelos/animal.dart';
import '../../modelos/lote.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../servicos/banco_dados_servico.dart';

class FormAnimal extends StatefulWidget {
  final Animal? animalExistente;

  const FormAnimal({super.key, this.animalExistente});

  @override
  State<FormAnimal> createState() => _FormAnimalState();
}

class _FormAnimalState extends State<FormAnimal> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _brincoController = TextEditingController();
  final _nomeController = TextEditingController();
  final _racaController = TextEditingController();
  final _pesoController = TextEditingController();

  String? _loteSelecionadoId;
  String _sexo = 'M';
  String _categoria = 'Bezerro';
  DateTime _dataNascimento = DateTime.now();
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    if (widget.animalExistente != null) {
      final a = widget.animalExistente!;
      _brincoController.text = a.brinco;
      _nomeController.text = a.nome ?? '';
      _racaController.text = a.raca;
      _pesoController.text = a.pesoAtualKg.toString();
      _loteSelecionadoId = a.loteId;
      _sexo = a.sexo;
      _categoria = a.categoria;
      _dataNascimento = a.dataNascimento;
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_loteSelecionadoId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Selecione um lote')));
      return;
    }

    setState(() => _salvando = true);
    final provedor = context.read<ProvedorFazenda>();

    try {
      final novoAnimal = Animal(
        id: widget.animalExistente?.id ?? const Uuid().v4(),
        fazendaId: provedor.propriedadeAtiva!.id,
        loteId: _loteSelecionadoId!,
        brinco: _brincoController.text,
        nome: _nomeController.text.isEmpty ? null : _nomeController.text,
        raca: _racaController.text,
        sexo: _sexo,
        categoria: _categoria,
        dataNascimento: _dataNascimento,
        pesoAtualKg:
            double.tryParse(_pesoController.text.replaceAll(',', '.')) ?? 0.0,
        isAtivo: true,
      );

      final db = BancoDadosServico.instancia;

      if (widget.animalExistente != null) {
        await db.updateAnimal(novoAnimal);
      } else {
        await db.adicionarAnimal(novoAnimal);
      }

      // Atualiza lista no provedor
      await provedor.carregarAnimais(provedor.propriedadeAtiva!.id);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lotes = context.watch<ProvedorFazenda>().lotes;
    final isEdicao = widget.animalExistente != null;

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
                isEdicao ? 'Editar Animal' : 'Novo Animal',
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
                      _secaoTitulo('Identificação'),
                      const SizedBox(height: 12),
                      
                      TextFormField(
                        controller: _brincoController,
                        decoration: InputDecoration(
                          labelText: 'Brinco (Identificação)',
                          prefixIcon: const Icon(Icons.tag),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        ),
                        validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nomeController,
                        decoration: InputDecoration(
                          labelText: 'Nome (Opcional)',
                          prefixIcon: const Icon(Icons.text_fields),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        ),
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _loteSelecionadoId,
                        decoration: InputDecoration(
                          labelText: 'Lote / Pasto',
                          prefixIcon: const Icon(IconesApp.lote),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        ),
                        items: lotes
                            .map((l) => DropdownMenuItem(value: l.id, child: Text(l.nome)))
                            .toList(),
                        onChanged: (v) => setState(() => _loteSelecionadoId = v),
                        validator: (v) => v == null ? 'Selecione um lote' : null,
                      ),
                      
                      const SizedBox(height: 24),
                      _secaoTitulo('Informações'),
                      const SizedBox(height: 12),

                      Card(
                        elevation: 0,
                        color: theme.colorScheme.surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('Macho'),
                                  value: 'M',
                                  groupValue: _sexo,
                                  onChanged: (v) => setState(() => _sexo = v.toString()),
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('Fêmea'),
                                  value: 'F',
                                  groupValue: _sexo,
                                  onChanged: (v) => setState(() => _sexo = v.toString()),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                    Text(isEdicao ? 'SALVAR ALTERAÇÕES' : 'CADASTRAR ANIMAL'),
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
