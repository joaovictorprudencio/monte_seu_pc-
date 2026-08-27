# monte_seu_pc — Arquitetura do Wizard de Montagem de PC

## Contexto do projeto

- **Stack**: Ruby on Rails 8.1.2, PostgreSQL (Docker), Hotwire/Stimulus, RSpec 8.0 + FactoryBot.
- **Autor**: desenvolvedor Java/Spring Boot aprendendo Rails, mapeando padrões conhecidos (Service Layer, enums, DI) para os equivalentes idiomáticos em Rails.
- **Objetivo do projeto**: aplicação de montagem/assembly de PC, com fluxo tipo wizard multi-etapas (escolher CPU → Motherboard → RAM → Case), validando compatibilidade entre os componentes a cada passo.

---

## Fluxo do wizard (visão geral)

```
1. Usuário abre a tela de seleção de componente (GET /components/select)
   → view com filtros/scopes mostrando os componentes da categoria atual (ex: CPU)

2. Usuário escolhe o componente e clica em "Avançar"
   → [PRIMEIRA TELA] abre um modal pedindo nome da montagem (e outros metadados)
   → ao confirmar o modal, dispara a criação do Computer + primeira peça

3. Controller (ComputerAssembliesController#create) chama:
   Computers::CreateComputerService
     → cria o Computer (com nome vindo do modal)
     → acopla a primeira peça (CPU) via computer_parts
     → seta total_price = component.price (é a primeira peça, sem soma ainda)
     → muda status para :building
     → retorna o computer criado

4. Controller faz redirect_to para a próxima tela de seleção
   (GET /components/select), agora filtrando pela PRÓXIMA categoria
   (ex: motherboard), passando computer_id via query string

5. [DEMAIS TELAS] usuário escolhe a próxima peça e clica em "Avançar"
   → NÃO abre mais modal (só a primeira tela abre)
   → dispara Computers::AddPartToComputerService (ainda a ser implementado)
     → adiciona a peça ao computer existente
     → recalcula total_price = soma de todas as peças (computer_parts.sum)
     → salva (save! dispara o CompatibilityValidator automaticamente)
   → Controller faz redirect_to para a próxima categoria, ou para a
     tela de resumo/finalização se todas as peças já foram escolhidas
```

---

## Decisões de arquitetura já tomadas

### 1. Dois Services distintos (não um só com if/else)

- **`Computers::CreateComputerService`**: só para o PRIMEIRO passo (cria o `Computer` + acopla a primeira peça, tipicamente CPU). Recebe `component:` e `user:` (e, após a decisão do modal, também o nome da montagem).
- **`Computers::AddPartToComputerService`** *(a implementar)*: para os passos SEGUINTES (adicionar peça a um `Computer` já existente). Recebe `component:` e `computer:`.

Motivo: evitar que um único Service tenha lógica condicional ("se é a primeira peça, faz X; senão, faz Y") — separar em dois Services com responsabilidade única segue o princípio de responsabilidade única (SRP) e evita "code smell" de branching por estado.

### 2. Padrão Service Object

```ruby
module Computers
  class CreateComputerService
    def initialize(component:, user:)
      @component = component
      @user = user
    end

    def call
      computer = user.computers.create!(status: :building)
      computer.computer_parts.create!(component: component)
      computer.total_price = component.price
      computer.save!
      computer
    end

    private

    attr_reader :component, :user
  end
end
```

- Convenção: `initialize` recebe as dependências via **keyword arguments**; método público único é `.call`; lógica interna fica em métodos `private`.
- `.call` sempre retorna o objeto principal (`computer`) — nunca deixa o retorno "vazar" de um método interno tipo `building!` (que retornaria só `true`/`false`).
- Regra mental importante: dentro do Service, `self` é o Service, não o model. Por isso sempre usar `computer.algumacoisa`, nunca `id` ou `self.id` soltos esperando que se refiram ao `Computer`.

### 3. `CompatibilityValidator`

- Implementado como PORO (classe Ruby simples), chamado via `validate :components_compatibility` no model `Computer`.
- Verifica compatibilidade de socket, arquitetura, tipo de RAM, slots e form factor entre MOTHERBOARD, CPU, RAM e CASE.
- É automaticamente disparado sempre que `computer.save!`/`computer.valid?` é chamado — os Services não precisam chamá-lo manualmente, só precisam garantir que o `save!` aconteça no momento certo (depois de todas as peças/atributos estarem setados em memória).

### 4. Cálculo de `total_price`

- **Na criação (primeira peça)**: atribuição direta, `computer.total_price = component.price` (não usa soma, pois é a primeira e única peça naquele momento).
- **Nos passos seguintes (adição de peça)**: recalcular a partir da fonte de verdade, não incrementar (`+=`), para evitar dessincronização:
  ```ruby
  computer.total_price = computer.computer_parts.sum { |cp| cp.component.price }
  ```

### 5. `next_component_type` (lógica de "qual é a próxima peça")

```ruby
class Computer < ApplicationRecord
  COMPONENT_ORDER = %w[cpu motherboard ram case].freeze

  def next_component_type
    already_added = computer_parts.includes(:component).map { |cp| cp.component.category }
    COMPONENT_ORDER.find { |type| already_added.exclude?(type) }
  end
end
```

- Usado pelo Controller para decidir para qual categoria redirecionar depois de cada passo do wizard.

---

## Rotas e Controllers

