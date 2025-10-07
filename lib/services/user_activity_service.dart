import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserActivityService {
  static final UserActivityService instance = UserActivityService._init();
  UserActivityService._init();

  // Chaves para persistência de dados
  static const _countsKey = 'user_action_counts';
  static const _lastKey = 'last_used_action'; // NOVO

  // Registra que uma ação foi executada
  Future<void> logAction(String actionId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // MODIFICADO: Salva a ação atual como a última utilizada
    await prefs.setString(_lastKey, actionId);

    // Lógica de contagem de frequência (permanece a mesma)
    final jsonString = prefs.getString(_countsKey) ?? '{}';
    final Map<String, dynamic> counts = jsonDecode(jsonString);
    counts[actionId] = (counts[actionId] ?? 0) + 1;
    await prefs.setString(_countsKey, jsonEncode(counts));
  }

  // Busca as ações mais utilizadas, com a última ação em primeiro
  Future<List<String>> getMostUsedActions({int count = 4}) async {
    final prefs = await SharedPreferences.getInstance();
    
    // --- LÓGICA COMPLETAMENTE REESCRITA ---

    // 1. Busca a última ação utilizada
    final String? lastUsedAction = prefs.getString(_lastKey);

    // 2. Busca o mapa de contagem de frequência
    final jsonString = prefs.getString(_countsKey) ?? '{}';
    final Map<String, dynamic> counts = jsonDecode(jsonString);

    if (counts.isEmpty) {
      return [];
    }
    
    // 3. Ordena todas as ações por frequência
    var sortedByFrequency = counts.entries.toList();
    sortedByFrequency.sort((a, b) => (b.value as int).compareTo(a.value as int));

    // 4. Monta a lista final
    final List<String> finalActions = [];

    // Adiciona a última ação primeiro, se ela existir
    if (lastUsedAction != null && counts.containsKey(lastUsedAction)) {
      finalActions.add(lastUsedAction);
    }

    // Preenche o resto da lista com as mais frequentes, evitando duplicatas
    for (var entry in sortedByFrequency) {
      if (finalActions.length >= count) {
        break; // Para quando a lista atingir o tamanho desejado
      }
      if (!finalActions.contains(entry.key)) {
        finalActions.add(entry.key);
      }
    }
    
    return finalActions;
  }
}