import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class ServicoAutenticacao {
  static final ServicoAutenticacao _instancia = ServicoAutenticacao._internal();
  factory ServicoAutenticacao() => _instancia;
  ServicoAutenticacao._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> verificarDisponibilidade() async {
    try {
      final estaHabilitado = await _localAuth.isDeviceSupported();
      if (!estaHabilitado) return false;
      
      final biometrias = await _localAuth.getAvailableBiometrics();
      return biometrias.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  Future<List<BiometricType>> obterBiometriasDisponiveis() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  Future<bool> autenticar({String razao = 'Autentique-se para continuar'}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: razao,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  Future<bool> autenticarApenasBiometria({String razao = 'Use biometria para autenticar'}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: razao,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
