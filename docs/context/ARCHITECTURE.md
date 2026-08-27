# ARCHITECTURE.md

## Visão Geral

**Monte Seu PC** é uma aplicação Ruby on Rails 8.1 para montagem de computadores personalizados (e-commerce de componentes). O sistema permite navegar por componentes de PC, filtrar por categoria/marca/preço, verificar compatibilidade entre peças e montar computadores completos.

---

## Stack Utilizada

| Camada | Tecnologia | Versão |
|--------|------------|--------|
| Framework | Ruby on Rails | 8.1.2 |
| Linguagem | Ruby | 3.3+ |
| Banco de Dados | PostgreSQL | 1.1+ (gem pg) |
| Web Server | Puma | 5.0+ |
| Frontend | Hotwire (Turbo + Stimulus) | - |
| CSS | dartsass-rails + Bootstrap 5.3.3 | - |
| JS Bundling | Importmap | - |
| JSON API | Jbuilder | - |
| Testes | RSpec + FactoryBot + Capybara | - |
| Lint | RuboCop (rails-omakase) + Brakeman | - |
| Deploy | Kamal + Docker | - |
| Jobs/Queue | Solid Queue | - |
| Cache | Solid Cache | - |
| Cable | Solid Cable | - |
| Storage | Active Storage | - |
| Imagens | image_processing | 1.2 |

---

## Estrutura de Diretórios

```
app/
├── assets/
│   ├── images/          # Imagens estáticas (placa_mae.png, pc.png, placa.png)
│   └── stylesheets/
│       └── application.css
├── controllers/
│   ├── application_controller.rb
│   ├── components_controller.rb    # CRUD + filtros + seleção por categoria
│   ├── computers_controller.rb     # CRUD básico
│   ├── home_controller.rb
│   └── api/
│       └── create_mouting.rb       # API para montagem (vazio/placeholder)
├── helpers/
│   ├── application_helper.rb
│   ├── components_helper.rb        # Vazio
│   └── computers_helper.rb         # Vazio
├── javascript/
│   ├── application.js
│   └── controllers/
│       ├── index.js
│       ├── application.js
│       ├── hello_controller.js
│       ├── mask_controller.js      # Máscara de preço (IMask)
│       ├── search_form_controller.js  # Debounce de busca
│       └── select_component_controller.js  # Seleção de componente via Turbo Stream
├── jobs/
│   └── application_job.rb          # Vazio (ActiveJob base)
├── mailers/
│   └── application_mailer.rb
├── models/
│   ├── application_record.rb
│   ├── component.rb                # Modelo principal de componente
│   ├── computer.rb                 # Modelo de computador montado
│   ├── computer_part.rb            # Join table (Computer <-> Component)
│   └── concerns/
├── validators/
│   └── compatibility_validator.rb  # Validador custom de compatibilidade
└── views/
    ├── components/
    │   ├── index.html.erb
    │   ├── new.html.erb
    │   ├── edit.html.erb
    │   ├── show.html.erb
    │   ├── select_category.html.erb  # Página principal de montagem (stepper + grid + preview)
    │   ├── _form.html.erb
    │   ├── _component.html.erb
    │   ├── _component_card.html.erb  # Card com Turbo Frame + Stimulus
    │   ├── _stepper.html.erb         # Stepper visual de montagem
    │   ├── index.json.jbuilder
    │   ├── show.json.jbuilder
    │   └── _component.json.jbuilder
    ├── computers/
    │   ├── index.html.erb
    │   ├── new.html.erb
    │   ├── edit.html.erb
    │   ├── show.html.erb
    │   ├── _form.html.erb
    │   ├── _computer.html.erb
    │   ├── index.json.jbuilder
    │   ├── show.json.jbuilder
    │   └── _computer.json.jbuilder
    ├── home/
    │   └── index.html.erb
    ├── layouts/
    │   ├── application.html.erb
    │   ├── mailer.html.erb
    │   └── mailer.text.erb
    └── pwa/
        ├── manifest.json.erb
        └── service-worker.js
```

---

