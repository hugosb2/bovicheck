class CalculadoraIndicesProdutivos {
  double intervaloEntrePartos(DateTime dataPartoAnterior, DateTime dataPartoAtual) {
    if (dataPartoAtual.isBefore(dataPartoAnterior)) {
      throw ArgumentError('A data do parto atual não pode ser anterior à data do parto anterior.');
    }
    return dataPartoAtual.difference(dataPartoAnterior).inDays.toDouble();
  }

  double taxaDePrenhez({required int numFemeasPrenhes, required int totalFemeasAptas}) {
    if (totalFemeasAptas == 0) return 0.0;
    return (numFemeasPrenhes / totalFemeasAptas) * 100;
  }

  double conversaoAlimentar({required double consumoMateriaSecaKg, required double ganhoPesoVivoKg}) {
    if (ganhoPesoVivoKg == 0) return 0.0;
    return consumoMateriaSecaKg / ganhoPesoVivoKg;
  }

  double rendimentoDeCarcaca({required double pesoVivoAntesAbateKg, required double pesoCarcacaKg}) {
    if (pesoVivoAntesAbateKg == 0) return 0.0;
    return (pesoCarcacaKg / pesoVivoAntesAbateKg) * 100;
  }

  double taxaDeNatalidade({required int numBezerrosNascidosVivos, required int totalFemeasAptasReproducao}) {
    if (totalFemeasAptasReproducao == 0) return 0.0;
    return (numBezerrosNascidosVivos / totalFemeasAptasReproducao) * 100;
  }

  double taxaDeDesmame({required int numBezerrosDesmamados, required int numBezerrosNascidosVivosPeriodo}) {
    if (numBezerrosNascidosVivosPeriodo == 0) return 0.0;
    return (numBezerrosDesmamados / numBezerrosNascidosVivosPeriodo) * 100;
  }

  double ganhoMedioDiario({required double pesoInicialKg, required double pesoFinalKg, required int numDias}) {
    if (numDias == 0) return 0.0;
    return (pesoFinalKg - pesoInicialKg) / numDias;
  }

  double pesoAoDesmameAjustadoP205({
    required double pesoAoNascerKg,
    required double pesoRealDesmamaKg,
    required int idadeRealDesmamaDias,
  }) {
    if (idadeRealDesmamaDias == 0) return 0.0;
    double ganhoDiario = (pesoRealDesmamaKg - pesoAoNascerKg) / idadeRealDesmamaDias;
    return (ganhoDiario * 205) + pesoAoNascerKg;
  }

  double taxaDeMortalidade({required int numAnimaisMortos, required int totalAnimaisInicioPeriodo}) {
    if (totalAnimaisInicioPeriodo == 0) return 0.0;
    return (numAnimaisMortos / totalAnimaisInicioPeriodo) * 100;
  }

  double lotacaoAnimal({
    required int numTotalAnimais,
    required double pesoVivoMedioAnimalKg,
    required double areaTotalPastagemHa,
  }) {
    if (areaTotalPastagemHa == 0) return 0.0;
    double totalPesoVivo = numTotalAnimais * pesoVivoMedioAnimalKg;
    double totalUA = totalPesoVivo / 450;
    return totalUA / areaTotalPastagemHa;
  }

  double producaoLeitePorVacaDia({required double producaoTotalLeiteDiaL, required int numVacasEmLactacao}) {
    if (numVacasEmLactacao == 0) return 0.0;
    return producaoTotalLeiteDiaL / numVacasEmLactacao;
  }

  double idadeAoPrimeiroParto({required DateTime dataNascimentoNovilha, required DateTime dataPrimeiroParto}) {
     if (dataPrimeiroParto.isBefore(dataNascimentoNovilha)) {
      throw ArgumentError('A data do primeiro parto não pode ser anterior à data de nascimento.');
    }
    int dias = dataPrimeiroParto.difference(dataNascimentoNovilha).inDays;
    return dias / 30.4375;
  }
}