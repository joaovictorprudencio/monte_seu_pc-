---
name: clean-code
description: Use ao escrever ou revisar qualquer código, independente da linguagem ou framework. Aplica princípios de Clean Code — nomes, funções pequenas, SOLID, DRY, tratamento de erros e testes legíveis.
license: MIT
---

# Clean Code

Princípios gerais de código limpo, independentes de linguagem. Quando usado
junto de uma skill específica de framework (ex: rails-conventions), esta
skill cobre o "como escrever bem" e a outra cobre o "como fazer no Rails" —
elas se complementam.

## Nomes significativos

- Nomes devem responder: por que existe, o que faz, como é usado. Se
  precisa de um comentário do lado pra explicar, o nome está fraco.
- Evite abreviações obscuras (`usr`, `calc`, `tmp2`) — o custo de digitar
  um nome maior é menor que o custo de decifrar um nome ruim depois.
- Um nome por conceito: não use `get`, `fetch` e `retrieve` para a mesma
  ideia em lugares diferentes do código.
- Nomes de classes: substantivos (`Order`, `PaymentProcessor`). Nomes de
  métodos: verbos (`calculate_total`, `send_notification`).
- Variáveis booleanas como pergunta (`is_valid`, `has_permission`,
  `active?`).
- Evite ruído redundante (`account_data`, `the_account`, `account_info`
  para a mesma coisa que já é uma `Account`).

## Funções / Métodos

- **Pequenas.** Se não cabe numa tela sem rolar, provavelmente faz coisa
  demais.
- **Um nível de abstração por função.** Não misture "orquestrar o fluxo
  geral" com "detalhe de implementação de baixo nível" na mesma função.
- **Faça uma coisa só.** Se o nome da função tem "e" no meio
  (`valida_e_salva`), é sinal de que faz duas coisas — considere separar.
- **Poucos argumentos.** Zero a dois é o ideal; três já pede atenção;
  quatro ou mais quase sempre pede um objeto que agrupe os parâmetros
  relacionados.
- **Sem efeitos colaterais escondidos.** Se o nome diz `check_password`,
  a função não deveria também iniciar a sessão do usuário por baixo dos
  panos — isso é uma surpresa pra quem lê o nome e confia nele.
- Prefira retornar valores a alterar parâmetros recebidos por referência
  (side effects em argumentos de entrada confundem quem chama).

## Comentários

- O melhor comentário é o que você não precisou escrever porque o código
  já é claro.
- Comentário bom: explica o **porquê** de uma decisão não óbvia (uma
  regra de negócio estranha, um workaround de bug de biblioteca).
- Comentário ruim: repete o que o código já diz
  (`# incrementa o contador` acima de `counter += 1`).
- Código comentado (morto) não fica no repositório — o histórico do git
  já guarda isso.

## Formatação

- Consistência dentro do arquivo/projeto importa mais que a preferência
  pessoal — siga o padrão já estabelecido (linter/formatter do projeto).
- Funções relacionadas ficam próximas umas das outras no arquivo.
- Ordem de leitura de cima pra baixo: conceitos de alto nível primeiro,
  detalhes de implementação depois.

## Tratamento de erros

- Erros e exceções em vez de códigos de retorno mágicos (`-1`, `null`
  para "não encontrado") sempre que a linguagem suportar bem esse padrão.
- Não retorne `nil`/`null` quando dá pra evitar — prefira objeto nulo,
  coleção vazia, ou lançar uma exceção explícita. Retornar `nil` empurra
  a responsabilidade do tratamento pra quem chama, silenciosamente.
- Trate o erro no nível certo: não faça `rescue`/`catch` genérico logo
  onde o erro acontece só pra "engolir" o problema — capture onde você
  tem contexto suficiente pra decidir o que fazer.
- Mensagens de erro específicas o bastante pra debugar sem precisar
  reproduzir o cenário do zero.

## Objetos e Estruturas de Dados

- **Lei de Demeter**: fale só com "vizinhos diretos". Evite correntes
  como `pedido.cliente.endereco.cidade.nome` — se você precisa disso,
  provavelmente falta um método no objeto intermediário que devolva o
  que você precisa.