## Camadas da Aplicação

### 1. **Models (Active Record)**

| Modelo | Responsabilidade | Validações/Callbacks |
|--------|------------------|---------------------|
| `Component` | Representa peça de hardware (CPU, GPU, RAM, etc.) | Scopes de filtro; `has_one_attached :image` (Active Storage) |
| `Computer` | Computador montado pelo usuário | `validates :components, compatibility: true` (validator custom), `validates :total_price, :name`; `normalizes :total_price` |
| `ComputerPart` | Tabela de junção (N:N) | `belongs_to :computer, :component` |

**Scopes principais (Component):**
- `by_category(category)` - filtra por categoria
- `by_brand(brand)` - filtra por marca
- `by_price_range(min, max)` - range de preço
- `cheaper_first` / `expensive_first` / `by_name` - ordenação

**Métodos Computer:**
- `create_mounting(components_list)` - cria associações e soma preço
- `calculate_total_price(price)` - **BUG**: usa `update(total_price + price)` sem recalcular corretamente
- `change_part(old, new)` - **BUG**: variáveis `component`/`new_componente` typo; usa `self.price` inexistente
- `save_hash(component)` - serializa specs por categoria em JSON

### 2. **Controllers**

| Controller | Actions | Observações |
|------------|---------|-------------|
| `ComponentsController` | CRUD + `index`, `select_category`, `cpus`, `gpus`, `rams`, `motherboards`, `cases`, `sources`, `storages` | 7 actions dedicadas por categoria (duplicação); usa `kaminari` para paginação; responde `turbo_stream` em `select_category` |
| `ComputersController` | CRUD padrão | API namespace `/api/computers` |
| `HomeController` | `index` | Root path |

### 3. **Views / Frontend (Hotwire + Stimulus)**

- **Turbo Frames**: `components-list`, `component-preview` para navegação sem reload
- **Turbo Streams**: `select_category` atualiza preview do componente selecionado
- **Stimulus Controllers:**
  - `search-form`: debounce (500ms) no submit do formulário de busca
  - `select-component`: seleciona card, adiciona classe `.selected`, atualiza hidden field, faz fetch Turbo Stream
  - `mask`: máscara de moeda brasileira (IMask.js via importmap)

**Fluxo de montagem (select_category):**
1. Usuário escolhe categoria (stepper no topo)
2. Grid de cards (2 colunas) carrega via Turbo Frame
3. Clica no card → `select-component` controller → Turbo Stream atualiza painel lateral (preview)
4. Botão "Avançar" → próximo step do stepper

### 4. **Validators**

| Validator | Responsabilidade |
|-----------|------------------|
| `CompatibilityValidator` | Valida compatibilidade CPU↔Motherboard (socket, architecture), RAM↔Motherboard (ram_type, ram_speed), Case↔Motherboard (form_factor). Usa `ActiveModel::EachValidator`. |

**Regras implementadas:**
- CPU socket == Motherboard socket
- CPU architecture == Motherboard architecture
- RAM ram_type == Motherboard ram_type
- RAM speed <= CPU ram_speed (lógica invertida no código - **BUG potencial**)
- Case form_factor == Motherboard form_factor

### 5. **Jobs / Helpers / Services**

- **Jobs**: Apenas `ApplicationJob` (vazio). Sem jobs customizados.
- **Helpers**: `ComponentsHelper`, `ComputersHelper` - ambos vazios.
- **Services**: Não existe camada de services. Lógica nos models/controllers.
- **Serializers**: JBuilder views (`index.json.jbuilder`, `show.json.jbuilder`).

---

## Fluxo de uma Requisição (Montagem de PC)

