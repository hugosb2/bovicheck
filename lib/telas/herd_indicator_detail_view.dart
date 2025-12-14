import 'package:bovicheck/modelos/herd_indicator.dart';
import 'package:bovicheck/servicos/database_service.dart';
import 'package:bovicheck/servicos/herd_analysis_service.dart';
import 'package:bovicheck/componentes/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HerdIndicatorDetailView extends StatefulWidget {
  final String indicatorId;
  const HerdIndicatorDetailView({super.key, required this.indicatorId});

  @override
  State<HerdIndicatorDetailView> createState() =>
      _HerdIndicatorDetailViewState();
}

class _HerdIndicatorDetailViewState extends State<HerdIndicatorDetailView> {
  HerdIndicator? _indicator;
  bool _isLoading = true;
  double? _calculatedValue;
  String? _errorMessage;
  Map<String, String> _requirements = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final indicator =
        await DatabaseService.instance.getHerdIndicatorById(widget.indicatorId);
    if (indicator != null) {
      setState(() {
        _indicator = indicator;
      });
      await _calculateIndicator();
      _loadRequirements();
    } else {
      setState(() {
        _errorMessage = 'Índice não encontrado';
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _calculateIndicator() async {
    final allAnimals = await DatabaseService.instance.getAllAnimals();
    final analysisService = HerdAnalysisService(allAnimals);
    final period = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 365)),
      end: DateTime.now(),
    );
    final results = analysisService.analyze(period);
    setState(() {
      _calculatedValue = results[_indicator!.indicatorKey];
    });
  }

  void _loadRequirements() {
    if (_indicator == null) return;

    switch (_indicator!.indicatorKey) {
      case 'birthRate':
        _requirements = {
          'title': 'Taxa de Natalidade',
          'requirement':
              'Fêmeas aptas (> 15 meses de idade) e registros de Parto no período analisado.',
          'dataSource':
              'Dados dos animais: sexo, data de nascimento, status e eventos reprodutivos (Parto).',
        };
        break;
      case 'averageCalvingInterval':
        _requirements = {
          'title': 'Intervalo Partos',
          'requirement':
              'Animais fêmeas com pelo menos 2 registros de Parto no histórico.',
          'dataSource':
              'Dados dos animais: eventos reprodutivos (Parto) registrados na tela de animais.',
        };
        break;
      case 'averageAgeAtFirstCalving':
        _requirements = {
          'title': 'Idade 1º Parto',
          'requirement':
              'Fêmeas com pelo menos 1 registro de Parto no histórico reprodutivo.',
          'dataSource':
              'Dados dos animais: data de nascimento e eventos reprodutivos (Parto) registrados na tela de animais.',
        };
        break;
      case 'mortalityRate':
        _requirements = {
          'title': 'Taxa de Mortalidade',
          'requirement':
              'Animais que existiam no início do período e registros de Morte no período analisado.',
          'dataSource':
              'Dados dos animais: data de nascimento, status (Morte) e data de saída registrados na tela de animais.',
        };
        break;
      case 'averageAdgBirthToWeaning':
        _requirements = {
          'title': 'GMD Nasc.-Desmame',
          'requirement':
              'Animais com data de desmame e pesagens próximas ao nascimento e ao desmame.',
          'dataSource':
              'Dados dos animais: data de nascimento, data de desmame e registros de pesagem na tela de animais.',
        };
        break;
      case 'averageDailyMilkProduction':
        _requirements = {
          'title': 'Média de Leite',
          'requirement':
              'Registros de Parto (para iniciar a lactação) e registros de produção de leite.',
          'dataSource':
              'Dados dos animais: eventos reprodutivos (Parto) e registros de produção de leite na tela de animais.',
        };
        break;
      default:
        _requirements = {
          'title': _indicator!.indicatorTitle,
          'requirement': 'Dados insuficientes para calcular este índice.',
          'dataSource': 'Dados dos animais registrados na tela de animais.',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Carregando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_indicator == null || _errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: Center(child: Text(_errorMessage ?? 'Índice não encontrado')),
      );
    }

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_indicator!.indicatorTitle),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _buildInfoCard(context),
                  const SizedBox(height: 16),
                  _buildValueCard(context),
                  const SizedBox(height: 16),
                  _buildApplicationCard(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.bar_chart,
                        color: theme.colorScheme.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Informações do Índice',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoTile(context,
                      title: 'Nome', value: _indicator!.indicatorTitle),
                  _buildInfoTile(context,
                      title: 'Unidade', value: _indicator!.indicatorUnit),
                  _buildInfoTile(context,
                      title: 'Data de Criação',
                      value: DateFormat('dd/MM/yyyy HH:mm')
                          .format(_indicator!.createdAt)),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildValueCard(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = _calculatedValue != null;

    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: hasValue
                          ? theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.3)
                          : theme.colorScheme.errorContainer
                              .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                        hasValue ? Icons.check_circle : Icons.info_outline,
                        color: hasValue
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                        size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Valor Calculado',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: hasValue
                  ? Center(
                      child: Column(
                        children: [
                          Text(
                            '${_calculatedValue!.toStringAsFixed(_indicator!.indicatorUnit == '%' ? 0 : 1)}${_indicator!.indicatorUnit}',
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      color: theme.colorScheme.error),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Dados Insuficientes',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'O que é necessário:',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _requirements['requirement'] ?? '',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'De onde vem o dado:',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _requirements['dataSource'] ?? '',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 200.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildApplicationCard(BuildContext context) {
    final theme = Theme.of(context);
    final applications = <String>[];
    if (_indicator!.applyToLote) applications.add('Lote');
    if (_indicator!.applyToProperty) applications.add('Propriedade');

    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.location_on,
                        color: theme.colorScheme.secondary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Onde é Aplicado',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: applications.isEmpty
                  ? Text(
                      'Nenhuma aplicação definida',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: applications.map((app) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: theme.colorScheme.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                app,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 400.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildInfoTile(BuildContext context,
      {required String title, required String value}) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Text(
        value,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
