import 'package:flutter/material.dart'; // CORRIGIDO: O erro de digitação estava aqui
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionFooter extends StatefulWidget {
  const AppVersionFooter({super.key});

  @override
  State<AppVersionFooter> createState() => _AppVersionFooterState();
}

class _AppVersionFooterState extends State<AppVersionFooter> {
  String _buildSignature = '';

  @override
  void initState() {
    super.initState();
    _initBuildSignature();
  }

  Future<void> _initBuildSignature() async {
    final info = await PackageInfo.fromPlatform();
    // A data atual é formatada para o padrão yyyyMMdd
    final formattedDate = DateFormat('yyyyMMdd').format(DateTime.now());

    if (mounted) {
      setState(() {
        _buildSignature = 'v${info.version}_$formattedDate';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // O widget só exibe o texto depois que a informação for carregada
    return _buildSignature.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              _buildSignature,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          );
  }
}