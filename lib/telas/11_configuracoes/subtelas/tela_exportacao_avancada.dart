import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../estilos/tema.dart';
import '../../../modelos/propriedade.dart';
import '../../../modelos/lote.dart';
import '../../../modelos/animal.dart';
import '../../../servicos/banco_dados_servico.dart';

class TelaExportacaoAvancada extends StatefulWidget {
  const TelaExportacaoAvancada({super.key});

  @override
  State<TelaExportacaoAvancada> createState() => _TelaExportacaoAvancadaState();
}

class _TelaExportacaoAvancadaState extends State<TelaExportacaoAvancada> {
  bool _carregando = true;
  bool _tudoSelecionado = false;
  List<Propriedade> _fazendas = [];
  Map<String, List<Lote>> _lotesPorFazenda = {};
  Map<String, List<Animal>> _animaisPorLote = {};

  final Set<String> _fazendasSelecionadas = {};
  final Set<String> _lotesSelecionados = {};
  final Set<String> _animaisSelecionados = {};
  
  final Set<String> _camposAnimalSelecionados = {
    'brinco', 'nome', 'raca', 'sexo', 'categoria', 'dataNascimento', 'pesoAtualKg'
  };

  final Map<String, String> _todosCamposAnimal = {
    'brinco': 'Brinco',
    'nome': 'Nome',
    'raca': 'Raça',
    'sexo': 'Sexo',
    'categoria': 'Categoria',
    'dataNascimento': 'Data de Nascimento',
    'pesoAtualKg': 'Peso Atual',
    'dataObito': 'Data de Óbito',
    'isAtivo': 'Status Ativo',
  };

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final db = BancoDadosServico.instancia;
      final fazendas = await db.getPropriedades();
      
      for (var f in fazendas) {
        final lotes = await db.getLotesPorFazenda(f.id);
        _lotesPorFazenda[f.id] = lotes;
        
        for (var l in lotes) {
          final animais = await db.database.then((database) => database.query(
            'animais',
            where: 'loteId = ?',
            whereArgs: [l.id],
          ));
          _animaisPorLote[l.id] = animais.map((a) => Animal.fromMap(a)).toList();
        }
      }

