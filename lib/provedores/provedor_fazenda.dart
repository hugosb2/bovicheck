import 'package:flutter/material.dart';
import '../modelos/propriedade.dart';
import '../modelos/lote.dart';
import '../modelos/animal.dart';
import '../servicos/banco_dados_servico.dart';

class ProvedorFazenda extends ChangeNotifier {
  Propriedade? _propriedadeAtiva;
  List<Propriedade> _propriedades = [];
  List<Lote> _lotes = [];
  List<Animal> _animais = [];
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
  // Retornando 0 para 'doentes' para evitar erro se o campo não existir
  int get totalAnimaisDoentes => 0;

  // Carregamento Inicial
  Future<void> carregarPropriedades() async {
    _isLoading = true;
    notifyListeners();
    try {
      _propriedades = await BancoDadosServico.instancia.getPropriedades();

      // Atualiza a propriedade ativa se necessário
      if (_propriedadeAtiva != null) {
        try {
          _propriedadeAtiva =
              _propriedades.firstWhere((p) => p.id == _propriedadeAtiva!.id);
        } catch (_) {
          _propriedadeAtiva = null; // Foi deletada
        }
      }
    } catch (e) {
      print("Erro ao carregar propriedades: $e");
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
        _propriedadeAtiva =
            _propriedades.firstWhere((p) => p.id == fazendaOrId);
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
    _animais =
        await BancoDadosServico.instancia.getAnimaisPorFazenda(fazendaId);
    notifyListeners();
  }

  // Limpeza (Logout)
  void limparEstado() {
    _propriedadeAtiva = null;
    _lotes = [];
    _animais = [];
    notifyListeners();
  }
}