- **Encapsulamento real**: não exponha todos os atributos internos só
  porque "pode ser útil algum dia". Exponha comportamento, não estado.
- Objetos escondem dados e expõem comportamento; estruturas de dados
  expõem dados e não têm comportamento significativo. Não misture os
  dois estilos na mesma classe sem motivo.

## Classes

- **Responsabilidade única (SRP)**: uma classe, uma razão pra mudar. Se
  você descreve a classe com "e" (`ValidaEEnviaEmail`), separe.
- **Coesão alta**: os métodos de uma classe devem usar a maioria dos
  atributos da própria classe. Método que não usa quase nada do estado
  da classe é candidato a virar outra classe (ou função livre).
- **Classes pequenas**: mesma lógica das funções — se a classe faz
  muita coisa, quebre em colaboradores menores.

## SOLID

- **S — Single Responsibility**: uma classe, uma responsabilidade, um
  motivo para mudar.
- **O — Open/Closed**: aberto para extensão, fechado para modificação —
  novo comportamento deveria ser possível adicionando código novo, não
  reescrevendo o que já funciona e está testado.
- **L — Liskov Substitution**: uma subclasse deve poder substituir a
  classe-mãe em qualquer lugar sem quebrar o comportamento esperado por
  quem usa a classe-mãe.
- **I — Interface Segregation**: várias interfaces pequenas e
  específicas são melhores que uma interface grande genérica que força
  implementações a lidar com métodos que não usam.
- **D — Dependency Inversion**: dependa de abstrações, não de
  implementações concretas — módulos de alto nível não deveriam
  conhecer detalhes de baixo nível diretamente.

## DRY (Don't Repeat Yourself)

- Duplicação de **conhecimento/regra de negócio** é o problema real —
  duplicação acidental de sintaxe que representa coisas diferentes não
  é DRY quebrado, é coincidência.
- Antes de extrair uma abstração compartilhada, confirme que as duas
  ocorrências realmente representam a mesma regra e vão evoluir juntas —
  DRY prematuro cria acoplamento errado entre coisas que só pareciam
  iguais.

## Boy Scout Rule

- Deixe o código um pouco melhor do que encontrou. Não precisa ser uma
  refatoração grande — renomear uma variável confusa ou quebrar uma
  função longa já conta.
- Não aproveite uma tarefa pequena pra fazer uma reforma geral não
  relacionada — mudanças grandes fora de escopo dificultam review e
  aumentam risco.

## Testes

- **FIRST**: Fast (rápidos), Independent (não dependem de ordem ou uns
  dos outros), Repeatable (mesmo resultado em qualquer ambiente),
  Self-validating (passa/falha sem inspeção manual), Timely (escritos
  perto do código que testam, não meses depois).
- Um conceito testado por teste — se o nome do teste tem "e" no meio,
  provavelmente testa duas coisas e devia ser dois testes.
- Nome do teste descreve o comportamento esperado, não a implementação
  (`retorna_erro_quando_saldo_insuficiente`, não `testa_metodo_debitar`).
- Teste é código de produção também: aplique os mesmos princípios de
  nomes claros e funções pequenas nos testes.

## Code smells comuns a sinalizar

- Função/método longo demais para o que faz.
- Classe que sabe demais sobre o funcionamento interno de outra
  (feature envy).
- Muitos parâmetros ou um parâmetro booleano controlando comportamento
  totalmente diferente (`process(order, true)` — o que `true` significa?).
- Números ou strings mágicas sem nome (`if status == 3`) em vez de uma
  constante ou enum nomeado.
- Código morto (comentado ou inalcançável).
- Nomes genéricos demais (`data`, `info`, `manager`, `helper`) que não
  dizem o que a coisa realmente é.

## Ao revisar ou gerar código

- Aponte funções/métodos que fazem mais de uma coisa.
- Aponte nomes que exigem um comentário do lado para fazer sentido.
- Sugira extrair uma abstração só quando a duplicação for de regra de
  negócio real, não de sintaxe coincidente.
- Prefira sempre a solução mais simples que resolve o problema — não
  adicione abstração ou flexibilidade que ninguém pediu ainda (YAGNI).