```ruby
# config/routes.rb
get "components/select", to: "components#select_category", as: "select_category"
resources :computer_assemblies, only: [:create]   # passo 1 (criar computer + primeira peça)
resources :computer_parts, only: [:create]         # passos seguintes (adicionar peça)
```

- **`ComputerAssembliesController#create`**: chama `Computers::CreateComputerService`, trata `ActiveRecord::RecordInvalid`, faz `redirect_to select_category_path(category: computer.next_component_type, computer_id: computer.id)`.
- **`ComputerPartsController#create`** *(a implementar)*: chama `Computers::AddPartToComputerService`, mesmo padrão de redirect.
- Rails não separa "rotas de API" de "rotas de view" por padrão — a mesma rota responde HTML ou JSON dependendo de `respond_to`/formato pedido. Neste projeto, o fluxo é 100% Rails clássico (views ERB + Turbo/Hotwire), sem necessidade de JSON.
- `computer_id` trafega via query string entre as telas do wizard (alternativa possível: sessão, mas não adotada ainda).

---

## Front-end (Stimulus/Hotwire)

- Botão "Avançar" já usa um Stimulus Controller: `data-action="click->mounting-form#nextStep"`.
- Abordagem escolhida (idiomática Rails/Hotwire): o Stimulus Controller **não** faz `fetch` manual — ele popula um hidden field com o `component_id` selecionado e dispara `requestSubmit()` num `<form>` já existente na página (escondido ou estilizado). O Turbo intercepta o submit normalmente, segue o `redirect_to` do Controller automaticamente, sem reload completo da página.
- **Novidade combinada nesta conversa**: no PRIMEIRO passo do wizard, antes de disparar `requestSubmit()`, será aberto um **modal** pedindo o nome da montagem (e possíveis outros metadados). Só depois de confirmado o modal é que o form de criação (`ComputerAssembliesController#create`) é submetido, já incluindo esse nome como parâmetro adicional. Os passos seguintes (adicionar peça) NÃO abrem esse modal — vão direto pro submit do form de adição de peça.

Esboço do Stimulus Controller (`mounting_form_controller.js`) considerando o modal na primeira etapa:

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["componentInput", "hiddenComponentId", "form", "modal", "nameInput"]

  nextStep() {
    const selected = this.componentInputTargets.find(input => input.checked)
    if (!selected) {
      alert("Selecione um componente antes de avançar")
      return
    }

    this.hiddenComponentIdTarget.value = selected.value

    if (this.hasModalTarget) {
      // primeira etapa: abre modal pedindo nome da montagem antes de submeter
      this.modalTarget.classList.remove("d-none")
    } else {
      // demais etapas: submete direto
      this.formTarget.requestSubmit()
    }
  }

  confirmModal() {
    // chamado pelo botão de confirmação dentro do modal
    this.formTarget.requestSubmit()
  }
}
```

---

## Pendências / próximos passos

1. Implementar `Computers::AddPartToComputerService` (adicionar peça a um `Computer` existente, recalculando `total_price` e disparando o `CompatibilityValidator` via `save!`).
2. Implementar `ComputerPartsController#create`.
3. Adicionar o modal de nome da montagem na primeira tela do wizard (HTML + Stimulus), passando o nome como parâmetro extra para `CreateComputerService`.
4. Atualizar `Computers::CreateComputerService` para receber e persistir o nome da montagem vindo do modal (parâmetro adicional no `initialize`).
5. Decidir tela/lógica de finalização: quando `computer.next_component_type` retornar `nil` (todas as peças escolhidas), redirecionar para uma tela de resumo/confirmação em vez da tela de seleção de componente.
6. Expandir cobertura de testes RSpec para os dois Services e para o fluxo completo do Controller (incluindo o caso de `RecordInvalid` por incompatibilidade).
7. Tratamento de erro amigável no `rescue ActiveRecord::RecordInvalid` — hoje redireciona com mensagem simples via `alert:`, pode evoluir para um padrão `Result` object se a lógica de erro crescer.

---

## Princípios/aprendizados que devem ser mantidos ao continuar o projeto

- **Service Object**: sempre `initialize` com keyword args + método público único `.call` + métodos privados. `.call` sempre retorna o objeto de domínio relevante.
- **Um Service, uma responsabilidade** — não usar condicionais de estado (`if computer.new_record?`) dentro de um único Service; preferir dois Services distintos.
- **`self` dentro de um Service Object é o Service, não o Model** — sempre referenciar `computer.algumacoisa`, nunca atributos soltos esperando referência implícita ao model.
- **Persistência**: `.new` não salva, `.create!`/`.save!` salvam. Preferir versões com bang (`!`) em Services para que erros de validação estourem exception (tratável via `rescue`) em vez de falhar silenciosamente.
- **Recalcular vs. incrementar**: para valores derivados de uma coleção (`total_price`), preferir recalcular a partir da fonte de verdade (`sum`) a manter um acumulador incremental (`+=`), que pode dessincronizar.
- **Argumentos posicionais vs. keyword**: nunca misturar os dois estilos entre definição e chamada de um mesmo método; keyword é preferido para métodos com mais de 1 parâmetro.
- **Rails não separa rotas "de API" das "de view"** — a mesma rota responde diferente conforme `respond_to`/formato. Este projeto usa o modelo clássico full-stack (views ERB + Turbo), sem necessidade de JSON para navegação entre passos do wizard.