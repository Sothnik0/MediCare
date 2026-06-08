# 🏥 MediCare
Aplicativo móvel de monitoramento médico desenvolvido em Flutter com integração ao Firebase.

# 👥 Equipe

| Desenvolvedor | Responsabilidade | Link do Vídeo |
| --- | --- | --- |
| **Lucas Gravatá Portilho** | Telas e funcionalidades de Gerenciamento de Medicamentos | https://drive.google.com/drive/folders/17PfMiyscaO7FwV1BUzGxttgcZFGqpfPj?usp=sharing |
| **Carlos Eduardo Lima Santos** | Integração Firebase em Main, auth_service, agenda_service, tela_inicial, tela_agenda_medical | https://drive.google.com/drive/folders/1WkyQKbf47DO33yUftHuT2eEJXfybXuCD?usp=sharing |
| **Enzo Gabriel de Araújo Soares** | Tela de cadastro e confirmação de cadastro e integração com o banco de dados | https://youtu.be/9lawYzdJNfU | 
| **Lucca Derlan Barreto Costa** | Tela de Login, integração com Firebase, autenticação com Google no Login e login com email institucional |  https://drive.google.com/file/d/1x61rWvl3DELbhRJw8JXQVbnwA2pZoZ7o/view?usp=drive_link
| **Davi Gabriel dos Santos Mota** | Tela buscar, integração Firebase em tela_buscar e modificar funções | https://drive.google.com/file/d/1QoosfPJyAAQGPdkWOO-V4T0Rrko89V98/view?usp=sharing

---

## 🚀 Como rodar o projeto

### Pré-requisitos
Certifique-se de ter instalado em sua máquina:
* **Flutter SDK** — versão `^3.10.8`
* **Dart SDK** — incluso por padrão no Flutter
* **VS Code** com a extensão oficial do Flutter instalada
* Um emulador Android/iOS configurado ou um dispositivo físico conectado em modo de depuração USB

### Verificar ambiente
```bash
flutter doctor
```
Todos os itens devem estar com ✅ antes de continuar.

### Passo a passo
```bash
# 1. Clone o repositório
git clone [https://github.com/seu-usuario/medicare.git](https://github.com/seu-usuario/medicare.git)
cd medicare

# 2. Instale as dependências (Isso já baixa tudo do Firebase automaticamente)
flutter pub get

# 3. Rode o app
flutter run
```

Para rodar em um dispositivo específico:
```bash
flutter devices          # lista os dispositivos disponíveis
flutter run -d <id>      # roda no dispositivo desejado
```

---

## 🔥 Integração com Firebase

O projeto já está 100% conectado ao **Firebase** na nuvem. **Você não precisa baixar ou instalar o Firebase no seu computador**, o código já faz tudo sozinho através do arquivo `firebase_options.dart`. 

Para testar e desenvolver, siga estas regras da equipe:

### 1. Regra de Autenticação (Login/Cadastro)
Foi implementada uma regra de negócio na camada de serviço. O aplicativo **só permite login e cadastro** de usuários pertencentes à instituição.
* **Obrigatório:** O e-mail utilizado nos testes deve terminar com `@souunit.com.br` (ex: `aluno@souunit.com.br`).
* Qualquer tentativa de usar outro domínio fará o sistema rejeitar a conexão e manter o usuário na tela de Login.