```
GET /components/select?category=CPU
  ↓
ComponentsController#select_category
  ├─ Component.by_category("CPU").by_brand(...).by_price_range(...).page(1).per(6)
  ├─ Render select_category.html.erb
  │   ├─ Stepper (partial _stepper.html.erb) - step atual: CPU
  │   ├─ Turbo Frame #components-list
  │   │   └─ Loop @components → _component_card.html.erb (Turbo Frame + Stimulus)
  │   └─ Turbo Frame #component-preview
  │       └─ Se @selected_component → render preview + botão "Avançar"
  │
  ▼
User clica card → select-component#select
  ├─ Fetch Turbo Stream para select_category_path(selected_id: id)
  │
  ▼
ComponentsController#select_category (turbo_stream)
  ├─ @selected_component = Component.find(params[:selected_id])
  ├─ Render turbo_stream.replace("component-preview", ...)
  │
  ▼
Preview atualizado → User clica "Avançar" → Próxima categoria
```

---

## Principais Módulos

| Módulo | Arquivo(s) | Descrição |
|--------|------------|-----------|
| Catálogo de Componentes | `ComponentsController#index`, `Component` scopes | Listagem paginada, filtros, ordenação |
| Seleção por Categoria | `ComponentsController#select_category` + views | Stepper + Grid + Preview (Turbo) |
| Montagem de Computador | `Computer#create_mounting`, `CompatibilityValidator` | Cria Computer + ComputerParts + valida compatibilidade |
| API Computadores | `Api::ComputersController` (namespace) | JSON CRUD via JBuilder |
| Upload Imagem | `Component.has_one_attached :image` | Active Storage |

---

## Padrões Arquiteturais Encontrados

| Padrão | Onde Aplicado |
|--------|---------------|
| **Active Record** | Models `Component`, `Computer`, `ComputerPart` |
| **Convention over Configuration** | Rails padrão (rotas, controllers, migrations) |
| **Fat Model, Skinny Controller** | Parcial - validações no model, mas lógica de montagem no model `Computer` |
| **Custom Validator** | `CompatibilityValidator` (ActiveModel::EachValidator) |
| **Turbo Frames + Streams** | `select_category` view para SPA-like experience |
| **Stimulus Controllers** | Comportamento JS desacoplado (search, select, mask) |
| **Scopes Encadeáveis** | `Component` scopes para query building fluente |
| **JSONB** | `computers.data` para armazenar specs flexíveis |

---

## Dependências Externas (Gemfile)

**Runtime:**
- `rails`, `propshaft`, `dartsass-rails`, `pg`, `puma`
- `importmap-rails`, `turbo-rails`, `stimulus-rails`, `jbuilder`
- `solid_cache`, `solid_queue`, `solid_cable`
- `bootsnap`, `kamal`, `thruster`, `image_processing`

**Development/Test:**
- `debug`, `bundler-audit`, `dotenv-rails`, `brakeman`, `rubocop-rails-omakase`
- `rspec-rails`, `factory_bot_rails`, `view_component`, `kaminari`
- `capybara`, `selenium-webdriver`

**JS (via Importmap):**
- `@hotwired/turbo-rails`, `@hotwired/stimulus`, `bootstrap@5.3.3`, `@popperjs/core`

---

## Convenções do Projeto

| Aspecto | Convenção |
|---------|-----------|
| **Naming** | Models singular (`Component`), Controllers plural (`ComponentsController`) |
| **Rotas** | RESTful padrão + `select_category` custom + namespace `/api` |
| **Scopes** | Prefixo `by_` para filtros, `cheaper_first`/`expensive_first` para ordenação |
| **Validações** | Custom validator para regras de negócio complexas |
| **Frontend** | Turbo Frames para partial updates, Stimulus para interação |
| **Pagination** | `kaminari` (`.page(params[:page]).per(N)`) |
| **Moeda** | `decimal(10,2)` + normalização string BR → float + IMask no frontend |
| **Imagens** | Active Storage (`has_one_attached :image`) |
| **Testes** | RSpec + FactoryBot (spec/models/computer_spec.rb) |

---

## Pontos Técnicos Importantes

### 1. **Compatibilidade de Hardware**
- Implementada via `CompatibilityValidator` no model `Computer`
- Valida: CPU↔Motherboard (socket, architecture), RAM↔Motherboard (ram_type, ram_speed), Case↔Motherboard (form_factor)
- **Problema**: Validação roda no `validate :components` - só funciona se `components` já estiver associado (has_many through). `Computer#create_mounting` cria associações *após* save, então validação pode não pegar tudo.

