# App Test - Aplicação Social Flutter

Uma aplicação social desenvolvida em Flutter que combina autenticação Firebase com uma API REST simulada para posts. O projeto implementa Clean Architecture com BLoC para gerenciamento de estado.

## 🔐 Credenciais de Teste

**Email:** `teste@gmail.com`  
**Senha:** `teste123`

> ⚠️ **Importante:** Você pode usar estas credenciais para fazer login na aplicação ou criar sua própria conta.

### 📝 Criando Nova Conta
Se preferir, você pode **criar sua própria conta** através da tela de registro da aplicação. Basta:
1. Abrir a aplicação
2. Ir para a tela de "Cadastro"
3. Preencher os dados
4. Criar sua conta

## 🚀 Pré-requisitos e Configuração

### 📥 Clonando o Projeto

Primeiro, clone o repositório do projeto:

```bash
git clone https://github.com/LeandroSimo/app-social-flutter.git
cd app-social-flutter
```

### ⚙️ Instalação das Ferramentas

1. **Flutter SDK** (versão 3.9.0)
2. **Node.js** (para rodar a API simulada)
3. **Git**

### 📡 **PRIMEIRO PASSO OBRIGATÓRIO: Rodar a API Simulada**

> 🔴 **ATENÇÃO:** A aplicação **NÃO EXIBIRÁ OS POSTS** sem a API simulada rodando primeiro!

#### Instalação do JSON Server
```bash
npm install -g json-server
```

#### Executar a API Simulada
```bash
# No diretório raiz do projeto
npx json-server --watch db.json --port 3000 --host 0.0.0.0
```

A API ficará disponível em: `http://localhost:3000`

### 🔧 Configuração da URL da API

**📱 Para Dispositivo Físico:**
1. Descubra o IP da sua máquina na rede local
   - **Windows:** Execute `ipconfig` no terminal
   - **macOS/Linux:** Execute `ifconfig` no terminal
   - Procure pelo endereço IP da sua rede (ex: 192.168.x.x)
2. Edite o arquivo `lib\src\core\network\api_application.dart`:
```dart
_dio.options.baseUrl = 'http://SEU_IP_AQUI:3000'; // Ex: http://192.168.1.100:3000
```

**🖥️ Para Emulador Android:**
```dart
_dio.options.baseUrl = 'http://10.0.2.2:3000'; // IP especial do emulador
```

**🍎 Para Simulador iOS:**
```dart
_dio.options.baseUrl = 'http://localhost:3000'; // ou http://127.0.0.1:3000
```

## 🏃‍♂️ Como Executar

### 1. Instalar Dependências
```bash
flutter pub get
```

### 2. Gerar Arquivos de Mock (para testes)
```bash
flutter packages pub run build_runner build
```

### 3. Executar a Aplicação
```bash
flutter run
```

## 🧪 Executando os Testes

### Todos os Testes
```bash
flutter test
```

### Executar com Verbose
```bash
flutter test --verbose
```

## 🏗️ Arquitetura do Projeto

O projeto segue os princípios da **Clean Architecture** combinada com **Feature-First Organization** e **BLoC Pattern**.

### 📁 Estrutura de Pastas

```
lib/
├── src/
│   ├── core/                     # Funcionalidades compartilhadas
│   │   ├── errors/               # Tratamento de erros customizados
│   │   ├── network/              # Configuração de rede (Dio)
│   │   ├── routes/               # Roteamento da aplicação
│   │   ├── services/             # Serviços globais
│   │   ├── theme/                # Tema e estilos
│   │   ├── utils/                # Utilitários
│   │   ├── validators/           # Validadores
│   │   └── widgets/              # Widgets reutilizáveis
│   │
│   └── features/                 # Funcionalidades por feature
│       ├── auth/                 # Autenticação (Firebase)
│       │   ├── data/
│       │   │   ├── domain/
│       │   │   │   ├── entities/      # User
│       │   │   │   └── repositories/  # AuthRepository (interface)
│       │   │   ├── repositories/      # AuthRepositoryImpl
│       │   │   └── services/          # FirebaseAuthService
│       │   └── presentation/
│       │       ├── bloc/              # AuthCubit + AuthState
│       │       ├── screens/           # Login, Register, etc.
│       │       └── widgets/           # Widgets específicos de auth
│       │
│       ├── posts/                # Posts (API REST)
│       │   ├── data/
│       │   │   ├── domain/
│       │   │   │   ├── entities/      # Post
│       │   │   │   └── repositories/  # PostRepository (interface)
│       │   │   ├── models/            # PostModel (JSON mapping)
│       │   │   ├── repositories/      # PostRepositoryImpl
│       │   │   └── services/          # PostApiService (Dio)
│       │   └── presentation/
│       │       ├── bloc/              # PostCubit + PostState
│       │       ├── screens/           # Feed, PostDetail, etc.
│       │       └── widgets/           # PostItem, etc.
│       │
│       ├── profile/              # Perfil do usuário (Firestore)
│       └── home/                 # Tela principal
│
├── app_widget.dart              # Widget principal com providers
└── main.dart                    # Entry point
```