### 2. Acesso ao Painel do Banco de Dados
Para ver os dados sendo salvos em tempo real (como os usuários criados ou a Agenda Médica):
* Acesse o [Firebase Console](https://console.firebase.google.com/).
* Faça login com a sua conta Google que foi convidada pelo Administrador do Firebase (Carlos).
* Acesse a aba **Firestore Database** para ver os agendamentos e **Authentication** para ver os usuários.

### 3. Serviços Centralizados (Para Desenvolvedores)
Nunca chame o Firebase diretamente dentro das telas (arquivos `.dart` de UI). Todo o tráfego de dados deve passar pela pasta `core/servicos/`.
* Precisa logar/deslogar? Use o `AuthService()`.
* Precisa ler/gravar agendamentos? Use o `AgendaService()`.

---

## 📁 Estrutura de Pastas

```text
medicare/
│
├── assets/
│   └── images/            ← imagens e ícones do app (PNG, SVG)
│
├── lib/
│   ├── main.dart          ← ponto de entrada do app
│   ├── firebase_options.dart ← chaves de conexão geradas pelo Firebase (NÃO APAGAR)
│   │
│   ├── core/              ← recursos globais compartilhados por todas as features
│   │   ├── temas/
│   │   │   └── cores_app.dart     ← paleta de cores e gradientes do app
│   │   └── servicos/
│   │       ├── auth_service.dart   ← regras de login, cadastro e logout
│   │       └── agenda_service.dart ← regras de CRUD no banco de dados
│   │
│   └── features/          ← cada funcionalidade vive na sua própria pasta
│       │
│       ├── agenda/        ← módulo da agenda médica (Exemplo de feature)
│       │   ├── dados/
│       │   │   └── consulta_medica.dart      ← modelo de dados (classe)
│       │   └── apresentacao/
│       │       ├── paginas/
│       │       │   └── tela_agenda_medica.dart   ← tela principal
│       │       └── componentes/
│       │           ├── cartao_consulta.dart       ← widget do card
│       │           └── recortes_nuvem.dart        ← clippers das nuvens
│
├── pubspec.yaml           ← dependências (firebase_core, firebase_auth, etc)
└── README.md
```

---

## 🗂️ Regras da estrutura

| Pasta | O que colocar |
| --- | --- |
| `core/temas/` | Cores, tipografia, temas globais — usados por todo o app. |
| `core/servicos/` | Classes de integração com backend e APIs (Firebase, Google Sign-In, etc). |
| `features/<nome>/dados/` | Classes de modelo (ex: ConsultaMedica, Medicamento). |
| `features/<nome>/apresentacao/paginas/` | Telas completas (StatefulWidget principal). |
| `features/<nome>/apresentacao/componentes/` | Widgets menores reutilizados dentro da feature. |
| `assets/images/` | Imagens .png, .jpg, .svg — declarar também no pubspec.yaml. |

---

## 🎨 Cores do app

Todas as cores estão centralizadas em `lib/core/temas/cores_app.dart`.
Nunca use cores hardcoded — sempre referencie via `CoresApp`:

```dart
// ✅ Correto
color: CoresApp.cianoPrincipal

// ❌ Errado
color: Color(0xFF00E5FF)
```

| Token | Cor | Uso |
| --- | --- | --- |
| `cianoPrincipal` | `#00E5FF` | Cor principal do app |
| `cianoClaro` | `#CCF7FF` | Topo do gradiente de fundo |
| `azulCard` | `#0099BB` | Barra lateral dos cards |
| `fundoCreme` | `#F9F9F7` | Background do cabeçalho e rodapé |
| `textoForte` | `black87` | Títulos e textos primários |
| `textoSecundario` | `black54` | Subtítulos e textos de apoio |

---

## 🐛 Problemas comuns

**1. `flutter pub get` falhando no `pubspec.yaml`**
Verifique a indentação e o espaço após o `-` nos assets.

**2. App não encontra a imagem em runtime**
Confirme que o arquivo está em `assets/images/` e que o `pubspec.yaml` foi salvo antes de rodar `flutter pub get`.

**3. Erros de compilação em pacotes do Google/Firebase (Fantasma de Cache)**
Se o seu VS Code acusar erros estranhos no Firebase após puxar o código do GitHub, seu cache local pode estar corrompido. Rode os comandos abaixo no terminal do VS Code, em ordem:
```bash
flutter clean
flutter pub cache clean
flutter pub get
```
Após isso, reinicie o VS Code e rode `flutter run`.


# Guia de Instalação e Configuração do Firebase CLI via Terminal do VS Code

Este relatório apresenta o passo a passo detalhado para baixar, instalar e configurar a interface de linha de comando do Firebase (Firebase CLI) utilizando o terminal do Visual Studio Code (VS Code). Foram incluídos tanto o método convencional quanto alternativas para ambientes com restrições de privilégios de administrador.

---

## 1. Introdução ao Firebase CLI
O Firebase CLI (Command Line Interface) é a ferramenta essencial que permite gerenciar, configurar e implantar projetos do Firebase diretamente pelo terminal. No contexto do desenvolvimento cross-platform (como Flutter), ele automatiza a criação de registros de aplicativos e a geração de arquivos de configuração essenciais (como o `firebase_options.dart`).

---

## 2. Pré-requisitos e Preparation do Ambiente
Antes de iniciar, abra o seu projeto no **VS Code** e acesse o terminal integrado usando o atalho `Ctrl + '` (ou `Menu Superior > Terminal > Novo Terminal`).

Dependendo do nível de permissão do seu sistema e do usuário logado na máquina, escolha o método de instalação mais adequado abaixo:

* **Método A (Recomendado/Padrão):** Requer o **Node.js** e o gerenciador de pacotes **NPM** instalados.
* **Método B (Autônomo):** Ideal para computadores corporativos ou ambientes bloqueados onde **não há permissão de administrador** para instalar pacotes globais ou usar o NPM.

---

## 3. Método A: Instalação Padrão via NPM (Node Package Manager)

Se a sua máquina possui o Node.js configurado e permissões liberadas, siga estes passos no terminal do VS Code:

### Passo 3.1: Verificar instalações existentes
Certifique-se de que o Node e o NPM estão operacionais rodando o comando:
```bash
node -v
npm -v
```

### Passo 3.2: Instalação Global do Firebase Tools
Execute o comando de instalação global. O parâmetro `-g` garante que a ferramenta fique disponível em qualquer diretório do sistema:
```bash
npm install -g firebase-tools
```
> **Nota:** Caso ocorra erro de permissão (`EACCES`) no Linux ou macOS, pode ser necessário adicionar `sudo` antes do comando ou corrigir as permissões do diretório do NPM.

---

## 4. Método B: Instalação Autônoma (Sem dependência de NPM / Sem Admin)

Caso você esteja enfrentando restrições de privilégios, o Firebase disponibiliza um binário autônomo (*standalone binary*) que pode ser baixado e executado direto no terminal.

### Para Windows (via PowerShell no VS Code):
Abra o terminal do VS Code (certifique-se de selecionar o perfil do **PowerShell**) e execute a linha de comando abaixo:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('[https://firebase.tools/bin/win/instant/latest](https://firebase.tools/bin/win/instant/latest)'))
```
Esse script automatiza o download do executável portátil do Firebase e o configura temporariamente para a sua sessão do terminal, eliminando a necessidade de instaladores MSI ou permissões elevadas.

### Para macOS / Linux:
```bash
curl -sL [https://firebase.tools](https://firebase.tools) | bash
```

---

## 5. Autenticação e Login na Conta Firebase

Uma vez concluída a instalação por qualquer um dos métodos, é necessário conectar o CLI à sua conta do Google associada ao console do Firebase.

### Passo 5.1: Executar o Comando de Login
No terminal do VS Code, digite:
```bash
firebase login
```

### Passo 5.2: Fluxo de Autenticação
1. O terminal exibirá uma pergunta sobre a coleta de dados de erro anônimos. Digite `Y` (Sim) ou `N` (Não) e pressione **Enter**.
2. O navegador padrão do seu computador será aberto automaticamente em uma página de login do Google.
3. Selecione a conta onde está hospedado o seu projeto do Firebase.
4. Clique em **"Permitir"** para conceder ao Firebase CLI autorização de gerenciamento de dados.
5. Ao retornar ao VS Code, o terminal exibirá a mensagem de sucesso: `✔ Success! Logged in as seu-email@domain.com`.

---

## 6. Integração Específica para Projetos Flutter (FlutterFire)

Se o objetivo final for gerar a arquitetura de chaves do Firebase para o ambiente Flutter (`firebase_options.dart`), execute as etapas complementares a seguir:

### Passo 6.1: Ativação do FlutterFire CLI
Utilize o próprio motor do Dart para ativar globalmente o assistente do FlutterFire:
```bash
dart pub global activate flutterfire_cli
```

### Passo 6.2: Configuração Automática do Projeto
Estando estritamente na **raiz** do seu projeto Flutter, execute o utilitário de mapeamento:
```bash
flutterfire configure
```

### Passo 6.3: Seleção e Geração
1. O terminal exibirá uma lista contendo todos os seus projetos ativos no console do Firebase. Utilize as setas direcionais (`↑` e `↓`) do teclado para navegar e pressione **Enter** no projeto correto.
2. Selecione as plataformas alvo do seu aplicativo (Android, iOS, Web) usando a barra de espaço para marcar/desmarcar e confirme com **Enter**.
3. O CLI se encarregará de criar os aplicativos correspondentes dentro do painel web e, por fim, gerará de forma nativa o arquivo estruturado em `lib/firebase_options.dart`.

---

## 7. Resolução de Problemas Comuns (Troubleshooting)

| Sintoma / Erro | Causa Provável | Solução |
| :--- | :--- | :--- |
| `'firebase' não é reconhecido como um comando interno...` | O terminal ainda não atualizou as variáveis de ambiente (PATH) após a instalação. | Feche completamente o VS Code e abra-o novamente. Se persistir, utilize o Método B de instalação. |
| `Erro de execução de scripts` no Windows | Restrição de segurança do PowerShell para rodar binários externos descarregados da web. | Execute `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` no PowerShell antes de tentar rodar o comando. |
| `O arquivo não pode ser carregado porque a execução de scripts foi desabilitada` | Bloqueio de diretivas locais da máquina. | Mude o terminal padrão do VS Code de *PowerShell* para *Command Prompt (CMD)* tradicional e execute os comandos por ele. |
