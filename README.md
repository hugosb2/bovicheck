# 🐄 BoviCheck

<div align="center">

![BoviCheck](assets/icon.png)

**Aplicativo completo para gerenciamento de rebanho bovino, cálculo de índices zootécnicos e análise de produtividade.**

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Android](https://img.shields.io/badge/Android-9.0+-success)](https://developer.android.com)

</div>

---

## 📋 Índice

- [Sobre o Projeto](#-sobre-o-projeto)
- [Funcionalidades](#-funcionalidades)
- [Tecnologias Utilizadas](#-tecnologias-utilizadas)
- [Requisitos](#-requisitos)
- [Instalação](#-instalação)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Licença](#-licença)

---

## 🎯 Sobre o Projeto

O **BoviCheck** é uma solução completa desenvolvida em Flutter para gestão de rebanhos bovinos. O aplicativo permite que produtores rurais gerenciem seus animais, calculem índices zootécnicos importantes e analisem a produtividade do rebanho de forma intuitiva e eficiente.

### Principais Diferenciais

- ✅ **Interface moderna e responsiva** com Material Design 3
- ✅ **Análise inteligente** com IA (Gemini)
- ✅ **Cálculos automáticos** de índices zootécnicos
- ✅ **Banco de dados local** SQLite
- ✅ **Backup e restauração** de dados
- ✅ **Suporte a Android**

---

## ✨ Funcionalidades

### 🏠 Dashboard
- Visão geral do rebanho com estatísticas principais
- Análise inteligente com IA (Powered by Gemini)
- Indicadores globais e por lote
- Gráficos de evolução temporal

### 🐄 Gestão de Animais
- **Cadastro completo** de animais com dados básicos
- **Histórico de pesagens** com gráficos de evolução
- **Registros de saúde** (vacinas, medicamentos)
- **Controle reprodutivo** (cios, inseminações, partos)
- **Produção de leite** (registro diário com período)
- **Análise individual** de desempenho

### 📊 Indicadores Zootécnicos
- Taxa de Natalidade
- Taxa de Prenhez
- Taxa de Desmame
- Taxa de Mortalidade
- Idade ao 1º Parto
- Intervalo Entre Partos (IEP)
- GMD (Ganho Médio Diário)
- Produção Média Diária de Leite

### 🏡 Gestão de Lotes
- Criação e gerenciamento de lotes
- Associação de animais a lotes
- Capacidade e área do lote

### 📝 Formulários de Registro
- Pesagem
- Produção de Leite
- Eventos Sanitários
- Eventos Reprodutivos
- Abate

### ⚙️ Configurações
- **Temas**: Claro, Escuro ou Sistema
- **Cores dinâmicas**: Adaptação automática
- **Backup e Restauração**: Proteção dos dados

---

## 🛠 Tecnologias Utilizadas

### Framework e Linguagem
- **Flutter** 3.9.2+
- **Dart** 3.9.2+

### Principais Dependências

| Categoria | Pacote | Versão |
|-----------|--------|--------|
| Estado | `provider` | ^6.1.2 |
| Banco de Dados | `sqflite` | ^2.4.2 |
| Gráficos | `fl_chart` | ^0.70.2 |
| Animações | `flutter_animate` | ^4.5.2 |
| Arquivos | `file_picker` | ^8.1.7 |
| Compartilhamento | `share_plus` | ^10.1.4 |
| UUID | `uuid` | ^4.5.1 |
| Preferências | `shared_preferences` | ^2.5.2 |
| Internacionalização | `intl` | ^0.20.2 |

---

## 📱 Requisitos

### Para Desenvolvimento
- Flutter SDK >= 3.9.2
- Dart SDK >= 3.9.2
- Android Studio / VS Code
- Git

### Para Execução
- **Android**: Android 9.0+ (API 28+)

---

## 🚀 Instalação

### 1. Clone o repositório

```bash
git clone https://github.com/seu-usuario/bovicheck.git
cd bovicheck
```

### 2. Instale as dependências

```bash
flutter pub get
```

### 3. Configure a API Key (Opcional)

Para habilitar o recurso de IA Consultant, edite o arquivo `lib/servicos/configuracao.dart`:

```dart
class Configuracao {
  static const String geminiApiKey = 'SUA_CHAVE_AQUI';
}
```

Obtenha sua chave em: https://aistudio.google.com/app/apikey

### 4. Build

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

---

## 📁 Estrutura do Projeto

```
bovicheck/
├── lib/
│   ├── main.dart                    # Ponto de entrada
│   ├── modelos/                     # Modelos de dados
│   │   ├── animal.dart
│   │   ├── lote.dart
│   │   ├── propriedade.dart
│   │   ├── log_sistema.dart
│   │   └── eventos/
│   │       ├── abate.dart
│   │       ├── pesagem.dart
│   │       ├── producao_leite.dart
│   │       ├── evento_reprodutivo.dart
│   │       └── evento_sanitario.dart
│   ├── provedores/                  # Providers de estado
│   │   ├── provedor_fazenda.dart
│   │   └── provedor_tema.dart
│   ├── servicos/                    # Serviços
│   │   ├── banco_dados_servico.dart
│   │   ├── configuracao.dart
│   │   └── ia_gemini_cliente.dart
│   ├── estilos/                     # Estilos e temas
│   │   ├── tema.dart
│   │   ├── cores.dart
│   │   ├── icones.dart
│   │   └── tela_padrao.dart
│   └── telas/                       # Telas do aplicativo
│       ├── 1_boas_vindas/
│       ├── 2_configuracao_inicial/
│       ├── 4_dashboard/
│       ├── 5_ia_consultor/
│       ├── 6_indicadores/
│       ├── 8_rebanho/
│       ├── 9_lotes/
│       ├── 10_formularios/
│       └── 11_configuracoes/
├── assets/
│   └── icons/
├── pubspec.yaml
└── README.md
```

---

## 📖 Como Usar

### Primeiros Passos

1. **Abrir o aplicativo**
   - Na primeira execução, configure uma nova fazenda
   - Comece a cadastrar seus animais e lotes

2. **Dashboard**
   - Visualize estatísticas gerais do rebanho
   - Acesse análises da IA
   - Navegue rapidamente para outras seções

3. **Rebanho**
   - Lista de todos os animais
   - Filtros por sexo, categoria, lote
   - Detalhes de cada animal

4. **Lotes**
   - Gerenciamento de lotes
   - Visualização de animais por lote

5. **Formulários**
   - Registro de pesagem
   - Registro de produção de leite
   - Eventos sanitários
   - Eventos reprodutivos
   - Abate

6. **Indicadores**
   - Visualização de índices zootécnicos
   - Histórico de indicadores
   - Gráficos de evolução

---

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

---

## 👨‍💻 Desenvolvimento

Desenvolvido para produtores rurais brasileiros.

---

## 🙏 Agradecimentos

- Flutter Team
- Comunidade Flutter
- Todos os mantenedores dos pacotes utilizados
