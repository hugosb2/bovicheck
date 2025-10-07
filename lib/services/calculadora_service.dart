// Este arquivo contém APENAS a lógica de negócio (os cálculos).

class CalculadoraIndicesProdutivos {
  /// Calcula o Intervalo entre Partos em dias.
  /// [dataPartoAnterior]: Data do parto anterior.
  /// [dataPartoAtual]: Data do parto atual.
  double intervaloEntrePartos(DateTime dataPartoAnterior, DateTime dataPartoAtual) {
    if (dataPartoAtual.isBefore(dataPartoAnterior)) {
      throw ArgumentError('A data do parto atual não pode ser anterior à data do parto anterior.');
    }
    return dataPartoAtual.difference(dataPartoAnterior).inDays.toDouble();
  }

  /// Calcula a Taxa de Prenhez em porcentagem.
  /// [numFemeasPrenhes]: Número de fêmeas diagnosticadas prenhas.
  /// [totalFemeasAptas]: Número total de fêmeas aptas (expostas).
  double taxaDePrenhez({required int numFemeasPrenhes, required int totalFemeasAptas}) {
    if (totalFemeasAptas == 0) return 0.0;
    return (numFemeasPrenhes / totalFemeasAptas) * 100;
  }

  /// Calcula a Conversão Alimentar.
  /// [consumoMateriaSecaKg]: Consumo de matéria seca em kg.
  /// [ganhoPesoVivoKg]: Ganho de peso vivo em kg.
  double conversaoAlimentar({required double consumoMateriaSecaKg, required double ganhoPesoVivoKg}) {
    if (ganhoPesoVivoKg == 0) return 0.0;
    return consumoMateriaSecaKg / ganhoPesoVivoKg;
  }

  /// Calcula o Rendimento de Carcaça em porcentagem.
  /// [pesoVivoAntesAbateKg]: Peso vivo antes do abate em kg.
  /// [pesoCarcacaKg]: Peso da carcaça em kg.
  double rendimentoDeCarcaca({required double pesoVivoAntesAbateKg, required double pesoCarcacaKg}) {
    if (pesoVivoAntesAbateKg == 0) return 0.0;
    return (pesoCarcacaKg / pesoVivoAntesAbateKg) * 100;
  }

  /// Calcula a Taxa de Natalidade em porcentagem.
  /// [numBezerrosNascidosVivos]: Número de bezerros nascidos vivos.
  /// [totalFemeasAptasReproducao]: Número total de fêmeas aptas (expostas à reprodução).
  double taxaDeNatalidade({required int numBezerrosNascidosVivos, required int totalFemeasAptasReproducao}) {
    if (totalFemeasAptasReproducao == 0) return 0.0;
    return (numBezerrosNascidosVivos / totalFemeasAptasReproducao) * 100;
  }

  /// Calcula a Taxa de Desmame em porcentagem.
  /// [numBezerrosDesmamados]: Número de bezerros desmamados.
  /// [numBezerrosNascidosVivosPeriodo]: Número de bezerros nascidos vivos no período.
  double taxaDeDesmame({required int numBezerrosDesmamados, required int numBezerrosNascidosVivosPeriodo}) {
    if (numBezerrosNascidosVivosPeriodo == 0) return 0.0;
    return (numBezerrosDesmamados / numBezerrosNascidosVivosPeriodo) * 100;
  }

  /// Calcula o Ganho Médio Diário (GMD) em kg/dia.
  /// [pesoInicialKg]: Peso inicial em kg.
  /// [pesoFinalKg]: Peso final em kg.
  /// [numDias]: Número de dias entre as pesagens.
  double ganhoMedioDiario({required double pesoInicialKg, required double pesoFinalKg, required int numDias}) {
    if (numDias == 0) return 0.0;
    return (pesoFinalKg - pesoInicialKg) / numDias;
  }

  /// Calcula o Peso ao Desmame Ajustado para 205 dias (P205).
  /// [pesoAoNascerKg]: Peso ao nascer em kg.
  /// [pesoRealDesmamaKg]: Peso real à desmama em kg.
  /// [idadeRealDesmamaDias]: Idade real à desmama em dias.
  double pesoAoDesmameAjustadoP205({
    required double pesoAoNascerKg,
    required double pesoRealDesmamaKg,
    required int idadeRealDesmamaDias,
  }) {
    if (idadeRealDesmamaDias == 0) return 0.0;
    double ganhoDiario = (pesoRealDesmamaKg - pesoAoNascerKg) / idadeRealDesmamaDias;
    return (ganhoDiario * 205) + pesoAoNascerKg;
  }

  /// Calcula a Taxa de Mortalidade em porcentagem.
  /// [numAnimaisMortos]: Número de animais mortos.
  /// [totalAnimaisInicioPeriodo]: Número total de animais existentes no início do período/fase.
  double taxaDeMortalidade({required int numAnimaisMortos, required int totalAnimaisInicioPeriodo}) {
    if (totalAnimaisInicioPeriodo == 0) return 0.0;
    return (numAnimaisMortos / totalAnimaisInicioPeriodo) * 100;
  }

  /// Calcula a Lotação Animal em Unidade Animal (UA) por hectare.
  /// Considera 1 UA = 450 kg de peso vivo.
  /// [numTotalAnimais]: Número total de animais.
  /// [pesoVivoMedioAnimalKg]: Peso vivo médio por animal em kg.
  /// [areaTotalPastagemHa]: Área total de pastagem em hectares.
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

  /// Calcula a Produção de Leite por Vaca por Dia em litros.
  /// [producaoTotalLeiteDiaL]: Produção total de leite no dia em litros.
  /// [numVacasEmLactacao]: Número de vacas em lactação.
  double producaoLeitePorVacaDia({required double producaoTotalLeiteDiaL, required int numVacasEmLactacao}) {
    if (numVacasEmLactacao == 0) return 0.0;
    return producaoTotalLeiteDiaL / numVacasEmLactacao;
  }

  /// Calcula a Idade ao Primeiro Parto em meses.
  /// [dataNascimentoNovilha]: Data de nascimento da novilha.
  /// [dataPrimeiroParto]: Data do primeiro parto da novilha.
  double idadeAoPrimeiroParto({required DateTime dataNascimentoNovilha, required DateTime dataPrimeiroParto}) {
     if (dataPrimeiroParto.isBefore(dataNascimentoNovilha)) {
      throw ArgumentError('A data do primeiro parto não pode ser anterior à data de nascimento.');
    }
    int dias = dataPrimeiroParto.difference(dataNascimentoNovilha).inDays;
    return dias / 30.4375; // Média de dias em um mês
  }
}