---
name: rails-conventions
description: Use ao escrever, revisar ou gerar código Ruby on Rails — models, controllers, views, rotas, migrations, queries e testes. Garante convenções idiomáticas do Rails e "Rails way" em vez de padrões importados de outras stacks.
license: MIT
---

# Rails Conventions

Diretrizes para escrever Rails idiomático: "convention over configuration",
Fat Model / Skinny Controller, e a estrutura MVC do jeito que o framework
espera. O objetivo é código que qualquer dev Rails reconhece de cara — não
reinventar padrões de outras linguagens dentro do Rails.

## Estrutura geral

- Siga a estrutura padrão de pastas do Rails (`app/models`, `app/controllers`,
  `app/views`, `app/services`, `app/jobs`) — não crie estruturas paralelas
  sem necessidade real.
- Um arquivo por classe, nome do arquivo em snake_case batendo com o nome
  da classe (`user_mailer.rb` → `UserMailer`).
- Módulos e namespaces refletem a estrutura de pastas
  (`app/services/computers/create_computer_service.rb` →
  `Computers::CreateComputerService`).

## Routing

- Prefira rotas RESTful com `resources`; evite `get`/`post` soltos quando
  uma ação padrão (index, show, create, update, destroy) resolve.
- Ações customizadas viram `member` (uma instância) ou `collection`
  (a coleção toda):

  ```ruby
  resources :computers do
    member do
      patch :select_category
    end
  end
  ```

- Rotas aninhadas só quando existe uma relação de posse clara (`has_many`)
  e no máximo um nível de profundidade. Se precisar de mais, use rotas
  shallow (`shallow: true`).
- Nomeie rotas customizadas com verbos claros, evite genéricos como
  `update2` ou `process`.

## Models

- **Validações** declarativas no topo da classe, antes de associations
  quando possível, para leitura rápida das regras.
- **Associations** com `dependent:` explícito (`:destroy`, `:nullify`,
  `:restrict_with_error`) — nunca deixe implícito o que acontece com
  registros filhos.
- **Scopes** nomeados em vez de queries soltas espalhadas por
  controllers/views:

  ```ruby
  scope :available, -> { where(active: true) }
  scope :by_category, ->(category) { where(category: category) }
  ```

- **Enums** para estados fixos e conhecidos em tempo de design
  (`status: { draft: 0, published: 1 }`), nunca strings mágicas
  espalhadas pelo código.
- **Callbacks** com cautela: só para efeitos colaterais que pertencem
  genuinamente ao ciclo de vida do model (normalizar um campo, gerar um
  slug). Lógica de negócio com múltiplos passos ou que dispara side
  effects externos (emails, jobs, chamadas a outros models) vai para um
  Service Object, não para um `after_save`.
- **Concerns** (`app/models/concerns`) para comportamento compartilhado
  entre models não relacionados por herança. Se dois models têm o mesmo
  concern mas por motivos diferentes, provavelmente é hora de repensar.
- **STI** (Single Table Inheritance) quando os subtipos compartilham
  quase todos os atributos e só variam em comportamento — não em quando
  os subtipos têm campos muito diferentes entre si (aí `jsonb` para specs
  variáveis ou uma tabela separada tende a servir melhor).

## Controllers — Skinny Controller

- Só as 7 ações RESTful por padrão. Se sentir necessidade de uma 8ª ação
  customizada com frequência, considere extrair um controller aninhado
  (ex: `Computers::CategorySelectionsController`).
- **Strong params** sempre, nunca `params.permit!` genérico:

  ```ruby
  def computer_params
    params.require(:computer).permit(:name, :budget, component_ids: [])
  end
  ```

- `before_action` para setup repetido (`set_computer`, `authenticate_user!`),
  nunca duplicando o mesmo `find` em várias actions.
