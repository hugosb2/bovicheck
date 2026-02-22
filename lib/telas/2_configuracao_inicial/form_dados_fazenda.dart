import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../estilos/icones.dart';
import '../../modelos/propriedade.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../servicos/preferencias_usuario.dart';
import '../../servicos/banco_dados_servico.dart';
import '../4_dashboard/tela_dashboard.dart';

class FormDadosFazenda extends StatefulWidget {
  final Propriedade? propriedadeExistente;

  const FormDadosFazenda({super.key, this.propriedadeExistente});

  @override
  State<FormDadosFazenda> createState() => _FormDadosFazendaState();
}

class _FormDadosFazendaState extends State<FormDadosFazenda> {
  final _formKey = GlobalKey<FormState>();

  late ScrollController _scrollController;
  bool _isCollapsed = false;

  final _nomeFazendaController = TextEditingController();
  final _proprietarioController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _areaController = TextEditingController();

  String? _estadoSelecionado;
  String _sistemaProducao = 'Extensivo';
  bool _salvando = false;

  final List<String> _estados = [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO',
  ];

  final List<String> _sistemas = [
    'Extensivo',
    'Semi-Confinamento',
    'Confinamento',
    'Leiteiro'
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    if (widget.propriedadeExistente != null) {
      final p = widget.propriedadeExistente!;
      _nomeFazendaController.text = p.nomeFazenda;
      _proprietarioController.text = p.nomeProprietario;
      _cidadeController.text = p.cidade;
      _areaController.text =
          p.areaTotalHectares.toString().replaceAll('.', ',');
      _sistemaProducao = p.sistemaProducao;
      if (_estados.contains(p.estado)) _estadoSelecionado = p.estado;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _nomeFazendaController.dispose();
    _proprietarioController.dispose();
    _cidadeController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      bool deveColapsar = _scrollController.offset > 90;
      if (deveColapsar != _isCollapsed)
        setState(() => _isCollapsed = deveColapsar);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_estadoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione o Estado (UF)')));
      return;
    }

    setState(() => _salvando = true);

    try {
      final novaFazenda = Propriedade(
        id: widget.propriedadeExistente?.id ?? const Uuid().v4(),
        nomeFazenda: _nomeFazendaController.text.trim(),
        nomeProprietario: _proprietarioController.text.trim(),
        cidade: _cidadeController.text.trim(),
        estado: _estadoSelecionado!,
        sistemaProducao: _sistemaProducao,
        // Garante envio de valores nulos ou 0.0 para evitar erro de modelo
        gpsLat: widget.propriedadeExistente?.gpsLat ?? 0.0,
        gpsLong: widget.propriedadeExistente?.gpsLong ?? 0.0,
        areaTotalHectares:
            double.tryParse(_areaController.text.replaceAll(',', '.')) ?? 0.0,
      );

      if (widget.propriedadeExistente != null) {
        await BancoDadosServico.instancia.updatePropriedade(novaFazenda);
        if (!mounted) return;
        final provedor = context.read<ProvedorFazenda>();
        if (provedor.propriedadeAtiva?.id == novaFazenda.id) {
          await provedor.selecionarFazenda(novaFazenda.id);
        } else {
          await provedor.carregarPropriedades();
        }
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Dados atualizados!'),
            backgroundColor: Colors.green));
      } else {
        await context.read<ProvedorFazenda>().adicionarPropriedade(novaFazenda);
        await PreferenciasUsuario().salvarUltimaFazenda(novaFazenda.id);
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const TelaDashboard()),
          (route) => false,
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

  InputDecoration _inputDecor(String label, IconData icon, {String? suffix}) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixText: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdicao = widget.propriedadeExistente != null;
    final Color corAppBarBg =
        _isCollapsed ? theme.colorScheme.primary : theme.colorScheme.surface;
    final Color corElementos =
        _isCollapsed ? theme.colorScheme.onPrimary : theme.colorScheme.primary;
    final EdgeInsets paddingTitulo = _isCollapsed
        ? const EdgeInsets.only(left: 72, bottom: 16)
        : const EdgeInsets.only(left: 16, bottom: 16);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
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
                    fontFamily: 'Roboto',
                  ),
                  child: Text(isEdicao ? 'Editar Dados' : 'Dados da Fazenda'),
                ),
                background: Container(
                  color: theme.colorScheme.surface,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (!isEdicao) ...[
                    const Text(
                      'Preencha as informações para configurar seu ambiente.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                  ],
                  TextFormField(
                    controller: _nomeFazendaController,
                    decoration:
                        _inputDecor('Nome da Fazenda', IconesApp.fazenda),
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _proprietarioController,
                    decoration: _inputDecor(
                        'Nome do Proprietário', IconesApp.proprietario),
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 3, // AUMENTADO PARA DAR ESPAÇO À CIDADE
                        child: TextFormField(
                          controller: _cidadeController,
                          decoration:
                              _inputDecor('Cidade', IconesApp.localizacao),
                          validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2, // AUMENTADO PARA O DROPDOWN CABER
                        child: DropdownButtonFormField<String>(
                          value: _estadoSelecionado,
                          decoration: _inputDecor('UF', Icons.map),
                          isExpanded: true, // Garante que o texto não estoure
                          items: _estados
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _estadoSelecionado = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _areaController,
                    decoration: _inputDecor('Área Total', Icons.aspect_ratio,
                        suffix: 'ha'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v!.isEmpty) return 'Obrigatório';
                      if (double.tryParse(v.replaceAll(',', '.')) == null)
                        return 'Inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _sistemaProducao,
                    decoration: _inputDecor(
                        'Sistema de Produção', Icons.settings_input_component),
                    items: _sistemas
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _sistemaProducao = v!),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 56,
                    child: FilledButton(
                      onPressed: _salvando ? null : _salvar,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _salvando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(IconesApp.salvar),
                                const SizedBox(width: 8),
                                Text(isEdicao
                                    ? 'SALVAR ALTERAÇÕES'
                                    : 'SALVAR E ENTRAR'),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 300),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
