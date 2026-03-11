# TheMovieDB iOS Challenge

Uma aplicação iOS moderna desenvolvida em SwiftUI que permite aos usuários explorar, buscar e gerenciar filmes do TheMovieDB API com uma arquitetura robusta e testes abrangentes.

---

## Funcionalidades

### Principais Features

- Lista de Filmes Populares - Exibe filmes populares em grid/lista scrollável
- Busca de Filmes - Busca em tempo real por título de filme com debounce
- Detalhes do Filme - Visualiza informações completas (sinopse, data de lançamento, rating, gêneros)
- Sistema de Favoritos - Adicione/remova filmes favoritos com persistência via Core Data
- Compartilhamento de Imagem - Compartilhe a imagem do poster através dos apps nativos do iOS
- Ratings e Avaliações - Exibe nota de avaliação e votos do TMDB
- Categorização por Gêneros - Filmes categorizados por gênero
- Tratamento de Erros - Feedback inteligente com ações de retry

---

## Requisitos do Sistema

- iOS 17.0 ou superior
- Xcode 15.0 ou superior
- Swift 5.5 ou superior
- TheMovieDB API Key (gratuita em themoviedb.org)

---

## Guia de Execução

### 1. Clonar o Repositório

```bash
git clone https://github.com/seu-usuario/moviedb-ios.git
cd moviedb-ios
```

### 2. Obter API Key

1. Acesse https://www.themoviedb.org/settings/api
2. Crie uma conta gratuita
3. Gere uma API Key (v3 auth)
4. Copie a chave gerada

### 3. Configurar a API Key no Projeto

Abra o arquivo `MovieDB/App/Configuration.swift` e substitua `SUA_API_KEY_AQUI` pela sua chave:

```swift
struct Configuration {
    static let apiKey = "SEU_API_KEY_AQUI"  // Cole sua chave aqui
    static let baseURL = "https://api.themoviedb.org/3"
    static let imageBaseURL = "https://image.tmdb.org/t/p/w500"
    static let requestTimeout: TimeInterval = 30
    static let defaultPageSize = 20
}
```

### 4. Abrir no Xcode

```bash
open MovieDB.xcodeproj
```

### 5. Executar a Aplicação

1. Selecione o simulador desejado
2. Pressione Cmd + R (ou clique em Play)
3. A aplicação será compilada e executada no simulador

### 6. Executar os Testes

```bash
# Executar todos os testes
Cmd + U

# Executar testes específicos
Cmd + U (com o arquivo de testes selecionado)
```

---

## Como Usar a Aplicação

### Tela Home (Tab Inicial)

1. Visualize filmes populares em layout grid
2. Role para baixo para carregar mais filmes (paginação infinita)
3. Use a barra de busca no topo para encontrar filmes específicos
4. Toque em um filme para visualizar seus detalhes completos
5. Clique no ícone de coração para adicionar/remover dos favoritos
6. Filtre filmes pela sua classificação (Rating)

### Tela de Detalhes do Filme

1. Visualize a imagem de backdrop do filme
2. Clique no botão de compartilhamento para compartilhar a imagem
3. Veja informações completas do filme:
   - Título e tagline
   - Rating (estrelas) e votos totais
   - Data de lançamento
   - Duração do filme
   - Status de produção
   - Gêneros categorizados
   - Sinopse completa
5. Clique no ícone de coração para adicionar aos favoritos

### Tela de Favoritos (Aba Secundária)

1. Visualize todos os filmes salvos como favoritos
2. Clique em um filme para ver seus detalhes novamente
3. A lista persiste mesmo após fechar a aplicação (armazenada em Core Data)

---

## Arquitetura do Projeto

### Estrutura de Pastas