- Controller **não decide regra de negócio** — ele recebe input, delega
  para o model ou um service, e decide o que renderizar/redirecionar com
  base no resultado:

  ```ruby
  def create
    result = Computers::CreateComputerService.call(computer_params)
    if result.success?
      redirect_to result.computer, notice: "Criado com sucesso"
    else
      render :new, status: :unprocessable_entity
    end
  end
  ```

- `rescue_from` no `ApplicationController` para erros recorrentes
  (`ActiveRecord::RecordNotFound` → 404), não `begin/rescue` repetido em
  cada action.

## Service Objects

Use quando a lógica:
- Envolve mais de um model, ou
- Tem múltiplos passos com possibilidade de falha em cada um, ou
- Dispara efeitos colaterais (envio de email, job em background, chamada
  externa)

Padrão simples e previsível:

```ruby
module Computers
  class CreateComputerService
    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @params = params
    end

    def call
      computer = Computer.new(@params)
      return failure(computer) unless computer.save

      success(computer)
    end

    private

    def success(computer) = OpenStruct.new(success?: true, computer: computer)
    def failure(computer) = OpenStruct.new(success?: false, computer: computer)
  end
end
```

## Views

- Partials (`_form.html.erb`, `_computer.html.erb`) para qualquer bloco
  reutilizado em mais de um lugar, ou que passa de ~20 linhas.
- Sem lógica de negócio em views. Lógica de apresentação simples
  (formatação, condicional de exibição) tudo bem; regra de negócio, não.
- Helpers (`app/helpers`) para lógica de apresentação reaproveitável —
  não vire "gambiarra" pra esconder lógica de negócio que devia estar no
  model.
- Turbo: `.turbo_stream.erb` só para updates parciais reais; página cheia
  continua `.html.erb`. Não force Turbo Stream onde um redirect simples
  resolve.

## Migrations

- Sempre reversíveis: prefira `change` quando o Rails consegue inferir o
  `down` automaticamente; use `up`/`down` explícitos quando não consegue
  (ex: mudança de tipo de coluna com cast).
- Índices em toda foreign key e em colunas usadas em `where`/`order` com
  frequência.
- `null: false` + `default:` explícitos quando fizer sentido para o
  domínio — não deixe campos obrigatórios aceitando `NULL` "por enquanto".
- Uma migration, uma responsabilidade. Não misture criação de tabela com
  alteração de outra tabela não relacionada.

## Queries e N+1

- `includes`/`preload`/`eager_load` sempre que for iterar sobre uma
  association em view ou serializer:

  ```ruby
  @computers = Computer.includes(:components).where(active: true)
  ```

- Use `bullet` gem (ou similar) em desenvolvimento para pegar N+1 antes
  de ir pra produção.
- Queries complexas de leitura viram um scope nomeado ou um Query Object
  dedicado — não um bloco de SQL cru espalhado no controller.

## Testes (RSpec)

- `FactoryBot` para setup de dados, nunca fixtures manuais criadas linha
  a linha dentro do teste.
- Um `describe`/`context` por comportamento, não por método técnico.
- Testes de model: validações, scopes, métodos de negócio.
- Request specs para o fluxo HTTP completo (o que costuma substituir
  controller specs no Rails moderno).
- System specs (Capybara) só para os fluxos críticos de UI ponta a ponta
  — são caros, não use pra tudo.

## Nomenclatura

- Métodos e variáveis: `snake_case`.
- Classes e módulos: `PascalCase`.
- Métodos que retornam boolean terminam em `?` (`active?`, `compatible?`).
- Métodos destrutivos/perigosos terminam em `!` (`save!`, `destroy!`).
- Nomes de tabelas no plural, nomes de models no singular
  (`computers` → `Computer`).

## Ao gerar ou revisar código

- Se aparecer lógica de negócio dentro de um controller ou view, aponte
  e sugira mover para model ou service.
- Se um método passar de ~10-15 linhas ou mexer em mais de um model,
  sugira extrair um Service Object.
- Prefira sempre o "Rails way" (convention over configuration) a um
  padrão importado de outra stack, a menos que exista uma razão concreta
  documentada no projeto para o desvio.
