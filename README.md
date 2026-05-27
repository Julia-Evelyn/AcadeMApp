# AcadeMApp

Aplicativo Flutter para acompanhamento de treino, historico e preferencias visuais.

## Visao Geral

O projeto usa um tema simples e consistente para as telas principais:

- `HomeView`: dashboard com cards de resumo e acoes rapidas.
- `HistoricoView`: area para exibicao de treinos concluidos.
- `ConfiguracoesView`: controle de aparencia com tema claro, escuro e sistema.

Os tokens abaixo documentam o estado visual atual do app e servem como base para evoluir o design system sem quebrar consistencia entre telas.

## Stack

- Flutter
- Material 3
- `firebase_core`
- `cloud_firestore`
- `shared_preferences`
- `sqflite`

## Servicos da Sprint

Para concluir a sprint de servicos com o menor numero de mudancas, o projeto passou a concentrar integracoes externas em uma camada dedicada:

- `FirebaseBootstrapService`: inicializacao do Firebase no startup.
- `AppPreferencesService`: persistencia local de tema, cor de destaque, alerta e perfil.
- `AlarmAudioService`: reproducao do alarme de inatividade.
- `ProfileImagePickerService`: selecao de imagem do perfil.
- `AtividadeStorageService`: persistencia local de atividades com `sqflite`.

Tambem foram criados controllers para `Home` e `Perfil` para reduzir logica de negocio dentro das telas sem introduzir Provider.

## Arquivos-Chave

- [app_theme.dart](C:/Users/gabri/Downloads/Projeto/AcadeMApp/lib/core/theme/app_theme.dart:3)
- [theme_controller.dart](C:/Users/gabri/Downloads/Projeto/AcadeMApp/lib/core/theme/theme_controller.dart:4)
- [home_view.dart](C:/Users/gabri/Downloads/Projeto/AcadeMApp/lib/features/home/view/home_view.dart:3)
- [configuracoes_view.dart](C:/Users/gabri/Downloads/Projeto/AcadeMApp/lib/features/configuracoes/view/configuracoes_view.dart:5)
- [historico_treinos_view.dart](C:/Users/gabri/Downloads/Projeto/AcadeMApp/lib/features/historico_treinos/view/historico_treinos_view.dart:3)

## Design Tokens

### Cores

| Token | Valor | Uso |
| --- | --- | --- |
| `color.brand.primary` | `#1E40AF` | Cor principal do app, app bar no tema claro e botoes primarios no tema claro |
| `color.brand.accent` | `#10B981` | Cor de destaque usada nos botoes do tema escuro |
| `color.background.light` | `#F3F4F6` | Fundo base do tema claro |
| `color.background.dark` | `#111827` | Fundo base do tema escuro |
| `color.surface.appBar.dark` | `#1F2937` | Fundo da app bar no tema escuro |
| `color.text.onPrimary` | `#FFFFFF` | Texto e icones sobre superficies primarias |
| `color.feedback.activity` | `Colors.orange` | Card de progresso diario |
| `color.feedback.inactivity` | `Colors.blue` | Card de alerta de inatividade |

### Tema Semantico

| Token | Valor atual | Uso |
| --- | --- | --- |
| `theme.mode.default` | `ThemeMode.system` | Estado inicial do tema |
| `theme.mode.light` | `ThemeMode.light` | Forca o modo claro |
| `theme.mode.dark` | `ThemeMode.dark` | Forca o modo escuro |

### Espacamento

| Token | Valor | Uso |
| --- | --- | --- |
| `space.xs` | `10` | Espaco entre botoes e blocos pequenos |
| `space.sm` | `20` | Padding vertical e separacao entre cards |
| `space.md` | `30` | Padding vertical principal da home |
| `space.lg` | `40` | Separacao antes das acoes principais |
| `space.container.mobile` | `20` | Padding horizontal padrao no mobile |
| `space.container.desktop` | `100` | Padding horizontal em layouts largos |

### Borda e Forma

| Token | Valor | Uso |
| --- | --- | --- |
| `radius.button` | `8` | Botoes elevados no tema |
| `radius.card.md` | `12` | Card de configuracoes |
| `radius.card.lg` | `15` | Cards de status na home |

### Elevacao

| Token | Valor | Uso |
| --- | --- | --- |
| `elevation.none` | `0` | App bar |
| `elevation.sm` | `2` | Card de configuracoes |
| `elevation.md` | `4` | Cards de status |

### Tipografia

| Token | Valor | Uso |
| --- | --- | --- |
| `text.hero` | `displaySmall + bold` | Saudacao principal da home |
| `text.sectionTitle` | `18 + bold` | Titulo "Aparencia" |
| `text.metric` | `20 + bold` | Valor numerico dos cards |
| `text.body` | `titleLarge` ou estilo padrao | Textos secundarios e mensagens |

## Mapeamento dos Tokens no Flutter

```dart
class AppTheme {
  static const Color primaryColor = Color(0xFF1E40AF);
  static const Color accentColor = Color(0xFF10B981);
  static const Color lightBackground = Color(0xFFF3F4F6);
  static const Color darkBackground = Color(0xFF111827);
}
```

Exemplos de uso no projeto:

- `AppTheme.primaryColor` define a identidade visual principal.
- `BorderRadius.circular(8)` aparece no estilo dos botoes.
- `BorderRadius.circular(12)` e `BorderRadius.circular(15)` diferenciam cards de configuracao e cards de destaque.
- `EdgeInsets.symmetric(horizontal: 20, vertical: 20)` e `EdgeInsets.symmetric(horizontal: 100, vertical: 20)` controlam responsividade simples.

## Convencao Recomendada

Para manter o design system escalavel, use estes nomes ao criar novos tokens:

```text
color.brand.*
color.background.*
color.surface.*
color.text.*
color.feedback.*
space.*
radius.*
elevation.*
text.*
theme.mode.*
```

## Como Evoluir

- Centralizar espaco, radius e elevation em uma camada de tokens em `lib/core/theme/`.
- Criar `TextTheme` completo para evitar tamanhos soltos nas views.
- Substituir `Colors.orange` e `Colors.blue` por tokens semanticos fixos.
- Expandir tokens para estados de sucesso, aviso, erro e info.

## Executar o Projeto

```bash
flutter pub get
flutter run
```

No Windows, plugins Flutter exigem suporte a symlink. Se o build falhar, ative o `Developer Mode` nas configuracoes do sistema.