```
MovieDB/
├── App/
│   ├── MovieDBApp.swift                # Entry point da aplicação
│   └── Configuration.swift             # Configurações globais (API Key, URLs)
│
├── Domain/
│   ├── Models/
│   │   ├── Movie.swift                 # Modelo de Filme
│   │   ├── Genre.swift                 # Modelo de Gênero
│   │   └── APIResponse.swift           # Modelo de resposta da API
│   ├── Protocols/
│   │   ├── MovieRepositoryProtocol     # Interface para repositório de filmes
│   │   ├── FavoritesRepositoryProtocol # Interface para repositório de favoritos
│   │   └── LoggerProtocol              # Interface para logging
│   └── Errors/
│       └── NetworkError.swift          # Erros de rede customizados
│
├── Data/
│   ├── Repositories/
│   │   ├── MovieRepository.swift       # Implementação do repositório de filmes
│   │   ├── FavoritesRepository.swift   # Implementação do repositório de favoritos
│   │   └── MockMovieRepository.swift   # Mock para testes
│   ├── Services/
│   │   ├── ShareService.swift          # Serviço de compartilhamento de imagens
│   │   ├── APIService.swift            # Serviço de requisições HTTP
│   │   ├── APIEndpoint.swift           # Definição dos endpoints da API
│   │   └── CoreDataStack.swift         # Configuração do Core Data
│   ├── DTOs/
│   │   └── MovieAPIResponse.swift      # Data Transfer Objects da API
│   └── CoreData/
│       ├── TheMovieDB.xcdatamodeld     # Esquema do Core Data
│       └── MovieEntity+Extensions      # Extensões da entidade Core Data
│
├── Application/
│   └── ViewModels/
│       ├── HomeViewModel.swift         # ViewModel da tela Home
│       ├── MovieDetailViewModel.swift  # ViewModel de detalhes do filme
│       └── FavoritesViewModel.swift    # ViewModel de favoritos
│
├── Presentation/
│   ├── Views/
│   │   ├── HomeView.swift              # Tela principal com busca e grid
│   │   ├── MovieDetailView.swift       # Tela de detalhes do filme
│   │   ├── FavoritesView.swift         # Tela de filmes favoritos
│   │   └── AppView.swift               # Tab bar principal
│   ├── Components/
│   │   ├── MovieListCell.swift         # Célula de filme na lista
│   │   ├── LoadingView.swift           # View de carregamento
│   │   ├── ErrorView.swift             # View de erro com retry
│   │   ├── EmptyStateView.swift        # View de estado vazio
│   │   ├── CachedAsyncImage.swift      # AsyncImage com cache
│   │   └── SearchBar.swift             # Barra de busca customizada
│   └── Modifiers/
│       └── CustomModifiers.swift       # Modificadores reutilizáveis
│
├── Utilities/
│   ├── Logger.swift                    # Sistema de logging
│   ├── Formatters.swift                # Formatadores de dados
│   └── Extensions.swift                # Extensões úteis
│
└── Tests/
    ├── HomeViewModelTests.swift        # Testes da Home
    ├── MovieDetailViewModelTests.swift # Testes de detalhes
    ├── FavoritesViewModelTests.swift   # Testes de favoritos
    ├── MovieRepositoryTests.swift      # Testes do repositório
    ├── FavoritesRepositoryTests.swift  # Testes de persistência
    ├── ShareServiceTests.swift         # Testes de compartilhamento
    ├── NetworkErrorTests.swift         # Testes de erros
    └── Mocks/
        ├── MockMovieRepository.swift
        ├── MockFavoritesRepository.swift
        └── MockLogger.swift
```

### Padrão de Arquitetura

O projeto implementa MVVM (Model-View-ViewModel) com Clean Architecture em 4 camadas:

1. Domain Layer - Modelos, Protocolos e Erros (sem dependências)
2. Data Layer - Repositórios, Serviços e Persistência
3. Application Layer - ViewModels que orquestram a lógica
4. Presentation Layer - Views e Components (apenas UI)

---

## Descrição Detalhada dos Métodos Principais

### HomeViewModel.loadPopularMovies()

Carrega filmes populares da API TMDB com suporte a paginação infinita.

```swift
func loadPopularMovies(page: Int = 1)
```

Parâmetros:
- `page: Int` - Número da página de filmes a carregar (padrão: 1)

Comportamento:
1. Define `isLoading = true` para mostrar indicador de carregamento
2. Faz requisição à API TMDB para buscar filmes populares
3. Se é primeira página - substitui lista existente
4. Se é página seguinte - adiciona à lista existente (paginação infinita)
5. Define `isLoading = false` ao completar
6. Se erro - captura exceção e popula `error` property

Estados afetados:
- `movies: [Movie]` - Lista de filmes populares retornados
- `isLoading: Bool` - Indica se está carregando
- `error: ErrorMessage?` - Mensagem de erro (se houver)
- `currentPage: Int` - Página atual para paginação

Lançamentos:
- `NetworkError.networkUnavailable` - Sem conexão com internet
- `NetworkError.timedOut` - Timeout na requisição
- `NetworkError.serverError` - Erro 5xx do servidor
- `NetworkError.decodingError` - Erro ao decodificar resposta JSON

Exemplo de uso:
```swift
await viewModel.loadPopularMovies()        // Primeira página
await viewModel.loadPopularMovies(page: 2) // Segunda página (paginação)
```

### HomeViewModel.searchMovies(query:)

Realiza busca de filmes com debounce automático.

```swift
func searchMovies(query: String)
```

Parâmetros:
- `query: String` - Termo de busca digitado pelo usuário

Comportamento:
1. Se query está vazio - recarrega filmes populares
2. Se query tem texto - aguarda 0.5 segundos (debounce)
3. Após debounce - faz requisição de busca
4. Atualiza lista de filmes na tela

Estados afetados:
- `movies: [Movie]` - Lista de filmes retornados
- `isLoading: Bool` - Indica carregamento
- `error: ErrorMessage?` - Erros da busca

### FavoritesRepository.saveFavorite(movie:)

Persiste um filme nos favoritos usando Core Data.

```swift
func saveFavorite(movie: Movie) async throws
```

Parâmetros:
- `movie: Movie` - Filme a ser adicionado aos favoritos

Processo:
1. Cria uma entidade MovieEntity no Core Data
2. Mapeia propriedades de Movie para MovieEntity
3. Salva o contexto do Core Data
4. Se erro - propaga exceção

Lançamentos:
- NSError (Core Data) - Se falhar ao salvar

---

## Premissas e Decisões Técnicas

