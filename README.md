
# Monte Seu PC

Aplicação Ruby on Rails para gerenciar computadores e seus componentes. O projeto permite cadastrar configurações de computadores, adicionar componentes e acompanhar o valor total do sistema.

## Funcionalidades

- Cadastro de computadores com nome, descrição, tipo de uso e preço total
- Registro de componentes com categoria, marca, arquitetura, preço e demais atributos
- Associação entre computadores e componentes via `computer_parts`
- Estrutura pensada para montar e consultar PCs personalizados

## Modelo de Dados

```mermaid
classDiagram
    class Usuario {
        +id: bigint
        +nome: string
        +email: string
        +senha: string
        +created_at: datetime
        +updated_at: datetime
    }

    class Computador {
        +id: bigint
        +nome: string
        +descricao: text
        +total_price: decimal
        +type_of_use: string
        +created_at: datetime
        +updated_at: datetime
    }

    class Componente {
        +id: bigint
        +name: string
        +brand: string
        +architecture: string
        +category: string
        +form_factor: string
        +socket: string
        +ram_type: string
        +wattage: integer
        +price: decimal
        +slots: integer
        +max_gpu_length: integer
        +created_at: datetime
        +updated_at: datetime
    }

    class ComputerPart {
        +id: bigint
        +computer_id: bigint
        +component_id: bigint
        +created_at: datetime
        +updated_at: datetime
    }

    Computador "1" --> "*" ComputerPart : possui
    Componente "1" --> "*" ComputerPart : pertence a
```

## Tecnologias

- Ruby 3.x
- Rails 8.1
- PostgreSQL
- Hotwire / Turbo / Stimulus via importmap




