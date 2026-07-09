# Replication Package: Code Smells in Elixir

This repository contains the complementary data and scripts for the paper **"Detecting Code Smells in Elixir Using Metrics and Predicates for Functional Programming"**.

## Repository Structure

low_level_concerns/
├── rules/
│   ├── complex_branching.ex
│   └── complex_else_clauses_in_with.ex
├── metrics/
│   ├── ComplexBranching.csv
│   └── ComplexElseClausesInWith.csv
├── scripts/
│   └── threshold_extraction.py
├── requirements.txt
├── .gitignore
└── README.md

## Setup

The threshold computation script requires Python 3.10+. To set up the environment:

```bash
python -m venv venv
source venv/bin/activate  # on Windows: venv\Scripts\activate
pip install -r requirements.txt
```

## Benchmark Dataset

To define the metric thresholds (LOC, CC and CEC), we extracted data from 20 popular open-source Elixir project repositories hosted on GitHub. Below is the complete list of repositories used to compose the *benchmark*:

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

The file `rules/complex_branching.ex` contains the implementation of the *check* used to detect the **Complex Branching** code smell, using the module attributes `@loc_threshold` (33) and `@cc_threshold` (8) as thresholds. For the threshold definition step, both attributes were temporarily set to `1`, causing the check to traverse all functions of the analyzed projects and record the values of the **LOC (Lines of Code)** and **CC (Cyclomatic Complexity)** metrics for every function, regardless of whether it would be flagged as a code smell under the final threshold.

The values collected during this process are available in:

- `metrics/ComplexBranching.csv`

This file contains, for each analyzed function, the source file, the function name, and the extracted metric values, and was used as the basis for the statistical analysis that defined the thresholds for *Complex Branching*.

Similarly, the file `rules/complex_else_clauses_in_with.ex` contains the implementation of the *check* used to detect the **Complex Else Clauses in With** code smell, using the module attribute `@cec_threshold` (5) as threshold. For data collection, this attribute was likewise set to `1`, so the check recorded the value of the **CEC (Clause Else Count)** metric — defined as the number of clauses present in the `else` block of a `with` expression — for every occurrence, without filtering by threshold.

The collected values are available in:

- `metrics/ComplexElseClausesInWith.csv`

This file contains, for each analyzed `with ... else` expression, the source file, the corresponding function, and the **CEC** value, serving as the basis for defining the threshold adopted for the **Complex Else Clauses in With** code smell.

## Running the Credo Checks

The checks in `rules/` are custom Credo checks and require an Elixir project with Credo configured to reference them. The thresholds used for code smell detection are defined as module attributes in each check's source (`@loc_threshold`/`@cc_threshold` in `complex_branching.ex`, `@cec_threshold` in `complex_else_clauses_in_with.ex`), corresponding to the values reported in the paper.

1. Add [Credo](https://github.com/rrrene/credo) as a dependency in the target project's `mix.exs`.
2. Copy the desired check file (e.g. `complex_branching.ex`) into the project's `lib/` directory.
3. Reference the check in the project's `.credo.exs`, under the `checks` list:

```elixir
   checks: [
     {Credo.Check.Warning.ComplexBranching, []},
     {Credo.Check.Warning.ComplexElseClausesInWith, []}
   ]
```

4. Run:

```bash
   mix credo --strict
```

To reproduce the data collection step used for threshold derivation, set the corresponding module attribute(s) to `1` (e.g., `@loc_threshold 1` and `@cc_threshold 1` in `complex_branching.ex`, or `@cec_threshold 1` in `complex_else_clauses_in_with.ex`), causing the check to record metric values for every function instead of filtering by threshold.

## Threshold Computation

The metric thresholds reported in the paper were derived from the CSV files described above using the automatic distribution-cropping method proposed by Fontana et al. (2015).

The script `scripts/threshold_extraction.py` implements this method. It takes as input the CSV files in `metrics/` and outputs the exact threshold value derived for each metric (LOC, CC, and CEC), corresponding to the values reported in the paper.

To reproduce the threshold computation:

```bash
python scripts/threshold_extraction.py --input metrics/ComplexBranching.csv --metrics LOC CC --percentile 75
python scripts/threshold_extraction.py --input metrics/ComplexElseClausesInWith.csv --metrics CEC --percentile 75
```