### 2. **Cálculo de Preço Total**
- `Computer#calculate_total_price(price)` faz `update(total_price + price)` - **BUG**: `total_price` pode ser nil na primeira chamada; soma acumulada pode duplicar se chamado múltiplas vezes.
- `normalizes :total_price` limpa string "R$ 1.234,56" → "1234.56"

### 3. **Dados Flexíveis (JSONB)**
- `computers.data` (jsonb, default: {}) armazena specs por categoria (CPU, GPU, RAM, etc.) via `save_hash`
- Não há schema fixo - flexível mas sem validação

### 4. **Duplicação de Código no Controller**
- 7 actions idênticas (`cpus`, `gpus`, `rams`, `motherboards`, `cases`, `sources`, `storages`) diferindo apenas na string da categoria
- Poderiam ser uma action genérica `category(:cpu)` ou route dinâmica

### 5. **Typos em Scopes e Métodos**
- `Component.cheapper_firts` → deveria ser `cheaper_first`
- `Component.expansive_firts` → deveria ser `expensive_first`
- `Computer#change_part`: variáveis `componente`/`new_componente` (português) vs `component`/`new_component` (inglês) misturados; usa `self.price` inexistente `self.price`

### 6. **N+1 Queries Potenciais**
- `CompatibilityValidator` faz `record.components.find_by(category: "X")` múltiplas vezes dentro do loop
- Views iteram `@components` sem `includes(:image_attachment)` para Active Storage

---

## Dívidas Técnicas Identificadas

| Item | Severidade | Descrição |
|------|------------|-----------|
| **Typos em scopes** | Baixa | `cheapper_firts`, `expansive_firts` |
| **Bugs em `Computer#change_part`** | Alta | Variáveis erradas, `self.price` não existe |
| **Bug em `calculate_total_price`** | Alta | Não trata nil, soma acumulativa incorreta |
| **Validação de compatibilidade incompleta** | Média | Não valida GPU↔PSU (wattage), RAM↔CPU (max speed), Storage slots |
| **Duplicação de 7 actions no controller** | Média | `cpus`, `gpus`, `rams`, etc. |
| **N+1 em validador e views** | Média | `find_by` em loop, Active Storage sem eager load |
| **`computer_id` no form de Component** | Baixa | Campo exposto no `_form.html.erb` mas não usado |
| **Category strings hardcoded** | Baixa | "CPU", "GPU", "MOTHERBOARD", "CASE", "SOURCE", "STORAGE", "RAM" espalhados |
| **API `create_mouting` vazia** | Baixa | `app/controllers/api/create_mouting.rb` vazio/placeholder |
| **Tabela `testes` no schema** | Baixa | Tabela órfã (migração residual) |
| **Sem testes de integração/controller** | Média | Apenas `spec/models/computer_spec.rb` |
| **Sem Service Objects** | Arquitetural | Lógica de montagem e preço no model `Computer` |
| **Scopes com `self` desnecessário** | Baixa | `scope :by_price_range -> { query = self; ... }` |

---

## Configurações Relevantes

**config/routes.rb:**
```ruby
root 'home#index'
get "components/select", to: "components#select_category"
resources :components
resources :computers
namespace :api { resources :computers }
```

**config/importmap.rb:** Bootstrap 5.3.3 + Popper via JSPM CDN

**config/database.yml:** PostgreSQL com env vars `DB_USER`, `DB_PASSWORD`

**config/puma.rb:** Padrão Rails 8 (workers/threads via env)

---

## Observações Finais

A aplicação é um **MVP funcional** de montador de PC com foco no frontend Hotwire. A arquitetura segue Rails conventions, mas apresenta:
- Lógica de negócio concentrada nos models (validações, montagem, preço)
- Duplicação significativa no controller de componentes
- Bugs conhecidos nos métodos de mutação de `Computer`
- Frontend moderno (Turbo + Stimulus) bem integrado
- Falta de camada de services, jobs, testes amplos