      if (mounted) {
        setState(() {
          _fazendas = fazendas;
          _carregando = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
    }
  }

  void _selecionarTudo(bool? valor) {
    setState(() {
      _tudoSelecionado = valor ?? false;
      if (_tudoSelecionado) {
        for (var f in _fazendas) {
          _fazendasSelecionadas.add(f.id);
          final lotes = _lotesPorFazenda[f.id] ?? [];
          for (var l in lotes) {
            _lotesSelecionados.add(l.id);
            final animais = _animaisPorLote[l.id] ?? [];
            for (var a in animais) {
              _animaisSelecionados.add(a.id);
            }
          }
        }
      } else {
        _fazendasSelecionadas.clear();
        _lotesSelecionados.clear();
        _animaisSelecionados.clear();
      }
    });
  }

  void _alternarFazenda(String id) {
    setState(() {
      if (_fazendasSelecionadas.contains(id)) {
        _fazendasSelecionadas.remove(id);
        final lotes = _lotesPorFazenda[id] ?? [];
        for (var l in lotes) {
          _lotesSelecionados.remove(l.id);
          final animais = _animaisPorLote[l.id] ?? [];
          for (var a in animais) {
            _animaisSelecionados.remove(a.id);
          }
        }
        _tudoSelecionado = false;
      } else {
        _fazendasSelecionadas.add(id);
        final lotes = _lotesPorFazenda[id] ?? [];
        for (var l in lotes) {
          _lotesSelecionados.add(l.id);
          final animais = _animaisPorLote[l.id] ?? [];
          for (var a in animais) {
            _animaisSelecionados.add(a.id);
          }
        }
      }
    });
  }

  void _alternarLote(String fazendaId, String loteId) {
    setState(() {
      if (_lotesSelecionados.contains(loteId)) {
        _lotesSelecionados.remove(loteId);
        final animais = _animaisPorLote[loteId] ?? [];
        for (var a in animais) {
          _animaisSelecionados.remove(a.id);
        }
        _tudoSelecionado = false;
      } else {
        _lotesSelecionados.add(loteId);
        _fazendasSelecionadas.add(fazendaId);
        final animais = _animaisPorLote[loteId] ?? [];
        for (var a in animais) {
          _animaisSelecionados.add(a.id);
        }
      }
    });
  }

  void _alternarAnimal(String fazendaId, String loteId, String animalId) {
    setState(() {
      if (_animaisSelecionados.contains(animalId)) {
        _animaisSelecionados.remove(animalId);
        _tudoSelecionado = false;
      } else {
        _animaisSelecionados.add(animalId);
        _lotesSelecionados.add(loteId);
        _fazendasSelecionadas.add(fazendaId);
      }
    });
  }

  Future<void> _exportar() async {
    if (_fazendasSelecionadas.isEmpty && _lotesSelecionados.isEmpty && _animaisSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione ao menos um item para exportar.')),
      );
      return;
    }

    try {
      final jsonStr = await BancoDadosServico.instancia.exportarDadosGranular(
        fazendaIds: _fazendasSelecionadas.toList(),
        loteIds: _lotesSelecionados.toList(),
        animalIds: _animaisSelecionados.toList(),
        camposAnimal: _camposAnimalSelecionados,
      );

      final bytes = utf8.encode(jsonStr);
      final dataStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final nomeArquivo = _tudoSelecionado 
          ? 'BoviCheck_Backup_Total_$dataStr.bvk'
          : 'BoviCheck_Exportacao_Parcial_$dataStr.bvk';

      final outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Salvar Exportação/Backup',
        fileName: nomeArquivo,
        bytes: Uint8List.fromList(bytes),
      );

      if (outputFile != null) {
        final file = File(outputFile);
        if (!(await file.exists()) || (await file.length()) == 0) {
          await file.writeAsBytes(bytes);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Arquivo gerado com sucesso!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const AppBarPadrao(titulo: 'Exportar Dados (Backup)'),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildHeaderTudo(),
                      const Divider(height: 32),
                      _secaoTitulo('1. Selecione Fazendas, Lotes ou Animais'),
                      ..._fazendas.map((f) => _buildFazendaTile(f)),
                      
                      const SizedBox(height: 32),
                      _secaoTitulo('2. Dados dos Animais a incluir'),
                      _buildCamposPicker(),
                    ],
                  ),
                ),
                _buildBotaoExportar(),
              ],
            ),
    );
  }

  Widget _buildHeaderTudo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _tudoSelecionado 
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _tudoSelecionado 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.outlineVariant
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _tudoSelecionado,
            onChanged: _selecionarTudo,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Backup Completo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Selecionar todos os dados do sistema',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(
            Icons.backup_outlined, 
            color: _tudoSelecionado ? Theme.of(context).colorScheme.primary : null
          ),
        ],
      ),
    );
  }

  Widget _secaoTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        titulo,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFazendaTile(Propriedade f) {
    final lotes = _lotesPorFazenda[f.id] ?? [];
    final selecionada = _fazendasSelecionadas.contains(f.id);

    return ExpansionTile(
      leading: Checkbox(
        value: selecionada,
        onChanged: (_) => _alternarFazenda(f.id),
      ),
      title: Text(f.nomeFazenda, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${lotes.length} lotes'),
      children: lotes.map((l) => _buildLoteTile(f.id, l)).toList(),
    );
  }

  Widget _buildLoteTile(String fazendaId, Lote l) {
    final animais = _animaisPorLote[l.id] ?? [];
    final selecionado = _lotesSelecionados.contains(l.id);

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: ExpansionTile(
        leading: Checkbox(
          value: selecionado,
          onChanged: (_) => _alternarLote(fazendaId, l.id),
        ),
        title: Text(l.nome),
        subtitle: Text('${animais.length} animais'),
        children: animais.map((a) => _buildAnimalTile(fazendaId, l.id, a)).toList(),
      ),
    );
  }

  Widget _buildAnimalTile(String fazendaId, String loteId, Animal a) {
    final selecionado = _animaisSelecionados.contains(a.id);

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 48, right: 16),
      leading: Checkbox(
        value: selecionado,
        onChanged: (_) => _alternarAnimal(fazendaId, loteId, a.id),
      ),
      title: Text('Brinco: ${a.brinco}'),
      subtitle: Text(a.raca),
    );
  }

  Widget _buildCamposPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _todosCamposAnimal.entries.map((entry) {
        final selecionado = _camposAnimalSelecionados.contains(entry.key);
        return FilterChip(
          label: Text(entry.value),
          selected: selecionado,
          onSelected: (bool value) {
            setState(() {
              if (value) {
                _camposAnimalSelecionados.add(entry.key);
              } else {
                if (entry.key != 'brinco') { // Brinco é obrigatório
                  _camposAnimalSelecionados.remove(entry.key);
                }
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildBotaoExportar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: _exportar,
            icon: const Icon(Icons.download_rounded),
            label: Text(_tudoSelecionado ? 'GERAR BACKUP COMPLETO' : 'EXPORTAR SELEÇÃO'),
          ),
        ),
      ),
    );
  }
}
