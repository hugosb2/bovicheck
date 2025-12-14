import 'package:bovicheck/controladores/animal_list_controller.dart';
import 'package:bovicheck/controladores/dashboard_controller.dart';
import 'package:bovicheck/modelos/animal/animal.dart';
import 'package:bovicheck/modelos/lote.dart';
import 'package:bovicheck/servicos/database_service.dart';
import 'package:bovicheck/estilos/app_colors.dart';
import 'package:bovicheck/estilos/app_icons.dart';
import 'package:bovicheck/telas/animal/animal_detail_view.dart';
import 'package:bovicheck/telas/animal/animal_form_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimalListView extends StatefulWidget {
  const AnimalListView({super.key});
  @override
  State<AnimalListView> createState() => _AnimalListViewState();
}

class _AnimalListViewState extends State<AnimalListView> {
  String? _selectedLoteId;
  late Future<List<Lote>> _lotesFuture;

  @override
  void initState() {
    super.initState();
    _lotesFuture = DatabaseService.instance.getAllLotes();
  }

  // ATUALIZAÇÃO 3: Receba o controller como parâmetro
  Future<void> _refreshDataAfterNavigation(
      AnimalListController controller) async {
    // ATUALIZAÇÃO 4: Use o controller diretamente
    controller.fetchAnimals();
    Provider.of<DashboardController>(context, listen: false)
        .fetchDashboardData();
  }

  // ATUALIZAÇÃO 1: Receba o controller como parâmetro
  Future<void> _onFabPressed(AnimalListController controller) async {
    final lotes = await DatabaseService.instance.getAllLotes();
    final currentContext = context;
    if (!currentContext.mounted) return;

    if (lotes.isEmpty) {
      showDialog(
        context: currentContext,
        builder: (ctx) => AlertDialog(
          title: const Text('Nenhum Lote Encontrado'),
          content: const Text(
              'Você precisa cadastrar um Lote antes de poder adicionar um Animal.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(currentContext, '/lotes');
              },
              child: const Text('Cadastrar Lote'),
            ),
          ],
        ),
      );
    } else {
      await Navigator.push(currentContext,
          MaterialPageRoute(builder: (_) => const AnimalFormView()));

      // ATUALIZAÇÃO 2: Passe o controller adiante
      _refreshDataAfterNavigation(controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider(
      create: (_) => AnimalListController(),
      child: Consumer<AnimalListController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Meu Rebanho'),
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
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por brinco ou nome...',
                      prefixIcon: const Icon(AppIcons.search),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color:
                              theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) => controller.search(value),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: -0.1, end: 0),
                ),
                FutureBuilder<List<Lote>>(
                  future: _lotesFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(height: 50);
                    }
                    final lotes = snapshot.data ?? [];
                    if (lotes.isEmpty) return const SizedBox.shrink();

                    return SizedBox(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: lotes.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return ChoiceChip(
                              label: const Text('Todos'),
                              selected: _selectedLoteId == null,
                              onSelected: (selected) {
                                setState(() => _selectedLoteId = null);
                                controller.filterByLote(null);
                              },
                              showCheckmark: false,
                            );
                          }
                          final lote = lotes[index - 1];
                          return ChoiceChip(
                            label: Text(lote.nome),
                            selected: _selectedLoteId == lote.id,
                            onSelected: (selected) {
                              final newLoteId = selected ? lote.id : null;
                              setState(() => _selectedLoteId = newLoteId);
                              controller.filterByLote(newLoteId);
                            },
                            showCheckmark: false,
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : controller.filteredAnimals.isEmpty
                          ? Center(
                              child: Text(
                                'Nenhum animal encontrado.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.outline),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              itemCount: controller.filteredAnimals.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final animal =
                                    controller.filteredAnimals[index];
                                final age = DateTime.now()
                                    .difference(animal.dataNascimento)
                                    .inDays;
                                final ageString = (age / 365).floor() > 0
                                    ? '${(age / 365).floor()} a'
                                    : '${(age / 30).floor()} m';

                                return Card(
                                  elevation: 1,
                                  shadowColor:
                                      theme.colorScheme.shadow.withValues(alpha: 0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: theme.colorScheme.outlineVariant
                                          .withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () async {
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    AnimalDetailView(
                                                        animalId: animal.id)));

                                        _refreshDataAfterNavigation(controller);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    theme.colorScheme
                                                        .primaryContainer,
                                                    theme.colorScheme
                                                        .primaryContainer
                                                        .withValues(alpha: 0.7),
                                                  ],
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: theme
                                                        .colorScheme.primary
                                                        .withValues(alpha: 0.2),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                AppIcons.pet,
                                                size: 24,
                                                color: theme.colorScheme
                                                    .onPrimaryContainer,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Brinco: ${animal.brinco}',
                                                    style: theme
                                                        .textTheme.titleMedium
                                                        ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: theme.colorScheme
                                                          .onSurface,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${animal.nome ?? 'Sem nome'} • ${animal.sexo} • $ageString',
                                                    style: theme
                                                        .textTheme.bodyMedium
                                                        ?.copyWith(
                                                      color: theme.colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: animal.status ==
                                                        AnimalStatus.ativo
                                                    ? AppColors
                                                        .statusActiveContainer
                                                    : AppColors
                                                        .statusInactiveContainer,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: (animal.status ==
                                                                AnimalStatus
                                                                    .ativo
                                                            ? AppColors
                                                                .statusActive
                                                            : AppColors
                                                                .statusInactive)
                                                        .withValues(alpha: 0.2),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                animal.status.name
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                  color: animal.status ==
                                                          AnimalStatus.ativo
                                                      ? AppColors.statusActive
                                                      : AppColors
                                                          .statusInactive,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.chevron_right_rounded,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                    .animate()
                                    .fadeIn(
                                        duration: 300.ms,
                                        delay: (index * 50).ms)
                                    .slideX(begin: 0.1, end: 0);
                              },
                            ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _onFabPressed(controller),
              icon: const Icon(AppIcons.add),
              label: const Text('Novo Animal'),
              elevation: 4,
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .scale(begin: const Offset(0, 0), end: const Offset(1, 1)),
          );
        },
      ),
    );
  }
}
