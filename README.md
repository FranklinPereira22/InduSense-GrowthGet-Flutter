# InduSense — Monitoramento Ambiental Industrial (Growth Get)

App Flutter/FlutterFlow para monitoramento em tempo real de sensores
IoT/ESP32 (temperatura, umidade, qualidade do ar e gases), com histórico,
alertas e gestão de perfil. Backend: Nest.js + PostgreSQL, API REST/JSON.

## 1. Estrutura de pastas

```
lib/
├── main.dart                        # bootstrap + MultiProvider + MaterialApp
├── core/
│   ├── theme/app_theme.dart         # cores, tema Material 3, statusColor()
│   └── constants/api_constants.dart # baseUrl, endpoints, flag useMock
├── models/
│   ├── user_model.dart              # UserModel, AuthResponse
│   ├── sensor_model.dart            # SensorModel, SensorType, SensorStatus
│   ├── reading_model.dart           # ReadingModel (histórico)
│   └── alert_model.dart             # AlertModel
├── services/
│   ├── api_client.dart              # wrapper HTTP (GET/POST/PATCH) + token
│   ├── auth_service.dart            # login, cadastro, logout, sessão
│   ├── auth_provider.dart           # ChangeNotifier de sessão (Provider)
│   ├── sensor_service.dart          # sensores + leituras/histórico
│   ├── alert_service.dart           # alertas + marcar como lido
│   └── mock_data_service.dart       # dados fictícios (useMock = true)
├── widgets/
│   ├── sensor_card.dart             # card de sensor (dashboard)
│   ├── status_indicator.dart        # pílula normal/atenção/crítico/offline
│   └── state_widgets.dart           # Loading / EmptyState / AppError
├── screens/
│   ├── splash/splash_screen.dart
│   ├── auth/login_screen.dart
│   ├── auth/cadastro_screen.dart
│   ├── dashboard/dashboard_screen.dart
│   ├── historico/historico_screen.dart
│   ├── sensor_detail/sensor_detail_screen.dart
│   ├── alertas/alertas_screen.dart
│   ├── configuracoes/configuracoes_screen.dart
│   └── home_shell.dart              # bottom navigation (4 abas)
└── routes/app_routes.dart           # rotas nomeadas
```

Camadas separadas: **UI** (screens/widgets) → **services** (regra de
negócio + chamada de API) → **models** (contratos de dados). As telas
nunca chamam `http` diretamente; sempre passam por um service.

## 2. Navegação

Rotas nomeadas (`AppRoutes`), com `HomeShell` (bottom navigation) agrupando
Dashboard, Histórico, Alertas e Perfil:

```
/            → SplashScreen        (checa sessão salva)
/login       → LoginScreen
/cadastro    → CadastroScreen
/dashboard   → HomeShell(aba 0)    → DashboardScreen
/historico   → HomeShell(aba 1)    → HistoricoScreen
/alertas     → HomeShell(aba 2)    → AlertasScreen
/configuracoes → HomeShell(aba 3) → ConfiguracoesScreen
/sensor-detalhe → SensorDetailScreen (argumento: sensorId String)
```

Fluxo: Splash decide entre `/login` e `/dashboard` conforme sessão salva
em `SharedPreferences`. Logout limpa o token e retorna para `/login`
(`pushNamedAndRemoveUntil`).

## 3. Models (resumo dos campos)

| Model | Campos principais |
|---|---|
| `UserModel` | id, nome, email, cargo?, empresa? |
| `SensorModel` | id, nome, localizacao, tipo (enum), status (enum), valorAtual, limiteMin, limiteMax, ultimaLeitura, online |
| `ReadingModel` | id, sensorId, sensorNome, tipo, valor, dataHora, status |
| `AlertModel` | id, sensorId, sensorNome, tipo, valorMedido, limite, dataHora, lido, severidade |

`SensorType` = temperatura \| umidade \| qualidadeAr \| gas
`SensorStatus` = normal \| atencao \| critico \| offline

## 4. Endpoints esperados (Nest.js) + JSON

> `ApiConstants.baseUrl` = `https://api.indusense.growthget.com/v1`
> (ajustar para o ambiente real). Todas as rotas autenticadas usam
> `Authorization: Bearer <token>`.

### Autenticação

**POST `/auth/login`**
```json
// Request
{ "email": "carlos@growthget.com", "senha": "123456" }
// Response 200
{
  "token": "jwt...",
  "user": { "id": "u1", "nome": "Carlos Andrade", "email": "carlos@growthget.com" }
}
```

**POST `/auth/register`**
```json
// Request
{ "nome": "Maria Silva", "email": "maria@growthget.com", "senha": "123456", "empresa": "Growth Get" }
// Response 201 → mesmo formato de /auth/login
```

**POST `/auth/logout`** → 204 (sem corpo)
**GET `/auth/me`** → retorna `UserModel` do usuário logado (para restaurar sessão)

