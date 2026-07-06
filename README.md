# Replication Package: Code Smells in Elixir

This repository contains the complementary data and scripts for the paper **"Detecting Code Smells in Elixir Using Metrics and Predicates for Functional Programming"**.

## Benchmark Dataset

To define the metric thresholds (LOC and CC), we extracted data from 20 popular open-source Elixir project repositories hosted on GitHub. Below is the complete list of repositories used to compose the *benchmark*:

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

## Extraction Methodology

The metrics used in this work were extracted through custom *checks* developed on top of the static analysis tool [Credo](https://github.com/rrrene/credo).

The file `rules/complex_branching.ex` contains the implementation of the *check* used to detect the **Complex Branching** code smell. For the threshold definition step, a version of this same *check* was used, but without the threshold validation condition. In this configuration, the *check* simply traverses all functions of the analyzed projects and records the values of the **LOC (Lines of Code)** and **CC (Cyclomatic Complexity)** metrics, regardless of whether the function is classified as a code smell.

The values collected during this process are available in:

- `metrics/ComplexBranching.csv`

This file contains, for each analyzed function, the source file, the function name, and the extracted metric values, and was used as the basis for the statistical analysis that defined the thresholds for *Complex Branching*.

Similarly, the file `rules/complex_else_clauses_in_with.ex` contains the implementation of the *check* used to detect the **Complex Else Clauses in With** code smell. For data collection, a version of the same *check* without the threshold validation was used, responsible solely for recording the value of the **CEC (Clause Else Count)** metric, defined as the number of clauses present in the `else` block of a `with` expression.

The collected values are available in:

- `metrics/ComplexElseClausesInWith.csv`

This file contains, for each analyzed `with ... else` expression, the source file, the corresponding function, and the **CEC** value, serving as the basis for defining the threshold adopted for the **Complex Else Clauses in With** code smell.