### 🧩 Camadas da Arquitetura

#### **1. Domain (Domínio)**
- **Entities:** Objetos de negócio puros (Post, User, UserProfile)
- **Repositories:** Interfaces/contratos dos repositórios
- **Use Cases:** Regras de negócio (implícitas nos Cubits)

#### **2. Data (Dados)**
- **Models:** Mapeamento JSON ↔ Objeto (PostModel)
- **Repositories:** Implementação concreta dos contratos
- **Services:** Comunicação com APIs externas
  - `FirebaseAuthService`: Firebase Authentication
  - `PostApiService`: API REST com Dio
  - `FirestoreUserProfileRepository`: Firestore

#### **3. Presentation (Apresentação)**
- **BLoC/Cubit:** Gerenciamento de estado
  - `AuthCubit`: Estado de autenticação
  - `PostCubit`: Lista de posts e paginação
  - `PostDetailCubit`: Detalhes de um post
- **Screens:** Telas da aplicação
- **Widgets:** Componentes visuais

### 🔄 Fluxo de Dados

```
UI → Cubit → Repository → Service → API/Firebase
   ←       ←            ←         ←
```

**Exemplo - Carregamento de Posts:**
1. **UI** chama `PostCubit.loadPosts()`
2. **PostCubit** chama `PostRepository.getPosts()`
3. **PostRepositoryImpl** chama `PostApiService.getPosts()`
4. **PostApiService** faz requisição HTTP com Dio
5. **Resposta** volta transformando JSON → Model → Entity
6. **Cubit** emite novo estado com os posts
7. **UI** reage ao estado e atualiza a tela

### 📋 Gerenciamento de Estado

- **BLoC Pattern** com Cubit para simplicidade
- **Estados tipados** para cada feature
- **Stream de autenticação** para reatividade
- **Loading, Success, Error** states bem definidos

### 🌐 Integrações

- **Firebase Authentication:** Login/registro de usuários
- **Firestore:** Armazenamento de perfis de usuário
- **API REST Simulada:** Posts e interações sociais
- **Dio:** Cliente HTTP com interceptors

### 🧪 Estratégia de Testes

- **Unit Tests:** Lógica pura, validadores, transformações
- **Repository Tests:** Mocks das APIs
- **BLoC Tests:** Estados e transições
- **Widget Tests:** Componentes da UI
- **Integration Tests:** Fluxos completos

## 🛠️ Tecnologias Utilizadas

- **Flutter/Dart**
- **BLoC/Cubit** (gerenciamento de estado)
- **Firebase** (Auth + Firestore)
- **Dio** (cliente HTTP)
- **JSON Server** (API simulada)
- **Mockito** (mocks para testes)
- **Equatable** (comparação de objetos)

## 📱 Funcionalidades

- ✅ Autenticação com Firebase (login/registro)
- ✅ Feed de posts com paginação infinita
- ✅ Visualização de detalhes de posts
- ✅ Perfil de usuário
- ✅ Upload de imagens
- ✅ Pull-to-refresh
- ✅ Tratamento de erros
- ✅ Estados de loading

## 🐛 Solução de Problemas

### API não responde
- Verifique se o JSON Server está rodando
- Confirme a URL no `api_application.dart`
- Para device físico, use IP da rede local

### Erro de autenticação
- Use as credenciais: `teste@gmail.com` / `teste123`
- Verifique configuração do Firebase

### Testes falhando
- Execute `flutter packages pub run build_runner build`
- Certifique-se que a API simulada está rodando

---

## 📄 Licença

Este projeto é para fins de demonstração.
