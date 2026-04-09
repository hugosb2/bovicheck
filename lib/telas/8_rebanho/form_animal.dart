import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../estilos/icones.dart';
import '../../modelos/animal.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../servicos/banco_dados_servico.dart';

class FormAnimal extends StatefulWidget {
  final Animal? animalExistente;

  const FormAnimal({super.key, this.animalExistente});

  @override
  State<FormAnimal> createState() => _FormAnimalState();
}

class _FormAnimalState extends State<FormAnimal> {
  final _pageController = PageController();
  int _etapaAtual = 0;
  final int _totalEtapas = 3;

  final _brincoController = TextEditingController();
  final _nomeController = TextEditingController();
  final _racaController = TextEditingController();
  final _pesoController = TextEditingController();

  String? _loteSelecionadoId;
  String _sexo = 'M';
  String _categoria = 'Bezerro';
  DateTime _dataNascimento = DateTime.now();
  bool _salvando = false;

  final List<String> _categorias = [
    'Bezerro',
    'Bezerra',
    'Novilho',
    'Novilha',
    'Boi',
    'Vaca',
    'Touro',
    'Outro',
  ];

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

  @override
  void dispose() {
    _pageController.dispose();
    _brincoController.dispose();
    _nomeController.dispose();
    _racaController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  void _irParaEtapa(int etapa) {
    setState(() => _etapaAtual = etapa);
    _pageController.animateToPage(
      etapa,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  bool _validarEtapaIdentificacao() {
    if (_brincoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o número do brinco')),
      );
      return false;
    }
    if (_loteSelecionadoId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione um lote/pasto')));
      return false;
    }
    return true;
  }

  bool _validarEtapaCaracteristicas() {
    if (_racaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha a raça do animal')),
      );
      return false;
    }
    return true;
  }

  void _proximaEtapa() {
    if (_etapaAtual == 0 && !_validarEtapaIdentificacao()) return;
    if (_etapaAtual == 1 && !_validarEtapaCaracteristicas()) return;
    if (_etapaAtual < _totalEtapas - 1) {
      _irParaEtapa(_etapaAtual + 1);
    } else {
      _salvar();
    }
  }

  void _etapaAnterior() {
    if (_etapaAtual > 0) {
      _irParaEtapa(_etapaAtual - 1);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _salvar() async {
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

      await provedor.carregarAnimais(provedor.propriedadeAtiva!.id);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.animalExistente != null
                  ? 'Animal atualizado com sucesso!'
                  : 'Animal criado com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataNascimento,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (data != null) {
      setState(() => _dataNascimento = data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdicao = widget.animalExistente != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _etapaAnterior();
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              _etapaAtual == 0 ? Icons.close : Icons.arrow_back,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: _etapaAnterior,
          ),
          title: Text(
            isEdicao ? 'Editar Animal' : 'Novo Animal',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: theme.colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: _buildBarraProgresso(theme),
          ),
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _PaginaIdentificacao(
              brincoController: _brincoController,
              nomeController: _nomeController,
              loteSelecionadoId: _loteSelecionadoId,
              onLoteChanged: (v) => setState(() => _loteSelecionadoId = v),
              onChanged: () => setState(() {}),
            ),
            _PaginaCaracteristicas(
              racaController: _racaController,
              sexo: _sexo,
              categoria: _categoria,
              categorias: _categorias,
              dataNascimento: _dataNascimento,
              onSexoChanged: (v) => setState(() => _sexo = v),
              onCategoriaChanged: (v) => setState(() => _categoria = v),
              onDataNascimentoTap: _selecionarData,
            ),
            _PaginaConfirmacao(
              pesoController: _pesoController,
              brinco: _brincoController.text,
              nome: _nomeController.text,
              sexo: _sexo,
              raca: _racaController.text,
              categoria: _categoria,
              dataNascimento: _dataNascimento,
              loteSelecionadoId: _loteSelecionadoId,
            ),
          ],
        ),
        bottomNavigationBar: _buildBotoes(theme, isEdicao),
      ),
    );
  }

  Widget _buildBarraProgresso(ThemeData theme) {
    final titulos = ['Identificação', 'Características', 'Confirmação'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalEtapas, (i) {
              final bool ativo = i <= _etapaAtual;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: ativo
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                    if (i < _totalEtapas - 1) const SizedBox(width: 6),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_totalEtapas, (i) {
              final bool ativo = i <= _etapaAtual;
              final bool atual = i == _etapaAtual;
              return GestureDetector(
                onTap: () {
                  if (i < _etapaAtual) {
                    _irParaEtapa(i);
                  }
                },
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: atual ? FontWeight.bold : FontWeight.normal,
                    color: atual
                        ? theme.colorScheme.primary
                        : ativo
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.outline,
                  ),
                  child: Text(titulos[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBotoes(ThemeData theme, bool isEdicao) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Row(
          children: [
            if (_etapaAtual > 0)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: OutlinedButton.icon(
                  onPressed: _etapaAnterior,
                  icon: const Icon(Icons.arrow_back, size: 20),
                  label: const Text('VOLTAR'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 56),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _salvando ? null : _proximaEtapa,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _salvando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _etapaAtual == _totalEtapas - 1
                                  ? IconesApp.salvar
                                  : Icons.arrow_forward,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _etapaAtual == _totalEtapas - 1
                                  ? (isEdicao
                                        ? 'SALVAR ALTERAÇÕES'
                                        : 'CADASTRAR ANIMAL')
                                  : 'PRÓXIMO',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// PÁGINA 1 — IDENTIFICAÇÃO
// ============================================================================

class _PaginaIdentificacao extends StatelessWidget {
  final TextEditingController brincoController;
  final TextEditingController nomeController;
  final String? loteSelecionadoId;
  final ValueChanged<String?> onLoteChanged;
  final VoidCallback onChanged;

  const _PaginaIdentificacao({
    required this.brincoController,
    required this.nomeController,
    required this.loteSelecionadoId,
    required this.onLoteChanged,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lotes = context.watch<ProvedorFazenda>().lotes;
    final completo =
        brincoController.text.isNotEmpty && loteSelecionadoId != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Identificação do Animal',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Preencha os dados básicos de identificação',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          TextFormField(
            controller: brincoController,
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              labelText: 'Brinco (Identificação) *',
              prefixIcon: const Icon(Icons.tag),
              hintText: 'Ex: 001, A-123',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: nomeController,
            decoration: InputDecoration(
              labelText: 'Nome (Opcional)',
              prefixIcon: const Icon(Icons.text_fields),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            value: loteSelecionadoId,
            decoration: InputDecoration(
              labelText: 'Lote / Pasto *',
              prefixIcon: const Icon(IconesApp.lote),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            items: lotes
                .map((l) => DropdownMenuItem(value: l.id, child: Text(l.nome)))
                .toList(),
            onChanged: onLoteChanged,
          ),
          const SizedBox(height: 24),

          if (completo)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Identificação completa',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// PÁGINA 2 — CARACTERÍSTICAS
// ============================================================================

class _PaginaCaracteristicas extends StatelessWidget {
  final TextEditingController racaController;
  final String sexo;
  final String categoria;
  final List<String> categorias;
  final DateTime dataNascimento;
  final ValueChanged<String> onSexoChanged;
  final ValueChanged<String> onCategoriaChanged;
  final VoidCallback onDataNascimentoTap;

  const _PaginaCaracteristicas({
    required this.racaController,
    required this.sexo,
    required this.categoria,
    required this.categorias,
    required this.dataNascimento,
    required this.onSexoChanged,
    required this.onCategoriaChanged,
    required this.onDataNascimentoTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Características',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Informe os detalhes do animal',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          Text(
            'Sexo',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _OpcaoSexo(
                  icone: Icons.male,
                  rotulo: 'Macho',
                  valor: 'M',
                  selecionado: sexo == 'M',
                  corAtiva: Colors.blue,
                  onTap: () => onSexoChanged('M'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OpcaoSexo(
                  icone: Icons.female,
                  rotulo: 'Fêmea',
                  valor: 'F',
                  selecionado: sexo == 'F',
                  corAtiva: Colors.pink,
                  onTap: () => onSexoChanged('F'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: racaController,
            decoration: InputDecoration(
              labelText: 'Raça *',
              prefixIcon: const Icon(IconesApp.animal),
              hintText: 'Ex: Nelore, Angus, Girolando',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            value: categoria,
            decoration: InputDecoration(
              labelText: 'Categoria',
              prefixIcon: const Icon(Icons.category_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            items: categorias
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => onCategoriaChanged(v!),
          ),
          const SizedBox(height: 20),

          InkWell(
            onTap: onDataNascimentoTap,
            borderRadius: BorderRadius.circular(16),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Data de Nascimento',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(DateFormat('dd/MM/yyyy').format(dataNascimento)),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpcaoSexo extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String valor;
  final bool selecionado;
  final Color corAtiva;
  final VoidCallback onTap;

  const _OpcaoSexo({
    required this.icone,
    required this.rotulo,
    required this.valor,
    required this.selecionado,
    required this.corAtiva,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selecionado
              ? corAtiva.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selecionado
                ? corAtiva
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: selecionado ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icone,
              size: 32,
              color: selecionado ? corAtiva : theme.colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              rotulo,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: selecionado ? corAtiva : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// PÁGINA 3 — CONFIRMAÇÃO
// ============================================================================

class _PaginaConfirmacao extends StatelessWidget {
  final TextEditingController pesoController;
  final String brinco;
  final String nome;
  final String sexo;
  final String raca;
  final String categoria;
  final DateTime dataNascimento;
  final String? loteSelecionadoId;

  const _PaginaConfirmacao({
    required this.pesoController,
    required this.brinco,
    required this.nome,
    required this.sexo,
    required this.raca,
    required this.categoria,
    required this.dataNascimento,
    required this.loteSelecionadoId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lotes = context.watch<ProvedorFazenda>().lotes;
    final nomeLote = lotes
        .where((l) => l.id == loteSelecionadoId)
        .map((l) => l.nome)
        .firstOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Peso e Confirmação',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Informe o peso e revise os dados antes de salvar',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          TextFormField(
            controller: pesoController,
            decoration: InputDecoration(
              labelText: 'Peso (Kg)',
              prefixIcon: const Icon(IconesApp.peso),
              suffixText: 'kg',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 32),

          Text(
            'RESUMO DOS DADOS',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              children: [
                _linhaResumo(context, Icons.tag, 'Brinco', brinco),
                if (nome.isNotEmpty)
                  _linhaResumo(context, Icons.text_fields, 'Nome', nome),
                _linhaResumo(
                  context,
                  sexo == 'M' ? Icons.male : Icons.female,
                  'Sexo',
                  sexo == 'M' ? 'Macho' : 'Fêmea',
                ),
                _linhaResumo(context, IconesApp.animal, 'Raça', raca),
                _linhaResumo(
                  context,
                  Icons.category_outlined,
                  'Categoria',
                  categoria,
                ),
                _linhaResumo(
                  context,
                  Icons.calendar_today,
                  'Nascimento',
                  DateFormat('dd/MM/yyyy').format(dataNascimento),
                ),
                _linhaResumo(
                  context,
                  IconesApp.lote,
                  'Lote',
                  nomeLote ?? 'Não selecionado',
                ),
                if (pesoController.text.isNotEmpty)
                  _linhaResumo(
                    context,
                    IconesApp.peso,
                    'Peso',
                    '${pesoController.text} kg',
                    isUltimo: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _linhaResumo(
    BuildContext context,
    IconData icone,
    String rotulo,
    String valor, {
    bool isUltimo = false,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icone, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                rotulo,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  valor,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (!isUltimo)
          Divider(
            height: 1,
            indent: 48,
            endIndent: 16,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
      ],
    );
  }
}
