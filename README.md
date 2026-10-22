# Formula 1 Statistics Database

## Overview

The Formula 1 Statistics Database is a relational database for storing, organizing, and analyzing Formula 1 data. It is easier and faster to query than the Formula 1 statistics APIs.

The database holds a curated set of Formula 1 information. You can analyze individual drivers, race weekends, qualifying sessions, races, championship standings, and detailed race data. For newer seasons, it also stores lap data and pit stops.

The database is built mainly around drivers and race weekends. You can compare drivers and see how a driver's performance changes over a season.

---

## Project goals

The main goals of the database are to:

* Store Formula 1 statistics in a structured relational database.
* Organize information so it can be queried efficiently.
* Reduce unnecessary duplication of data.
* Allow comparisons between different drivers.
* Allow users to analyze the same driver across an entire season.
* Store detailed lap and pit-stop information for newer seasons.
* Provide Formula 1 fans with data they can use for their own analysis.
* Keep the database up to date as new race weekends occur.

---

## Intended users

The primary users are Formula 1 fans who want to analyze drivers and race weekends on their own.

They can use the database to examine statistics and rankings for their favorite drivers, compare drivers, and investigate race performance.

The database administrator maintains the database and updates it after each race weekend. The administrator has both read and write permissions.

---

# Data source

The database was populated with the FastF1 Python library.

The data-loading process was:

1. Retrieve Formula 1 data using the FastF1 library.
2. Export the retrieved data into an Excel file.
3. Review and correct inconsistent data in Excel.
4. Export the cleaned data into CSV format.
5. Load the CSV data into the relational database.

The manual review step caught inconsistent data before it reached the database.

---

# Database entities

The database contains the following entities:

* `drivers`
* `teams`
* `event_weekends`
* `race_results`
* `qualifying_results`
* `lap_data`
* `pit_stops`
* `driver_standings`
* `driver_race_stats`

Every table uses a primary key to uniquely identify each row.

---

# Database schema

## `drivers`

The `drivers` table stores information about Formula 1 drivers.

| Column          | Data Type | Key    | Description                                                                                                  |
| --------------- | --------- | ------ | ------------------------------------------------------------------------------------------------------------ |
| `driver_id`     | INT       | PK     | Auto-incrementing unique identifier for the driver.                                                          |
| `driver_number` | INT       |        | Official race number, required and limited to 0-99 by a `CHECK` constraint. The first number used by the driver is stored because drivers can change race numbers. |
| `driver_name`   | VARCHAR   | UNIQUE | Full name of the driver.                                                                                     |


## `teams`

The `teams` table stores Formula 1 team information.

| Column      | Data Type | Key    | Description                                       |
| ----------- | --------- | ------ | ------------------------------------------------- |
| `team_id`   | INT       | PK     | Auto-incrementing unique identifier for the team. |
| `team_name` | VARCHAR   | UNIQUE | Full name of the team.                            |

Team names are unique, so duplicate team records are not stored. The project assumes no two teams have used the exact same name.

> **Note:** Inconsistencies in the source data limit how `teams` relates to the other tables. The database is therefore more driver-focused than team-focused.

---

## `event_weekends`

The `event_weekends` table stores information about each Formula 1 race weekend and the sessions held during it.

| Column         | Data Type | Key | Description                                               |
| -------------- | --------- | --- | --------------------------------------------------------- |
| `weekend_id`   | INT       | PK  | Auto-incrementing unique identifier for the race weekend. |
| `round_number` | INT       |     | Championship round number.                                |
| `year`         | INT       |     | Year in which the event took place.                       |
| `country`      | VARCHAR   |     | Country hosting the race.                                 |
| `location`     | VARCHAR   |     | City/location of the race.                                |
| `event_name`   | VARCHAR   |     | Name of the event.                                        |
| `session1`     | VARCHAR   |     | Name of the first session, usually Practice 1.                   |
| `session1date` | VARCHAR   |     | Date of the first session.                                |
| `session2`     | VARCHAR   |     | Name of the second session.                               |
| `session2date` | VARCHAR   |     | Date of the second session.                               |
| `session3`     | VARCHAR   |     | Name of the third session.                                |
| `session3date` | VARCHAR   |     | Date of the third session.                                |
| `session4`     | VARCHAR   |     | Name of the fourth session.                               |
| `session4date` | VARCHAR   |     | Date of the fourth session.                               |
| `session5`     | VARCHAR   |     | Name of the fifth session.                                |
| `session5date` | VARCHAR   |     | Date of the fifth session.                                |

