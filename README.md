# AcadeMApp 🏃‍♀️💪

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)

O **AcadeMApp** é um aplicativo móvel projetado para ser o seu parceiro na rotina de treinos e combate ao sedentarismo. Com uma interface moderna, acessível e recursos de monitoramento, ele se adapta ao ritmo e às necessidades de cada usuário.

---

## ✨ Funcionalidades Principais

* **Autenticação Flexível:** * Login integrado com Firebase Authentication.
    * **Modo Visitante:** Permite a utilização local do app com persistência de dados isolada no cache (`SharedPreferences`), garantindo que usuários casuais não precisem criar conta imediatamente.
* **Acessibilidade em Primeiro Lugar ♿:** * Interruptor dinâmico que altera a tipografia de todo o sistema para a família de fontes **Lexend**, cientificamente otimizada para auxiliar pessoas com dislexia.
* **Monitoramento de Corridas (GPS):**
    * Mapeamento em tempo real de rotas utilizando `flutter_map` e `geolocator`.
    * Cálculo preciso de distância percorrida, tempo decorrido e estimativa de calorias queimadas.
    * Filtros inteligentes antidistorção (ignora flutuações de satélite e "teletransportes" do GPS).
* **Rotina de Treinos Dinâmica:**
    * Integração com API externa (ExerciseDB) para buscar uma vasta biblioteca de exercícios.
    * Tradução automatizada de termos e instruções para o português nativo.
    * Cronômetro de treino integrado (fase ativa e fase de descanso) com mudança visual de interface.
* **Sincronização em Nuvem (Cloud Sync):**
    * O histórico de corridas e os dados físicos do perfil (peso/altura) são salvos de forma redundante: localmente para acesso rápido e no **Firebase Database** como backup.
    * Ao realizar o login, o app puxa instantaneamente o seu histórico salvo em outros dispositivos.
* **Personalização de Interface:**
    * Suporte completo a Tema Claro (Light) e Tema Escuro (Dark).
    * Customização da "Cor de Destaque" (Accent Color) de acordo com a preferência do usuário.

---

## 🏗️ Arquitetura e Estrutura

O projeto foi construído seguindo a arquitetura **Feature-First**, garantindo que o código seja altamente escalável, modular e de fácil manutenção:

```text
lib/
├── core/
│   ├── layout/       # Componentes de estrutura principal (MainLayout, Navigation)
│   ├── services/     # Serviços globais (Firebase, Preferences, GPS)
│   └── theme/        # Controladores de Tema e Paleta de Cores
├── features/
│   ├── auth/         # Onboarding, Login, Setup de Perfil e Splash Screen
│   ├── configuracoes/# Controle de Acessibilidade, Tema e Cores
│   ├── perfil/       # Visualização e Edição de Perfil
│   └── treinos/      # Lógica de consumo de API de exercícios e timers
└── main.dart         # Ponto de entrada e injeção de dependências
