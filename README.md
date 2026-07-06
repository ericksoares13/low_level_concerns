# Replication Package: Code Smells in Elixir

Este repositório contém os dados e scripts complementares para o artigo **"Detecting code smells in Elixir using metrics and predicates for functional programming"**.

## Benchmark Dataset

Para definir os limiares das métricas (LOC e CC), extraímos dados de 20 repositórios de projetos Elixir populares e de código aberto hospedados no GitHub. Abaixo está a lista completa dos repositórios utilizados para compor o *benchmark*:

1. [Absinthe](https://github.com/absinthe-graphql/absinthe)
2. [Analytics](https://github.com/plausible/analytics)
3. [Anoma](https://github.com/anoma/anoma)
4. [Asciinema Server](https://github.com/asciinema/asciinema-server)
5. [Ash](https://github.com/ash-project/ash)
6. [Ecto](https://github.com/elixir-ecto/ecto)
7. [Electric](https://github.com/electric-sql/electric)
8. [Firezone](https://github.com/firezone/firezone)
9. [Libcluster](https://github.com/bitwalker/libcluster)
10. [Nerves](https://github.com/nerves-project/nerves)
11. [Oban](https://github.com/sorentwo/oban)
12. [Phoenix](https://github.com/phoenixframework/phoenix)
13. [Phoenix LiveDashboard](https://github.com/phoenixframework/phoenix_live_dashboard)
14. [Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view)
15. [Pinchflat](https://github.com/kieraneglin/pinchflat)
16. [Quantum Core](https://github.com/quantum-elixir/quantum-core)
17. [Realtime](https://github.com/supabase/realtime)
18. [Supavisor](https://github.com/supabase/supavisor)
19. [Symphony](https://github.com/openai/symphony)
20. [Teslamate](https://github.com/adriankumpf/teslamate)

## Metodologia de Extração

As métricas utilizadas neste trabalho foram extraídas por meio de *checks* personalizados desenvolvidos sobre a ferramenta de análise estática [Credo](https://github.com/rrrene/credo).

O arquivo `rules/complex_branching.ex` contém a implementação do *check* utilizado para detectar o *code smell* **Complex Branching**. Para a etapa de definição dos limiares, foi utilizada uma versão desse mesmo *check*, porém sem a condição de validação dos limiares (*thresholds*). Nessa configuração, o *check* apenas percorre todas as funções dos projetos analisados e registra os valores das métricas **LOC (Lines of Code)** e **CC (Cyclomatic Complexity)**, independentemente de a função ser classificada como um *code smell*.

Os valores coletados durante esse processo estão disponíveis em:

- `metrics/ComplexBranching.csv`

Esse arquivo contém, para cada função analisada, o arquivo de origem, o nome da função e os valores das métricas extraídas, sendo utilizado como base para a análise estatística que definiu os limiares do *Complex Branching*.

De forma análoga, o arquivo `rules/complex_else_clauses_in_with.ex` contém a implementação do *check* utilizado para detectar o *code smell* **Complex Else Clauses in With**. Para a coleta dos dados, foi utilizada uma versão do mesmo *check* sem a validação do limiar, responsável apenas por registrar o valor da métrica **CEC (Clause Else Count)**, definida como o número de cláusulas presentes no bloco `else` de uma expressão `with`.

Os valores coletados estão disponíveis em:

- `metrics/ComplexElseClausesInWith.csv`

Esse arquivo contém, para cada expressão `with ... else` analisada, o arquivo de origem, a função correspondente e o valor de **CEC**, servindo como base para a definição do limiar adotado para o *code smell* **Complex Else Clauses in With**.
