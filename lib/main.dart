import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'provedores/provedor_fazenda.dart';

// --- IMPORTANTE: Importar a tela de Boas Vindas ---
import 'telas/1_boas_vindas/tela_boas_vindas.dart';

void main() {
  runApp(const BoviCheckApp());
}

class BoviCheckApp extends StatelessWidget {
  const BoviCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProvedorFazenda()),
      ],
      child: MaterialApp(
        title: 'BoviCheck',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('pt', 'BR')],

        // --- AQUI É O PULO DO GATO ---
        // Se estiver como TelaDecisao(), troque para TelaBoasVindas()
        home: const TelaBoasVindas(),
      ),
    );
  }
}
