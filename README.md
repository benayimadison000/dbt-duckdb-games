Welcome to your new dbt project!

### Using the starter project

Try running the following commands:
- dbt run
- dbt test


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices

# dbt + DuckDB Games Analytics Project

A local data engineering project built with dbt Core and DuckDB, implementing a full analytics pipeline over a 50,000-row video games dataset. The project follows the staging, intermediate, and marts layering pattern with incremental loading, SCD Type 2 snapshots, reusable macros, automated data quality tests, and version control.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Data Architecture](#data-architecture)
- [Models](#models)
- [Macros](#macros)
- [Snapshots](#snapshots)
- [Data Quality Tests](#data-quality-tests)
- [Getting Started](#getting-started)
- [Daily Workflow](#daily-workflow)
- [Key Commands Reference](#key-commands-reference)

---

## Project Overview

This project transforms raw video games CSV data into a set of business-ready analytical tables using dbt Core running on a local DuckDB database. It demonstrates the core patterns used in production data engineering pipelines:

- Raw data ingestion via dbt seeds
- A three-layer transformation architecture (staging, intermediate, marts)
- Incremental loading to process only new records on each run
- Historical change tracking using SCD Type 2 snapshots
- Reusable SQL logic via Jinja macros
- Automated data quality testing
- A date spine for gap-free trend reporting

The dataset covers 50,000 video game records including sales figures, critic and user scores, platform information, publisher details, and game features such as DLC, microtransactions, and multiplayer support.

---

## Technology Stack

| Tool | Version | Purpose |
|---|---|---|
| dbt Core | 1.11.11 | Transformation framework |
| dbt-duckdb adapter | 1.10.1 | DuckDB connection |
| DuckDB | via adapter | Local analytical database |
| dbt-utils | 1.3.3 | Utility macros (surrogate keys, date spine) |
| Python | 3.12.9 | Runtime environment |
| Git | 2.53.0 | Version control |

---

## Project Structure

```
my_project_1/
├── seeds/
│   ├── games.csv                          # 50,000 game records
│   ├── genre_summary.csv                  # Genre-level aggregates
│   ├── platform_summary.csv               # Platform-level aggregates
│   ├── publisher_summary.csv              # Publisher-level aggregates
│   └── yearly_trends.csv                  # Year-level trend data
│
├── models/
│   ├── staging/
│   │   ├── stg_games.sql
│   │   ├── stg_genre_summary.sql
│   │   ├── stg_platform_summary.sql
│   │   ├── stg_publisher_summary.sql
│   │   ├── stg_yearly_trends.sql
│   │   └── schema.yml
│   │
│   ├── intermediate/
│   │   ├── int_games_enriched.sql
│   │   └── int_date_spine.sql
│   │
│   └── marts/
│       ├── mart_game_performance.sql      # Incremental model
│       ├── mart_genre_analysis.sql
│       ├── mart_publisher_rankings.sql
│       ├── mart_yearly_trends.sql
│       └── schema.yml
│
├── snapshots/
│   └── snap_publishers.sql                # SCD Type 2 publisher history
│
├── macros/
│   ├── sales_tier.sql
│   ├── critic_tier.sql
│   └── pct_true.sql
│
├── packages.yml                           # dbt-utils dependency
└── dbt_project.yml                        # Project configuration
```

---

## Data Architecture

Data flows through three layers before reaching the marts:

```
Source CSVs (seeds)
      |
      v
Staging Layer          — Clean, rename, cast types. One model per source table.
      |
      v
Intermediate Layer     — Join and enrich staging models. Business logic starts here.
      |
      v
Marts Layer            — Final business-ready tables consumed by analysts and BI tools.
```

### Schema Layout in DuckDB

| Schema | Contents |
|---|---|
| `main_seeds` | Raw CSV data loaded by dbt seed |
| `main_staging` | Cleaned and typed views |
| `main_intermediate` | Joined and enriched views |
| `main_marts` | Final analytical tables |
| `snapshots` | Historical SCD Type 2 records |

---

## Models

### Staging

Staging models are views that sit directly on top of raw seed data. They rename columns to consistent standards, cast types, and filter out null primary keys. No business logic is applied at this layer.

| Model | Source | Description |
|---|---|---|
| `stg_games` | `games.csv` | 50,000 game records with surrogate key, typed columns, and boolean feature flags |
| `stg_genre_summary` | `genre_summary.csv` | Genre-level metrics including avg sales, metacritic scores, and feature rates |
| `stg_platform_summary` | `platform_summary.csv` | Platform metrics including maker, type, and top genre |
| `stg_publisher_summary` | `publisher_summary.csv` | Publisher metrics including tier, region, revenue, and GOTY wins |
| `stg_yearly_trends` | `yearly_trends.csv` | Year-level release counts, sales, and feature adoption rates |

### Intermediate

| Model | Materialization | Description |
|---|---|---|
| `int_games_enriched` | View | Joins all five staging models into one enriched game record per row. Adds genre, platform, and publisher context onto each game. |
| `int_date_spine` | Table | Generates one row per year from 1980 to 2029 using `dbt_utils.date_spine`. Used to ensure no years are missing in trend reports. Includes decade labels. |

### Marts

| Model | Materialization | Description |
|---|---|---|
| `mart_game_performance` | Incremental | One row per game. Includes sales performance, score metrics, comparison to genre averages, feature flags, and derived `sales_tier` and `critic_tier` columns. |
| `mart_genre_analysis` | Table | One row per genre. Aggregates total games, sales, revenue, scores, pricing, completion times, and feature adoption rates. Includes a `genre_sales_tier` classification. |
| `mart_publisher_rankings` | Table | One row per publisher. Aggregates sales, revenue, quality scores, GOTY awards, monetisation strategy, and regional performance. Includes `sales_rank` and `sales_rank_within_tier` window function columns. |
| `mart_yearly_trends` | Table | One row per year from 1980 to 2029, sourced from the date spine. Includes total games, sales, revenue, scores, feature rates, year-over-year sales change, and `year_sales_tier` classification. |

### Incremental Model — mart_game_performance

`mart_game_performance` uses incremental materialization with a merge strategy. On the first run it builds the full table. On subsequent runs it only processes game records not already present in the table, identified by `game_id` as the unique key.

To rebuild from scratch:
```bash
dbt run --full-refresh --select mart_game_performance
```

Use `--full-refresh` when changing the model's SQL logic, adding new columns, or correcting historical source data.

---

## Macros

Macros are reusable Jinja functions defined once and called across multiple models. When dbt compiles a model it replaces each macro call with the generated SQL before executing.

### `sales_tier(column_name)`

Classifies a sales figure into a business tier.

```sql
{{ sales_tier('global_sales_million') }} as sales_tier
```

| Tier | Threshold |
|---|---|
| Blockbuster | >= 10 million |
| Hit | >= 1 million |
| Moderate | >= 0.1 million |
| Low | < 0.1 million |

### `critic_tier(column_name)`

Classifies a metacritic score into a quality tier.

```sql
{{ critic_tier('metacritic_score') }} as critic_tier
```

| Tier | Threshold |
|---|---|
| Must Play | >= 90 |
| Good | >= 75 |
| Mixed | >= 60 |
| Poor | < 60 |
| Unscored | NULL |

### `pct_true(column_name)`

Calculates the percentage of rows where a boolean column is true, rounded to one decimal place.

```sql
{{ pct_true('online_multiplayer') }} as pct_online_multiplayer
```

Equivalent to: `round(avg(case when column then 1.0 else 0.0 end) * 100, 1)`

---

## Snapshots

### `snap_publishers`

Tracks historical changes to publisher tier and region using SCD Type 2. Each time `dbt snapshot` runs, dbt compares the current source data against the snapshot table. When a tracked column changes, dbt closes the existing record by setting `dbt_valid_to` and inserts a new record with `dbt_valid_to = NULL` to represent the current state.

**Configuration:**

| Setting | Value |
|---|---|
| Strategy | `check` |
| Unique key | `publisher` |
| Tracked columns | `publisher_tier`, `publisher_region` |
| Target schema | `snapshots` |

**Columns added by dbt:**

| Column | Description |
|---|---|
| `dbt_scd_id` | Unique MD5 hash for each snapshot row |
| `dbt_updated_at` | Timestamp when the row was last evaluated |
| `dbt_valid_from` | When this version of the record became active |
| `dbt_valid_to` | When this version was superseded. NULL = current record |

**Querying current records:**
```sql
SELECT * FROM snapshots.snap_publishers
WHERE dbt_valid_to IS NULL;
```

**Querying historical records:**
```sql
SELECT * FROM snapshots.snap_publishers
WHERE publisher = 'Sega'
ORDER BY dbt_valid_from;
```

---

## Data Quality Tests

32 automated tests run on every `dbt build`. Tests are defined in `schema.yml` files alongside models.

### Test Types Used

| Test | What it checks |
|---|---|
| `unique` | No duplicate values in the column |
| `not_null` | No missing values in the column |
| `accepted_values` | Column only contains values from a defined list |

### Test Coverage

| Model | Tests |
|---|---|
| `stg_games` | `game_id` unique + not null, `title`, `genre`, `platform`, `publisher`, `release_year` not null |
| `stg_genre_summary` | `genre` unique + not null |
| `stg_platform_summary` | `platform` unique + not null |
| `stg_publisher_summary` | `publisher` unique + not null |
| `stg_yearly_trends` | `release_year` unique + not null |
| `mart_game_performance` | `game_id` unique + not null, `sales_tier` and `critic_tier` accepted values |
| `mart_genre_analysis` | `genre` unique + not null, `genre_sales_tier` accepted values |
| `mart_publisher_rankings` | `publisher` unique + not null, `sales_rank` not null |
| `mart_yearly_trends` | `release_year` unique + not null, `year_sales_tier` accepted values |

Run all tests:
```bash
dbt test
```

Run tests for a specific model:
```bash
dbt test --select mart_game_performance
```

---

## Getting Started

### Prerequisites

- Python 3.8 or higher
- Git
- VS Code (recommended)

### Installation

**1. Clone the repository:**
```bash
git clone https://github.com/benayimadison000/dbt-duckdb-games.git
cd dbt-duckdb-games/my_project_1
```

**2. Create and activate a virtual environment:**
```bash
python -m venv venv

# Windows
venv\Scripts\activate

# Mac/Linux
source venv/bin/activate
```

**3. Install Python dependencies:**
```bash
pip install dbt-core dbt-duckdb
```

**4. Configure the dbt profile:**

Create `~/.dbt/profiles.yml` with the following content:

```yaml
my_project_1:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: "dev.duckdb"
      threads: 4
```

**5. Install dbt packages:**
```bash
dbt deps
```

**6. Verify the setup:**
```bash
dbt debug
```

You should see `All checks passed!` at the bottom.

**7. Run the full pipeline:**
```bash
dbt build --full-refresh
```

Expected output:
```
Done. PASS=48 WARN=0 ERROR=0 SKIP=0 NO-OP=0 TOTAL=48
```

**8. Run snapshots:**
```bash
dbt snapshot
```

---

## Daily Workflow

### Starting a new feature

```bash
git checkout -b feature/your-feature-name
```

### Developing

```bash
# Run a single model during development
dbt run --select your_model_name

# Run a model and all its upstream dependencies
dbt run --select +your_model_name

# Run the full pipeline
dbt build --full-refresh
```

### Committing and pushing

```bash
git add .
git commit -m "describe what you built"
git push -u origin feature/your-feature-name
```

Then open a Pull Request on GitHub, merge it, and clean up:

```bash
git checkout master
git pull
git branch -d feature/your-feature-name
```

### Branch naming convention

| Prefix | Use for |
|---|---|
| `feature/` | New models, macros, or functionality |
| `fix/` | Fixing a broken model or failing test |
| `refactor/` | Improving existing code without changing output |
| `docs/` | Adding descriptions to schema.yml files |
| `test/` | Adding new data quality tests |

---

## Key Commands Reference

| Command | Description |
|---|---|
| `dbt debug` | Test database connection and project config |
| `dbt deps` | Install packages from packages.yml |
| `dbt seed` | Load CSV files from seeds/ into DuckDB |
| `dbt run` | Execute all models |
| `dbt run --select model_name` | Run a single model |
| `dbt run --select +model_name` | Run a model and all upstream dependencies |
| `dbt run --full-refresh` | Rebuild all models from scratch |
| `dbt test` | Run all data quality tests |
| `dbt snapshot` | Run SCD Type 2 snapshots |
| `dbt build` | Run seeds, models, and tests in dependency order |
| `dbt build --full-refresh` | Full rebuild including seeds |
| `dbt docs generate` | Compile documentation site |
| `dbt docs serve` | Serve documentation at localhost:8080 |
| `dbt clean` | Delete target/ and dbt_packages/ directories |
| `dbt show --select model_name --limit 5` | Preview first 5 rows of a model |
