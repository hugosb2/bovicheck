import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../estilos/cores.dart';
import '../../../estilos/icones.dart';
import '../../5_ia_consultor/tela_ia_consultor.dart';

class CardIA extends StatelessWidget {
  const CardIA({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Em uma implementação real, isso viria de um Provider ou Service
    // baseada na última análise salva no banco.
    final bool temAlerta = true;
    final String resumo = temAlerta
        ? "Atenção: Queda no Ganho Médio Diário (GMD) detectada no lote de Engorda."
        : "O rebanho está estável. Nenhuma anomalia detectada hoje.";

    return Card(
      elevation: 2,
      color: temAlerta ? CoresApp.containerAtencao : CoresApp.containerSucesso,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: temAlerta
              ? CoresApp.atencao.withOpacity(0.5)
              : CoresApp.sucesso.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TelaIAConsultor()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: temAlerta ? CoresApp.atencao : CoresApp.sucesso,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconesApp.iaConsultor,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Insight IA",
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resumo,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                IconesApp.setaDireita,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }
}