### Unique constraint

The combination of:

```sql
(round_number, year)
```

is unique.

This is necessary because round numbers repeat every year. Round 1 in 2024 and Round 1 in 2025 are different race weekends.

---

# `race_results`

The `race_results` table stores each driver's result in a race.

| Column               | Data Type | Key | Description                                                   |
| -------------------- | --------- | --- | ------------------------------------------------------------- |
| `race_id`            | INT       | PK  | Auto-incrementing unique identifier for the race result.      |
| `weekend_id`         | INT       | FK  | Links the result to an `event_weekends` record.               |
| `driver_id`          | INT       | FK  | Links the result to a `drivers` record.                       |
| `finishing_position` | INT       |     | Position in which the driver finished the race.               |
| `status`             | VARCHAR   |     | Driver's race status, such as `Finished`, `+1 Lap`, or `DNF`. |
| `points_earned`      | FLOAT     |     | Championship points earned from the race.                     |

### Foreign keys

```sql
weekend_id → event_weekends.weekend_id
driver_id  → drivers.driver_id
```

A race weekend has many race results, one for each participating driver. Each driver accumulates race results across their career.

---

# `qualifying_results`

The `qualifying_results` table stores drivers' qualifying results.

| Column                | Data Type | Key | Description                                                    |
| --------------------- | --------- | --- | -------------------------------------------------------------- |
| `quali_id`            | INT       | PK  | Auto-incrementing unique identifier for the qualifying result. |
| `weekend_id`          | INT       | FK  | Links the qualifying result to an `event_weekends` record.     |
| `driver_id`           | INT       | FK  | Links the result to a `drivers` record.                        |
| `qualifying_time`     | VARCHAR   |     | Driver's final qualifying time, such as `01:15.962`.           |
| `qualifying_position` | INT       |     | Driver's qualifying order/position for the race.               |


### Foreign keys

```sql
weekend_id → event_weekends.weekend_id
driver_id  → drivers.driver_id
```

A race weekend usually has one qualifying result per participating driver.

Qualifying data starts in 1994. The race data reaches back further.

---

# `lap_data`

The `lap_data` table stores detailed lap-by-lap race information.

It is one of the largest tables. It holds details for each lap, including tire usage, sector times, pit-lane activity, and driver position.

| Column             | Data Type | Key | Description                                               |
| ------------------ | --------- | --- | --------------------------------------------------------- |
| `lap_id`           | INT       | PK  | Unique identifier for the lap record.                     |
| `weekend_id`       | INT       | FK  | Links the lap to an `event_weekends` record.              |
| `driver_id`        | INT       | FK  | Links the lap to a `drivers` record.                      |
| `lap_number`       | INT       |     | Lap completed by the driver.                              |
| `lap_time`         | VARCHAR   |     | Time recorded for the lap.                                |
| `stint`            | INT       |     | Tire stint number.                                        |
| `pit_out_time`     | VARCHAR   |     | Time the driver exited the pits.                          |
| `pit_in_time`      | VARCHAR   |     | Time the driver entered the pits.                         |
| `sector1_time`     | VARCHAR   |     | Sector 1 time.                                            |
| `sector2_time`     | VARCHAR   |     | Sector 2 time.                                            |
| `sector3_time`     | VARCHAR   |     | Sector 3 time.                                            |
| `is_personal_best` | BOOL      |     | Indicates whether the lap was the driver's personal best. |
| `compound`         | VARCHAR   |     | Tire compound used during the lap.                        |
| `tyre_life`        | INT       |     | Number of laps the tire had been used.                    |
| `fresh_tyre`       | BOOL      |     | Indicates whether the tire was new.                       |
| `lap_start_time`   | VARCHAR   |     | Time at which the lap started.                            |
| `position`         | INT       |     | Driver's position during the lap.                         |
| `deleted`          | BOOL      |     | Indicates whether the lap was deleted.                    |


### Foreign keys

```sql
weekend_id → event_weekends.weekend_id
driver_id  → drivers.driver_id
```

One race weekend can produce about 1,000 lap records, since each driver gets a record for every lap they complete.

The table holds about 184,000 rows, so it is one of the most important tables to index and optimize.

---

# `pit_stops`

The `pit_stops` table stores pit-stop information for drivers during race weekends.

A driver may make several stops in one race, so each race weekend can have many pit stops.

