import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../estilos/tema.dart';
import '../../../servicos/configuracao.dart';
import '../../../servicos/ia_groq_cliente.dart';

/// Configuração do Consultor IA: chave da Groq e modelo.
class TelaConfigIA extends StatefulWidget {
  const TelaConfigIA({super.key});

  @override
  State<TelaConfigIA> createState() => _TelaConfigIAState();
}

class _TelaConfigIAState extends State<TelaConfigIA> {
  final TextEditingController _chaveController = TextEditingController();

  bool _mostrarChave = false;
  bool _salvando = false;
  bool _testando = false;
  String? _resultadoTeste;
  bool _testeOk = false;
  late String _modelo;

  @override
  void initState() {
    super.initState();
    _modelo = Configuracao.modeloGroq;
  }

  @override
  void dispose() {
    _chaveController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------ Ações

  Future<void> _salvar() async {
    final chave = _chaveController.text.trim();
    if (chave.isEmpty) {
      _avisar('Digite uma chave antes de salvar.', erro: true);
      return;
    }
    if (chave.contains(' ')) {
      _avisar('A chave não pode conter espaços.', erro: true);
      return;
    }

    setState(() => _salvando = true);
    try {
      await Configuracao.salvarChaveGroq(chave);
      if (!mounted) return;
      setState(() {
        _chaveController.clear();
        _resultadoTeste = null;
      });
      _avisar('Chave da Groq salva neste dispositivo.');
    } catch (e) {
      if (!mounted) return;
      _avisar('Não foi possível salvar: $e', erro: true);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _remover() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover chave?'),
        content: const Text(
          'O Consultor IA voltará a usar apenas a análise local (RAG sem LLM).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    await Configuracao.removerChaveGroq();
    if (!mounted) return;
    setState(() => _resultadoTeste = null);
    _avisar('Chave removida.');
  }

  Future<void> _testar() async {
    final digitada = _chaveController.text.trim();
    final chave = digitada.isNotEmpty ? digitada : Configuracao.chaveGroq;

    if (chave.isEmpty) {
      setState(() {
        _testeOk = false;
        _resultadoTeste = 'Nenhuma chave para testar. Digite ou salve uma chave.';
      });
      return;
    }

    setState(() {
      _testando = true;
      _resultadoTeste = null;
    });

    try {
      final resposta = await IAGroqCliente.testarConexao(
        chave: chave,
        modelo: _modelo,
      );
      if (!mounted) return;
      setState(() {
        _testeOk = true;
        _resultadoTeste =
            'Conexão OK com ${Configuracao.modelosGroq[_modelo] ?? _modelo}.\n'
            'Resposta: ${resposta.length > 80 ? '${resposta.substring(0, 80)}...' : resposta}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _testeOk = false;
        _resultadoTeste = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _testando = false);
    }
  }

  Future<void> _alterarModelo(String? modelo) async {
    if (modelo == null) return;
    await Configuracao.salvarModeloGroq(modelo);
    if (!mounted) return;
    setState(() {
      _modelo = modelo;
      _resultadoTeste = null;
    });
  }

  Future<void> _abrirConsoleGroq() async {
    final uri = Uri.parse('https://console.groq.com/keys');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) _avisar('Não foi possível abrir o navegador.', erro: true);
    } catch (_) {
      if (mounted) _avisar('Não foi possível abrir o navegador.', erro: true);
    }
  }

  void _avisar(String texto, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: erro ? Colors.red.shade700 : null,
      ),
    );
  }

  // ------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final configurada = Configuracao.temChaveGroq;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const AppBarPadrao(titulo: 'Consultor IA'),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _statusCard(theme, configurada),

          const SizedBox(height: 28),
          const _SecaoTitulo(texto: 'Chave de API da Groq'),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _chaveController,
                    obscureText: !_mostrarChave,
                    autocorrect: false,
                    enableSuggestions: false,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _salvar(),
                    style: const TextStyle(fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      labelText: 'GROQ_API_KEY',
                      hintText: configurada
                          ? Configuracao.chaveGroqMascarada
                          : 'gsk_...',
                      helperText: 'Chaves da Groq começam com gsk_',
                      helperMaxLines: 2,
                      prefixIcon: const Icon(Icons.vpn_key_outlined),
                      suffixIcon: IconButton(
                        tooltip: _mostrarChave ? 'Ocultar' : 'Mostrar',
                        icon: Icon(
                          _mostrarChave
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _mostrarChave = !_mostrarChave),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _salvando ? null : _salvar,
                          icon: _salvando
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.check),
                          label: const Text('Salvar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _testando ? null : _testar,
                          icon: _testando
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.wifi_tethering),
                          label: const Text('Testar'),
                        ),
                      ),
                    ],
                  ),
                  if (configurada) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _remover,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Remover chave'),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                  if (_resultadoTeste != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: (_testeOk ? Colors.green : Colors.red)
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (_testeOk ? Colors.green : Colors.red)
                              .withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _testeOk
                                ? Icons.check_circle_outline
                                : Icons.error_outline,
                            size: 20,
                            color: _testeOk
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _resultadoTeste!,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),

          const SizedBox(height: 28),
          const _SecaoTitulo(texto: 'Modelo'),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: RadioGroup<String>(
              groupValue: _modelo,
              onChanged: _alterarModelo,
              child: Column(
                children: [
                  for (final entry in Configuracao.modelosGroq.entries) ...[
                    RadioListTile<String>(
                      title: Text(entry.value),
                      subtitle: Text(
                        entry.key,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontFamily: 'monospace',
                        ),
                      ),
                      value: entry.key,
                    ),
                    if (entry.key != Configuracao.modelosGroq.keys.last)
                      const Divider(height: 1),
                  ],
                ],
              ),
            ),
          ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05),

          const SizedBox(height: 28),
          const _SecaoTitulo(texto: 'Como obter a chave'),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1. Acesse console.groq.com e crie uma conta gratuita.\n'
                    '2. Em "API Keys", gere uma nova chave (gsk_...).\n'
                    '3. Cole no campo acima e toque em Salvar.\n'
                    '4. Use "Testar" para confirmar que a chave responde.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _abrirConsoleGroq,
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Abrir console da Groq'),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),

          const SizedBox(height: 28),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'A chave fica salva apenas neste dispositivo e não é '
                      'enviada para nenhum servidor do BoviCheck. Ao gerar a '
                      'análise, somente os indicadores do rebanho são '
                      'enviados à Groq.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 250.ms),

          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _statusCard(ThemeData theme, bool configurada) {
    final cor = configurada ? Colors.green : theme.colorScheme.outline;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              configurada ? Icons.check_circle_outline : Icons.smart_toy_outlined,
              color: configurada ? Colors.green.shade700 : cor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  configurada ? 'IA generativa ativa' : 'IA generativa desativada',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  configurada
                      ? 'Chave ${Configuracao.chaveGroqMascarada}'
                          '${Configuracao.chaveVeioDoEnv ? ' (do .env)' : ' (neste dispositivo)'}'
                      : 'O consultor está usando apenas a análise local com RAG.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.05);
  }
}

class _SecaoTitulo extends StatelessWidget {
  final String texto;
  const _SecaoTitulo({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
