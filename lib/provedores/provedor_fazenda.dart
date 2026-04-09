import 'package:flutter/material.dart';
import '../modelos/propriedade.dart';
import '../modelos/lote.dart';
import '../modelos/animal.dart';
import '../modelos/eventos/evento_reprodutivo.dart';
import '../modelos/eventos/evento_sanitario.dart';
import '../modelos/eventos/pesagem.dart';
import '../modelos/eventos/producao_leite.dart';
import '../servicos/banco_dados_servico.dart';

class ProvedorFazenda extends ChangeNotifier {
  Propriedade? _propriedadeAtiva;
  List<Propriedade> _propriedades = [];
  List<Lote> _lotes = [];
  List<Animal> _animais = [];
  List<EventoReprodutivo> _eventosReprodutivos = [];
  List<EventoSanitario> _eventosSanitarios = [];
  List<Pesagem> _pesagens = [];
  List<ProducaoLeite> _producaoLeite = [];
  bool _isLoading = false;

  // Getters Básicos
  Propriedade? get propriedadeAtiva => _propriedadeAtiva;
  List<Propriedade> get propriedades => _propriedades;
  List<Lote> get lotes => _lotes;
  List<Animal> get animais => _animais;
  bool get isLoading => _isLoading;

  // Getters Calculados (Necessários para Dashboard e IA)
  int get totalAnimais => _animais.length;
  int get totalLotes => _lotes.length;

  int get totalAnimaisDoentes {
    final agora = DateTime.now();
    final inicioSemana = agora.subtract(const Duration(days: 7));
    return _animais.where((a) {
      return a.isAtivo &&
          _eventosSanitarios.any(
            (e) =>
                e.animalId == a.id &&
                (e.tipo.toLowerCase().contains('doença') || e.tipo.toLowerCase().contains('tratamento')) &&
                e.data.isAfter(inicioSemana),
          );
    }).length;
  }

  int get totalNascimentos {
    final agora = DateTime.now();
    final inicioAno = DateTime(agora.year, 1, 1);
    return _eventosReprodutivos
        .where((e) => e.tipo == 'Parto' && e.data.isAfter(inicioAno))
        .length;
  }

  double get totalLeiteMes {
    final agora = DateTime.now();
    final inicioMes = DateTime(agora.year, agora.month, 1);
    return _producaoLeite
        .where((e) => e.data.isAfter(inicioMes))
        .fold(0.0, (sum, item) => sum + item.litros);
  }

  double get taxaMortalidade {
    if (_animais.isEmpty) return 0.0;
    final obitos = _animais.where((a) => !a.isAtivo && a.dataObito != null).length;
    return (obitos / _animais.length) * 100;
  }

  double get mediaGMD {
    if (_pesagens.isEmpty) return 0.0;
    
    // Simplificado: média de todos os ganhos registrados
    Map<String, List<Pesagem>> pesagensPorAnimal = {};
    for (var p in _pesagens) {
      if (!pesagensPorAnimal.containsKey(p.animalId)) {
        pesagensPorAnimal[p.animalId] = [];
      }
      pesagensPorAnimal[p.animalId]!.add(p);
    }

    List<double> gmds = [];
    pesagensPorAnimal.forEach((id, lista) {
      if (lista.length >= 2) {
        lista.sort((a, b) => a.data.compareTo(b.data));
        final primeira = lista.first;
        final ultima = lista.last;
        final dias = ultima.data.difference(primeira.data).inDays;
        final ganho = ultima.pesoKg - primeira.pesoKg;
        if (dias > 0 && ganho > 0) {
          gmds.add(ganho / dias);
        }
      }
    });

    if (gmds.isEmpty) return 0.0;
    return gmds.reduce((a, b) => a + b) / gmds.length;
  }

  // Carregamento Inicial
  Future<void> carregarPropriedades() async {
    _isLoading = true;
    notifyListeners();
    try {
      _propriedades = await BancoDadosServico.instancia.getPropriedades();

      // Atualiza a propriedade ativa se necessário
      if (_propriedadeAtiva != null) {
        try {
          _propriedadeAtiva = _propriedades.firstWhere(
            (p) => p.id == _propriedadeAtiva!.id,
          );
        } catch (_) {
          _propriedadeAtiva = null; // Foi deletada
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar propriedades: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Seleção de Fazenda
  Future<void> selecionarFazenda(dynamic fazendaOrId) async {
    _isLoading = true;
    notifyListeners();

    if (fazendaOrId is Propriedade) {
      _propriedadeAtiva = fazendaOrId;
    } else if (fazendaOrId is String) {
      if (_propriedades.isEmpty) await carregarPropriedades();
      try {
        _propriedadeAtiva = _propriedades.firstWhere(
          (p) => p.id == fazendaOrId,
        );
      } catch (_) {
        _propriedadeAtiva = null;
      }
    }

    if (_propriedadeAtiva != null) {
      await carregarLotes(_propriedadeAtiva!.id);
      await carregarAnimais(_propriedadeAtiva!.id);
    } else {
      _lotes = [];
      _animais = [];
      _eventosReprodutivos = [];
      _eventosSanitarios = [];
      _pesagens = [];
      _producaoLeite = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- CRUD PROPRIEDADE ---
  Future<void> adicionarPropriedade(Propriedade p) async {
    await BancoDadosServico.instancia.adicionarPropriedade(p);
    await carregarPropriedades();
    await selecionarFazenda(p);
  }

  // --- CRUD LOTES ---
  Future<void> carregarLotes(String fazendaId) async {
    _lotes = await BancoDadosServico.instancia.getLotesPorFazenda(fazendaId);
    notifyListeners();
  }

  Future<void> adicionarLote(Lote lote) async {
    await BancoDadosServico.instancia.adicionarLote(lote);
    if (_propriedadeAtiva != null) {
      await carregarLotes(_propriedadeAtiva!.id);
    }
  }

  // --- CRUD ANIMAIS ---
  Future<void> carregarAnimais(String fazendaId) async {
    final db = BancoDadosServico.instancia;
    _animais = await db.getAnimaisPorFazenda(fazendaId);

    // Carrega todos os eventos para cálculo de indicadores no dashboard
    _eventosReprodutivos = [];
    _eventosSanitarios = [];
    _pesagens = [];
    _producaoLeite = [];

    for (var animal in _animais) {
      _eventosReprodutivos.addAll(
        await db.getEventosReprodutivosPorAnimal(animal.id),
      );
      
      final sanitariosMaps = await db.getEventosSanitariosPorAnimal(animal.id);
      _eventosSanitarios.addAll(
        sanitariosMaps.map((m) => EventoSanitario.fromMap(m)).toList(),
      );

      _pesagens.addAll(
        await db.getPesagensPorAnimal(animal.id),
      );

      _producaoLeite.addAll(
        await db.getProducaoLeitePorAnimal(animal.id),
      );
    }

    notifyListeners();
  }

  // Limpeza (Logout)
  void limparEstado() {
    _propriedadeAtiva = null;
    _lotes = [];
    _animais = [];
    _eventosReprodutivos = [];
    _eventosSanitarios = [];
    _pesagens = [];
    _producaoLeite = [];
    notifyListeners();
  }
}