| Column         | Data Type | Key | Description                                             |
| -------------- | --------- | --- | ------------------------------------------------------- |
| `pit_stop_id`  | INT       | PK  | Auto-incrementing unique identifier for the pit stop.   |
| `weekend_id`   | INT       | FK  | Links the pit stop to an `event_weekends` record.       |
| `driver_id`    | INT       | FK  | Links the pit stop to a `drivers` record.               |
| `lap_number`   | INT       |     | Lap on which the pit-lane event was recorded.           |
| `pit_in_time`  | VARCHAR   |     | Time the driver entered the pits.                       |
| `pit_out_time` | VARCHAR   |     | Time the driver exited the pits.                        |
| `stop_number`  | INT       |     | Sequence number of the record for that driver and race. |

### Foreign keys

```sql
weekend_id → event_weekends.weekend_id
driver_id  → drivers.driver_id
```

In the loaded data, `pit_in_time` and `pit_out_time` sit on separate rows. The entry is recorded on one lap and the matching exit on the next, so one physical stop usually takes two rows.

### Relationship

```text
event_weekends → pit_stops
```

A race weekend has a **one-to-many** relationship with pit stops.

Likewise:

```text
drivers → pit_stops
```

A driver can have multiple pit stops across their races.

---

# `driver_standings`

The `driver_standings` table stores championship standings for drivers at each race weekend.

| Column        | Data Type | Key | Description                                               |
| ------------- | --------- | --- | --------------------------------------------------------- |
| `standing_id` | INT       | PK  | Unique identifier for the standing record.                |
| `weekend_id`  | INT       | FK  | Links the standing to an `event_weekends` record.         |
| `driver_id`   | INT       | FK  | Links the standing to a `drivers` record.                 |
| `points`      | FLOAT     |     | Driver's championship points at that point in the season. |
| `position`    | INT       |     | Driver's championship position.                           |
| `wins`        | INT       |     | Number of race wins recorded by the driver.               |

### Foreign keys

```sql
weekend_id → event_weekends.weekend_id
driver_id  → drivers.driver_id
```

Each race weekend has a standings record for each relevant driver. This makes it possible to track championship progress over a season.

---

# `driver_race_stats`

The `driver_race_stats` table stores aggregated race statistics for each driver at a race weekend.

| Column             | Data Type | Key | Description                                         |
| ------------------ | --------- | --- | --------------------------------------------------- |
| `stat_id`          | INT       | PK  | Unique identifier for the statistics record.        |
| `weekend_id`       | INT       | FK  | Links the statistics to an `event_weekends` record. |
| `driver_id`        | INT       | FK  | Links the statistics to a `drivers` record.         |
| `fastest_lap_time` | VARCHAR   |     | Driver's fastest lap time.                          |
| `avg_lap_time`     | VARCHAR   |     | Driver's average lap time.                          |
| `total_laps`       | INT       |     | Total laps completed.                               |
| `laps_led`         | INT       |     | Number of laps spent in first position.             |
| `total_pit_stops`  | INT       |     | Total number of pit stops.                          |



### Foreign keys

```sql
weekend_id → event_weekends.weekend_id
driver_id  → drivers.driver_id
```

A driver has race statistics for each race weekend they take part in. In the loaded data, these records cover 2018 onward.

---

# Entity relationships

The database mainly uses `drivers` and `event_weekends` as parent entities for the race-related tables.

## Event weekend relationships

### `event_weekends` → `race_results`

**One-to-many**

One race weekend contains many race results, one per driver.

### `event_weekends` → `qualifying_results`

**One-to-many**

One race weekend contains many qualifying results.

### `event_weekends` → `lap_data`

**One-to-many**

One race weekend contains many lap records, about 1,000 for a single race.

### `event_weekends` → `pit_stops`

**One-to-many**

One race weekend contains many pit stops.

### `event_weekends` → `driver_standings`

**One-to-many**

One race weekend contains a standings record for each driver.

### `event_weekends` → `driver_race_stats`

**One-to-many**

One race weekend contains race statistics for each participating driver.

---

## Driver relationships

### `drivers` → `race_results`

**One-to-many**

A driver can have many race results over their career.

### `drivers` → `qualifying_results`

**One-to-many**

A driver can have many qualifying results. The available qualifying data begins in 1994.

### `drivers` → `lap_data`

**One-to-many**

A driver can have many lap records. The detailed lap data begins in 2018.

### `drivers` → `pit_stops`

**One-to-many**

A driver can make multiple pit stops over their career.