### Sensores

**GET `/sensors`**
```json
[
  {
    "id": "s1",
    "nome": "Sensor Temp — Linha A",
    "localizacao": "Galpão 1 · Linha de Produção A",
    "tipo": "temperatura",
    "status": "normal",
    "valorAtual": 24.6,
    "limiteMin": 15,
    "limiteMax": 35,
    "ultimaLeitura": "2026-08-13T14:02:00Z",
    "online": true
  }
]
```

**GET `/sensors/:id`** → objeto único no mesmo formato acima.

### Histórico

**GET `/readings?sensorId=&tipo=&inicio=&fim=`**
```json
[
  {
    "id": "s1-r0",
    "sensorId": "s1",
    "sensorNome": "Sensor Temp — Linha A",
    "tipo": "temperatura",
    "valor": 24.6,
    "dataHora": "2026-08-13T14:02:00Z",
    "status": "normal"
  }
]
```

### Alertas

**GET `/alerts`**
```json
[
  {
    "id": "a1",
    "sensorId": "s3",
    "sensorNome": "Qualidade do Ar — Solda",
    "tipo": "qualidade_ar",
    "valorMedido": 168,
    "limite": 100,
    "dataHora": "2026-08-13T14:00:00Z",
    "lido": false,
    "severidade": "critico"
  }
]
```

**PATCH `/alerts/:id/read`** → 204, marca o alerta como lido.

## 5. Código completo dos arquivos principais

Todos os arquivos foram entregues no ZIP anexo (`indusense_flutter.zip`),
já organizados na estrutura acima. Pontos de destaque:

- **`api_client.dart`**: único ponto de chamada HTTP, trata token, timeout
  (15s), erros de rede e mapeia `401` para "Sessão expirada".
- **`mock_data_service.dart`**: dados fictícios (6 sensores, 24 leituras
  cada, 4 alertas) usados enquanto `ApiConstants.useMock = true` — **basta
  trocar essa flag para `false`** para consumir a API real, sem alterar
  nenhuma tela.
- Toda tela de listagem trata 3 estados: **carregando** (`LoadingWidget`),
  **vazio** (`EmptyStateWidget`) e **erro** (`AppErrorWidget` com botão
  "Tentar novamente").
- Dashboard atualiza sensores a cada 30s (`Timer.periodic`) simulando
  tempo real; pode ser substituído por WebSocket/polling real no service.

## 6. Configurações necessárias no FlutterFlow

Para importar/recriar este projeto no FlutterFlow:

1. **Custom Code → Actions/Functions**: reaproveitar `api_client.dart`,
   `auth_service.dart`, `sensor_service.dart` e `alert_service.dart` como
   **Custom Actions**, retornando os models como `Custom Data Types`.
2. **Custom Data Types**: criar `SensorModel`, `ReadingModel`,
   `AlertModel`, `UserModel` no FlutterFlow espelhando os campos da
   seção 3, com os mesmos nomes/tipos usados no JSON de resposta.
3. **API Calls (FlutterFlow API Manager)**: cadastrar as chamadas da
   seção 4 (método, URL, headers `Authorization: Bearer [token_app_state]`,
   body JSON), habilitando "Make API Call on Widget Load" no Dashboard,
   Histórico e Alertas.
4. **App State (variáveis globais)**: `authToken` (string, persisted),
   `currentUser` (Custom Data Type UserModel, persisted), `isLoggedIn`
   (bool, persisted) — usados para a lógica de sessão/logout.
5. **Página inicial condicional**: configurar "Initial Action" da
   página Splash chamando a action de restaurar sessão e navegando
   condicionalmente para Login ou Dashboard.
6. **Tema**: em Theme Settings, replicar a paleta de
   `core/theme/app_theme.dart` (Primary `#0B5FFF`, Success `#1FAE64`,
   Warning `#F5A623`, Error `#E23D3D`, Background `#F4F6F9`).
7. **Pacotes/Dependências (Custom Package/pub.dev)**: adicionar
   `fl_chart` (gráficos do Histórico/Detalhe do Sensor) e `intl`
   (formatação de datas em pt-BR) em Settings → App Dependencies.
8. **Navegação**: replicar as rotas da seção 2, usando um
   "Bottom Navigation Bar" component como página wrapper (equivalente
   ao `HomeShell`) para Dashboard/Histórico/Alertas/Perfil.
9. **Idioma**: definir `pt-BR` como idioma padrão único em
   App Settings → Localization.

## 7. Rodando localmente (Flutter puro)

```bash
flutter pub get
flutter run
```

O app já funciona 100% com dados mockados (`ApiConstants.useMock = true`).
Para conectar ao backend Nest.js real, altere `useMock` para `false` e
ajuste `baseUrl` em `lib/core/constants/api_constants.dart`.
