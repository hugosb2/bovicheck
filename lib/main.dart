import 'package:bovicheck/telas/herd_indicators_view.dart';
import 'package:bovicheck/telas/lotes/lotes_management_view.dart';
import 'package:bovicheck/telas/propriedade/propriedade_management_view.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:bovicheck/controladores/dashboard_controller.dart';
import 'package:bovicheck/provedores/theme_provider.dart';
import 'package:bovicheck/servicos/database_service.dart';
import 'package:bovicheck/estilos/app_theme.dart';
import 'package:bovicheck/telas/about_view.dart';
import 'package:bovicheck/telas/animal/animal_list_view.dart';
import 'package:bovicheck/telas/dashboard_view.dart';
import 'package:bovicheck/telas/settings/backup_restore_view.dart';
import 'package:bovicheck/telas/settings/color_settings_view.dart';
import 'package:bovicheck/telas/settings/data_settings_view.dart';
import 'package:bovicheck/telas/settings/spreadsheet_export_view.dart';
import 'package:bovicheck/telas/settings/theme_settings_view.dart';
import 'package:bovicheck/telas/settings_view.dart';
import 'package:bovicheck/telas/splash_view.dart';
import 'package:bovicheck/telas/propriedade/propriedade_form_view.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await dotenv.load(fileName: ".env");

  final themeProvider = ThemeProvider();
  await themeProvider.loadPreferences();

  await DatabaseService.instance.initDB();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => DashboardController()),
      ],
      child: const MyApp(),
    ),
  );
}

class Aplicacao extends StatelessWidget {
  const Aplicacao({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            ThemeData lightTheme;
            ThemeData darkTheme;

            if (themeProvider.useDynamicColors &&
                lightDynamic != null &&
                darkDynamic != null) {
              lightTheme = AppTheme.buildLightTheme(lightDynamic.harmonized());
              darkTheme = AppTheme.buildDarkTheme(darkDynamic.harmonized());
            } else {
              lightTheme =
                  AppTheme.buildLightThemeFromSeed(themeProvider.selectedColor);
              darkTheme =
                  AppTheme.buildDarkThemeFromSeed(themeProvider.selectedColor);
            }

            return MaterialApp(
              title: 'BoviCheck',
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('pt', 'BR'),
              ],
              locale: const Locale('pt', 'BR'),
              theme: lightTheme, // ATUALIZADO
              darkTheme: darkTheme, // ATUALIZADO
              themeMode: themeProvider.themeMode,
              initialRoute: '/splash',
              routes: {
                '/splash': (context) => const SplashView(),
                '/': (context) => const DashboardView(),
                '/about': (context) => const AboutView(),
                '/settings': (context) => const SettingsView(),
                '/settings/theme': (context) => const ThemeSettingsView(),
                '/settings/colors': (context) => const ColorSettingsView(),
                '/settings/data': (context) => const DataSettingsView(),
                '/settings/backup': (context) => const BackupRestoreView(),
                '/settings/spreadsheet-export': (context) =>
                    const SpreadsheetExportView(),
                '/settings/propriedades': (context) =>
                    const PropriedadeManagementView(),
                '/propriedade/form': (context) => const PropriedadeFormView(),
                '/animals': (context) => const AnimalListView(),
                '/lotes': (context) => const LotesManagementView(),
                '/herd-indicators': (context) => const HerdIndicatorsView(),
              },
              debugShowCheckedModeBanner: false,
            );
          },
        );
      },
    );
  }
}

class MyApp extends Aplicacao {
  const MyApp({super.key}) : super();
}