### `drivers` → `driver_standings`

**One-to-many**

A driver can have a championship standing for each race weekend they take part in.

### `drivers` → `driver_race_stats`

**One-to-many**

A driver can have race statistics for each race weekend they take part in.

---

# Database design

## Primary keys

Every table uses a primary key to uniquely identify each record.

The database uses auto-incrementing integer identifiers instead of values from the source data.

For example:

```sql
driver_id
team_id
weekend_id
race_id
quali_id
lap_id
standing_id
stat_id
```

Some source data is inconsistent, so the design uses auto-incrementing identifiers. They stay stable for each record and make the database easier to extend.

---

## Foreign keys

Foreign keys connect child tables to their parent tables.

For example:

```text
race_results.driver_id
        ↓
drivers.driver_id
```

and:

```text
race_results.weekend_id
        ↓
event_weekends.weekend_id
```

Foreign-key constraints prevent invalid relationships, such as a race result that points to a driver who does not exist.

---

## Unique constraints

Driver names and team names are stored as unique values to prevent duplicate records.

```sql
UNIQUE(driver_name)
UNIQUE(team_name)
```

The `event_weekends` table also has a unique constraint on:

```sql
(round_number, year)
```

This lets the database tell apart the same championship round in different years.

---

# Normalization

The database was designed to reach **Third Normal Form (3NF)**, apart from the 1NF exception below.

### First normal form (1NF)

Values are atomic, with one exception: `event_weekends` stores sessions as the numbered column pairs `session1` to `session5date`, which is a repeating group. A separate sessions table would remove it.

### Second normal form (2NF)

The database satisfies 2NF because non-key attributes depend on the primary key.

### Third normal form (3NF)

The database satisfies 3NF because non-key attributes depend on the key, not on other non-key attributes.

---

# Indexing and optimization

Indexes speed up queries, especially on columns used in joins.

Foreign keys are indexed because they connect tables often. This matters most for `lap_data`, which has about 184,000 rows.

Additional `lap_data` indexes support common queries:

* Laps by race weekend and driver (`weekend_id`, `driver_id`)
* Deleted laps (`deleted`)
* Tire compounds (`compound`)
* Personal-best laps (`is_personal_best`)

Integer primary keys also compare faster than strings, which matters more as the data grows.

---

# Data coverage

The amount of historical data varies by type of information.

### Race data

Race results have broad historical coverage.

### Qualifying data

Qualifying data is available from **1994 onward** in the project dataset.

### Lap data

Detailed lap information is available from **2018 onward**.

### Pit stop data

Pit-stop data is limited to the newer part of the dataset. It is most useful for races from 2018 onward.

---

# Limitations

## Timing data stored as `VARCHAR`

Many timing measurements are stored as `VARCHAR` because the source dataset formats them inconsistently.

For example:

```text
lap_time
fastest_lap_time
avg_lap_time
sector1_time
sector2_time
sector3_time
qualifying_time
pit_in_time
pit_out_time
```

Session dates in `event_weekends` are also stored as strings. Storing these as strings makes numerical operations harder. A future version could convert them to a standard numeric format, such as milliseconds, and keep a formatted version for display.

---

## Historical data availability

Not every type of Formula 1 data is available for every season.

Qualifying data does not reach back to 1950; it starts in 1994. Detailed lap data starts in 2018. Queries on qualifying, laps, and pit stops therefore cannot cover the full history of Formula 1.

---

## Teams table

The `teams` table is underrepresented.

Source data conflicts and inconsistencies keep the teams table from relating to the other major tables. As a result, analysis is mainly at the driver level rather than the team level.

A future version could add a driver-team history table.

---

# Example use cases

The database can answer questions such as:

### Driver performance

* How many races has a driver won?
* How many points has a driver earned?
* What was a driver's average lap time at a particular race?
* How many laps has a driver led?
* How many races has a driver failed to finish?

### Qualifying vs. race performance

* What was a driver's qualifying position?
* Where did the driver finish the race?
* How many positions did the driver gain or lose between qualifying and the race?

### Championship analysis

* How did a driver's championship position change throughout a season?
* How many points did a driver have after each race?
* How many wins did a driver have at a particular point in the season?

### Lap analysis

* What was a driver's fastest lap?
* What was the driver's average lap time?
* Which tire compound was being used?
* How did tire life change throughout a stint?
* Which laps were deleted?
* What position was the driver in during each lap?

### Race strategy

