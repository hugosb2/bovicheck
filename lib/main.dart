import 'package:bovicheck/views/herd_indicators_view.dart';
import 'package:bovicheck/views/lotes/lotes_management_view.dart';
import 'package:bovicheck/views/propriedade/propriedade_management_view.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'controllers/dashboard_controller.dart';
import 'providers/theme_provider.dart';
import 'services/database_service.dart';
import 'views/about_view.dart';
import 'views/animal/animal_list_view.dart';
import 'views/dashboard_view.dart';
import 'views/settings/backup_restore_view.dart';
import 'views/settings/color_settings_view.dart';
import 'views/settings/data_settings_view.dart';
import 'views/settings/theme_settings_view.dart';
import 'views/settings_view.dart';
import 'views/splash_view.dart';
import 'package:bovicheck/views/propriedade/propriedade_form_view.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            ColorScheme lightColorScheme;
            ColorScheme darkColorScheme;

            if (themeProvider.useDynamicColors &&
                lightDynamic != null &&
                darkDynamic != null) {
              lightColorScheme = lightDynamic.harmonized();
              darkColorScheme = darkDynamic.harmonized();
            } else {
              lightColorScheme = ColorScheme.fromSeed(
                seedColor: themeProvider.selectedColor,
                brightness: Brightness.light,
              );
              darkColorScheme = ColorScheme.fromSeed(
                seedColor: themeProvider.selectedColor,
                brightness: Brightness.dark,
              );
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
              theme: ThemeData(
                colorScheme: lightColorScheme,
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorScheme: darkColorScheme,
                useMaterial3: true,
              ),
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