### 1. API Cache com URLCache

**Premissa:** As imagens dos filmes já estão em cache quando o usuário tenta compartilhar.

**Razão:** A AsyncImage que exibe o backdrop automaticamente cacheia a imagem via URLCache. Reutilizar este cache evita uma segunda requisição de rede desnecessária, tornando o compartilhamento instantâneo.

**Alternativa considerada:** Baixar a imagem novamente via URLSession. Rejeitada por:
- Gasta dados do usuário
- Adiciona latência (1-2 segundos)
- Risco de falha de rede

### 2. Uso de @MainActor para Thread Safety

**Premissa:** Todas operações de UI devem acontecer na main thread.

**Razão:** SwiftUI obriga `@Published` properties a serem atualizadas na main thread. Usar `@MainActor` no ViewModel garante que todas as atualizações sejam thread-safe.

**Alternativa considerada:** Chamar `DispatchQueue.main.async` manualmente. Rejeitada por:
- Menos legível que `@MainActor`
- Mais propenso a erros
- Swift concurrency é o padrão moderno

### 3. ErrorMessage Reutilizável

**Premissa:** Erros de compartilhamento usam a mesma estrutura ErrorMessage do resto da app.

**Razão:** Maximiza reutilização de código. O ErrorView já implementado mostra erros de forma consistente.

**Benefício:** Mesmo visual e comportamento em toda a aplicação (botão "Try Again", layout, etc).

### 4. Debounce em Busca (0.5 segundos)

**Premissa:** Busca aguarda 0.5 segundos após o usuário parar de digitar.

**Razão:**
- Reduz requisições desnecessárias
- Melhora performance
- Padrão UX esperado

**Ajuste:** Pode ser modificado em `HomeViewModel` se necessário.

### 5. Paginação de Filmes

**Premissa:** Filmes são carregados em grupos de 20.

**Razão:**
- API do TMDB retorna 20 por padrão
- Reduz tamanho de resposta
- Melhora tempo de carregamento inicial
- Suporta scroll infinito

### 6. Core Data para Persistência de Favoritos

**Premissa:** Usar Core Data em vez de UserDefaults ou Realm.

**Razão:**
- Native do iOS (sem dependências externas)
- Ideal para dados estruturados (filmes com múltiplas propriedades)
- Suporta sync automático com CloudKit (futuro)
- Melhor performance para grandes volumes

**Alternativa considerada:** Realm. Rejeitada por adicionar dependência externa.

### 7. OSLog Injetável

**Premissa:** Logging via protocol em vez de classe static.

**Razão:**
- Permite mock em testes
- Desacoplamento
- Testabilidade

**Benefício:** Testes não produzem logs indesejados.

---

## Testes

### Estrutura de Testes

O projeto contém 113+ testes unitários organizados por feature:

- HomeViewModel: 18 testes
- MovieDetailViewModel: 8 testes  
- FavoritesViewModel: 7 testes
- MovieRepository: 9 testes
- FavoritesRepository: 10 testes
- ShareService: 8 testes
- NetworkError: 20 testes
- Models: 18+ testes

### Executar Testes

```bash
# Todos os testes
Cmd + U

# Testes de cobertura
Product > Scheme > Edit Scheme > Test > Options > Code Coverage
```

Cobertura esperada: 88%+

### Padrão AAA em Testes

Cada teste segue:

```swift
func testExample() async {
    // Arrange - Preparar dados
    let viewModel = HomeViewModel(repository: mockRepository)
    
    // Act - Executar ação
    await viewModel.loadMovies()
    
    // Assert - Verificar resultado
    XCTAssertEqual(viewModel.movies.count, 1)
    XCTAssertFalse(viewModel.isLoading)
}
```

---

## Dependências

### Internas (sem CocoaPods)

- SwiftUI - UI Framework
- Combine - Reactive programming
- Core Data - Persistência local
- URLSession - Requisições HTTP
- OSLog - Logging

### Não há dependências externas

O projeto foi desenvolvido com apenas frameworks nativos do iOS.

---

## Performance e Otimizações

### Image Caching

- AsyncImage + URLCache para imagens da API
- Cache automático via URLSession
- Evita re-download em navegação

### Lazy Loading

- LazyVStack em listas
- Carregamento incremental de filmes
- Pagination infinita

### Search Debouncing

- Aguarda 0.5s após digitação
- Reduz requisições desnecessárias
- Melhor UX e performance

### Decodificação Assíncrona

- JSONDecoder em thread background
- Não bloqueia UI durante parsing

---

## Licença

Desenvolvido para fins educacionais.

---

## Desenvolvedor

Eliane Regina Nicácio Mendes

---

## Recursos Adicionais

### Documentação Oficial

- SwiftUI Documentation: https://developer.apple.com/xcode/swiftui/
- TheMovieDB API: https://www.themoviedb.org/settings/api
- Swift Concurrency: https://swift.org/concurrency/
- Core Data Guide: https://developer.apple.com/documentation/coredata

### Padrões Implementados

- MVVM (Model-View-ViewModel)
- Clean Architecture
- Dependency Injection
- Protocol-Oriented Programming
- Repository Pattern