* How many pit stops did a driver make?
* Which tire compounds were used?
* How long was each tire stint?
* How did lap times change as tire life increased?

---

# Project files

The project is organized around the schema, the data-loading process, and the queries.

## `schema.sql`

A MySQL dump of the database structure. It creates the `f1_db` database and each table with `CREATE TABLE`, with primary keys, foreign keys, constraints, and indexes (defined as `KEY` clauses) inside the table definitions. It contains no data.

## `schema_with_data.sql`

The same dump with the data included as `INSERT` statements.

## `query.sql`

The same data dump as `schema_with_data.sql` without the `CREATE TABLE` statements, followed by example queries. The queries use `SELECT`, `JOIN`, `LEFT JOIN`, `WHERE`, and `ORDER BY` to:

* Check whether drivers won from pole position after 1994.
* Find a driver's fastest laps across races from 2018 onward.
* Compare lap times with tire life for one driver in one race.
* Pull qualifying, race, and pit-stop statistics for every driver in one race.

## `f1test.py`

The Python script that collects the FastF1 data for the CSV export.

---

# Data pipeline

The general data pipeline is:

```text
              FastF1
                 │
                 ▼
        Python Data Collection
                 │
                 ▼
           Excel Export
                 │
                 ▼
      Data Cleaning / Editing
                 │
                 ▼
             CSV Files
                 │
                 ▼
          SQL Database
                 │
                 ▼
       Queries and Analysis
```

---

# Example database structure

```text
                         ┌─────────────────┐
                         │     drivers     │
                         │─────────────────│
                         │ driver_id   PK  │
                         │ driver_number   │
                         │ driver_name     │
                         └────────┬────────┘
                                  │
              ┌───────────────────┼────────────────────┐
              │                   │                    │
              ▼                   ▼                    ▼
       ┌──────────────┐   ┌────────────────┐   ┌──────────────┐
       │ race_results │   │ qualifying_    │   │   lap_data   │
       │              │   │ results        │   │              │
       │ race_id PK   │   │ quali_id PK    │   │ lap_id PK    │
       │ driver_id FK │   │ driver_id FK   │   │ driver_id FK │
       │ weekend_id FK│   │ weekend_id FK  │   │ weekend_id FK│
       └──────┬───────┘   └───────┬────────┘   └──────┬───────┘
              │                   │                   │
              └───────────────────┼───────────────────┘
                                  │
                                  ▼
                       ┌───────────────────┐
                       │  event_weekends   │
                       │───────────────────│
                       │ weekend_id PK     │
                       │ round_number      │
                       │ year              │
                       │ country           │
                       │ location          │
                       │ event_name        │
                       │ sessions          │
                       └─────────┬─────────┘
                                 │
              ┌──────────────────┼──────────────────┐
              │                  │                  │
              ▼                  ▼                  ▼
       ┌───────────────┐ ┌────────────────┐ ┌──────────────────┐
       │ pit_stops     │ │driver_standings│ │driver_race_stats │
       └───────────────┘ └────────────────┘ └──────────────────┘
```

---

# Future improvements

Possible next steps:

## Team relationships

A driver-team history table would record which team a driver raced for in each season or race.

For example:

```text
driver_team_history
-------------------
driver_team_id PK
driver_id FK
team_id FK
weekend_id FK
```

This would let you analyze team performance while accounting for drivers who change teams.

## Dedicated circuit table

A `circuits` table could store information about individual circuits instead of keeping location information in `event_weekends`.

It could include:

* Circuit name
* Country
* City
* Circuit length
* Number of turns
* Lap record

## Dedicated season table

A `seasons` table could represent each Formula 1 championship season.

## Improved timing storage

Timing data could be converted from strings into a standard numeric format, such as milliseconds. That would make calculations and comparisons easier.

## Expanded race data

Future versions could include:

* Weather data
* Track conditions
* Speed traps
* Sector speeds
* Driver telemetry
* Sprint results
* Constructor standings
* Circuit information
* More detailed pit-stop information

---

# Summary

The database stores and links drivers, race weekends, results, qualifying, lap data, standings, and race statistics in related tables. Primary and foreign keys maintain the relationships, unique constraints prevent duplicates, and indexes speed up the large `lap_data` table.

It supports both historical analysis and ongoing updates, so new race weekends can be added as the season progresses.

Its main focus is driver and race analysis, with detailed lap and pit-stop data for newer seasons. It also gives future work on teams, circuits, weather, and more advanced analytics a foundation to build on.
