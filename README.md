# Formula 1 Statistics Database

## Overview

The Formula 1 Statistics Database is a relational database designed to **store, organize, and analyze Formula 1 data** in a way that is easier and more efficient to query than relying directly on Formula 1 statistics APIs.

The database focuses on useful, handpicked Formula 1 information and allows users to analyze individual drivers, race weekends, qualifying sessions, races, championship standings, and detailed race data. For newer seasons, the database also stores more detailed information such as lap data and pit stops.

The database is designed primarily around **drivers and race weekends**, allowing users to compare different drivers and examine how a driver's performance changes throughout a season.

---

## Project Goals

The main goals of the database are to:

* Store Formula 1 statistics in a structured relational database.
* Organize information so that it can be queried efficiently.
* Reduce unnecessary duplication of data.
* Allow comparisons between different drivers.
* Allow users to analyze the same driver across an entire season.
* Store detailed lap and pit-stop information for newer seasons.
* Provide Formula 1 fans with data that they can use for their own analysis.
* Keep the database up to date as new race weekends occur.

---

## Intended Users

The primary users of this database are **Formula 1 fans** who want to conduct their own analysis of drivers and race weekends.

Users can use the database to examine statistics and rankings for their favorite drivers, compare drivers, and investigate race performance.

The database administrator is responsible for maintaining the database and updating it after each race weekend. The administrator has both **read and write permissions**.

---

# Data Source

The database was populated using the **FastF1 Python library**.

The general data-loading process was:

1. Retrieve Formula 1 data using the FastF1 library.
2. Export the retrieved data into an Excel file.
3. Review and correct inconsistent data in Excel.
4. Export the cleaned data into CSV format.
5. Load the CSV data into the relational database.

This process allowed inconsistent data to be manually reviewed before it was inserted into the database.

---

# Database Entities

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

# Database Schema

## `drivers`

The `drivers` table stores information about Formula 1 drivers.

| Column          | Data Type | Key    | Description                                                                                                  |
| --------------- | --------- | ------ | ------------------------------------------------------------------------------------------------------------ |
| `driver_id`     | INT       | PK     | Auto-incrementing unique identifier for the driver.                                                          |
| `driver_number` | INT       |        | Official race number. The first number used by the driver is stored because drivers can change race numbers. |
| `full_name`     | VARCHAR   | UNIQUE | Full name of the driver.                                                                                     |


## `teams`

The `teams` table stores Formula 1 team information.

| Column      | Data Type | Key    | Description                                       |
| ----------- | --------- | ------ | ------------------------------------------------- |
| `team_id`   | INT       | PK     | Auto-incrementing unique identifier for the team. |
| `team_name` | VARCHAR   | UNIQUE | Full name of the team.                            |

Team names are unique so that duplicate team records are not unnecessarily stored. The project assumes that two teams have not used the exact same name.

> **Note:** The current database design has limited relationships involving `teams` because of conflicts and inconsistencies in the source data. As a result, the database is currently more driver-focused than team-focused.

---

## `event_weekends`

The `event_weekends` table stores information about each Formula 1 race weekend and the sessions associated with that weekend.

| Column         | Data Type | Key | Description                                               |
| -------------- | --------- | --- | --------------------------------------------------------- |
| `weekend_id`   | INT       | PK  | Auto-incrementing unique identifier for the race weekend. |
| `round_number` | INT       |     | Championship round number.                                |
| `year`         | INT       |     | Year in which the event took place.                       |
| `country`      | VARCHAR   |     | Country hosting the race.                                 |
| `location`     | VARCHAR   |     | City/location of the race.                                |
| `event_name`   | VARCHAR   |     | Name of the event.                                        |
| `session1`     | VARCHAR   |     | Name of the first session, usually FP1.                   |
| `session1date` | VARCHAR   |     | Date of the first session.                                |
| `session2`     | VARCHAR   |     | Name of the second session.                               |
| `session2date` | VARCHAR   |     | Date of the second session.                               |
| `session3`     | VARCHAR   |     | Name of the third session.                                |
| `session3date` | VARCHAR   |     | Date of the third session.                                |
| `session4`     | VARCHAR   |     | Name of the fourth session.                               |
| `session4date` | VARCHAR   |     | Date of the fourth session.                               |
| `session5`     | VARCHAR   |     | Name of the fifth session.                                |
| `session5date` | VARCHAR   |     | Date of the fifth session.                                |

### Unique Constraint

The combination of:

```sql
(round_number, year)
```

is unique.

This is necessary because championship round numbers repeat every year. For example, Round 1 in 2024 and Round 1 in 2025 must be treated as different race weekends.

---

# `race_results`

The `race_results` table stores the result of each driver in a race.

| Column               | Data Type | Key | Description                                                   |
| -------------------- | --------- | --- | ------------------------------------------------------------- |
| `race_id`            | INT       | PK  | Auto-incrementing unique identifier for the race result.      |
| `weekend_id`         | INT       | FK  | Links the result to an `event_weekends` record.               |
| `driver_id`          | INT       | FK  | Links the result to a `drivers` record.                       |
| `finishing_position` | INT       |     | Position in which the driver finished the race.               |
| `status`             | VARCHAR   |     | Driver's race status, such as `Finished`, `+1 Lap`, or `DNF`. |
| `points_earned`      | INT       |     | Championship points earned from the race.                     |

### Foreign Keys

```sql
weekend_id → event_weekends.weekend_id
driver_id  → drivers.driver_id
```

Each race weekend can have multiple race results because each participating driver has an individual result. Each driver can also have many race results across their career.

---

# `qualifying_results`

The `qualifying_results` table stores driver qualifying results.

| Column                | Data Type | Key | Description                                                    |
| --------------------- | --------- | --- | -------------------------------------------------------------- |
| `quali_id`            | INT       | PK  | Auto-incrementing unique identifier for the qualifying result. |
| `weekend_id`          | INT       | FK  | Links the qualifying result to an `event_weekends` record.     |
| `driver_id`           | INT       | FK  | Links the result to a `drivers` record.                        |
| `qualifying_time`     | INT       |     | Driver's final qualifying time.                                |
| `qualifying_position` | INT       |     | Driver's qualifying order/position for the race.               |


### Foreign Keys

```sql
weekend_id → event_weekends.weekend_id
driver_id  → drivers.driver_id
```

A race weekend can have many qualifying results, generally one for each participating driver.

The qualifying data does not extend as far back as the race data. The data source only contains qualifying results from 1994 onward.

---

# `lap_data`

The `lap_data` table stores detailed lap-by-lap race information.

This is one of the largest tables in the database and contains detailed information about individual laps, tire usage, sector times, pit-lane activity, and driver position.

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


### Foreign Keys

```sql
weekend_id → event_weekends.weekend_id
driver_id  → drivers.driver_id
```

A single race weekend can generate approximately **1,000 lap records**, because each driver can generate a record for every lap they complete.

The database contains approximately **180,000 rows** in `lap_data`, making it one of the most important tables for indexing and optimization.

---

# `pit_stops`

The `pit_stops` table stores pit-stop information for drivers during race weekends.

The project identifies `pit_stops` as one of the database entities. Each race weekend can contain many pit stops because a driver may make multiple pit stops during a single race.

### Relationship

```text
event_weekends → pit_stops
```

A single race weekend has a **one-to-many** relationship with pit stops.

Likewise:

```text
drivers → pit_stops
```

A driver can have multiple pit stops across their races.

> The provided project description identifies `pit_stops` as an entity but does not provide its individual column definitions. The detailed schema for this table should therefore be taken from the project's `schema.sql` file.

---

# `driver_standings`

The `driver_standings` table stores championship standings for drivers at each race weekend.

| Column        | Data Type | Key | Description                                               |
| ------------- | --------- | --- | --------------------------------------------------------- |
| `standing_id` | INT       | PK  | Unique identifier for the standing record.                |
| `weekend_id`  | INT       | FK  | Links the standing to an `event_weekends` record.         |
| `driver_id`   | INT       | FK  | Links the standing to a `drivers` record.                 |
| `points`      | INT       |     | Driver's championship points at that point in the season. |
| `position`    | INT       |     | Driver's championship position.                           |
| `wins`        | INT       |     | Number of race wins recorded by the driver.               |

### Foreign Keys

```sql
weekend_id → event_weekends.weekend_id
driver_id  → drivers.driver_id
```

Each race weekend has a standings record for each relevant driver, allowing championship progression to be analyzed throughout a season.

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



### Foreign Keys

```sql
weekend_id → event_weekends.weekend_id
driver_id  → drivers.driver_id
```

Each driver can have race statistics for each race weekend in which they participate.

---

# Entity Relationships

The database primarily uses `drivers` and `event_weekends` as parent entities for the race-related tables.

## Event Weekend Relationships

### `event_weekends` → `race_results`

**One-to-many**

One race weekend can contain many race results, with each driver receiving their own result.

### `event_weekends` → `qualifying_results`

**One-to-many**

One race weekend can contain many qualifying results.

### `event_weekends` → `lap_data`

**One-to-many**

One race weekend can contain many lap records, with approximately 1,000 records possible for a single race.

### `event_weekends` → `pit_stops`

**One-to-many**

One race weekend can contain many pit stops.

### `event_weekends` → `driver_standings`

**One-to-many**

One race weekend contains a standings record for each driver.

### `event_weekends` → `driver_race_stats`

**One-to-many**

One race weekend contains race statistics for each participating driver.

---

## Driver Relationships

### `drivers` → `race_results`

**One-to-many**

A driver can have many race results throughout their career.

### `drivers` → `qualifying_results`

**One-to-many**

A driver can have many qualifying results. The available qualifying data begins in 1994.

### `drivers` → `lap_data`

**One-to-many**

A driver can have many lap records. The detailed lap data begins in 2018.

### `drivers` → `pit_stops`

**One-to-many**

A driver can make multiple pit stops throughout their career.

### `drivers` → `driver_standings`

**One-to-many**

A driver can have a championship standing for each race weekend they participate in.

### `drivers` → `driver_race_stats`

**One-to-many**

A driver can have race statistics for each race weekend they participate in.

---

# Database Design

## Primary Keys

Every table uses a primary key to uniquely identify each record.

The database uses auto-incrementing integer identifiers rather than relying on values already contained in the source data.

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

This design was chosen because some source data contains inconsistencies. Auto-incrementing identifiers provide stable identifiers for database records and make it easier to expand the database in the future.

---

## Foreign Keys

Foreign keys are used to connect child tables to their parent tables.

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

Foreign-key constraints help prevent invalid relationships, such as a race result referring to a driver that does not exist.

---

## Unique Constraints

Driver names and team names are stored as unique values to prevent duplicate records.

```sql
UNIQUE(full_name)
UNIQUE(team_name)
```

The `event_weekends` table also uses a unique constraint involving:

```sql
(round_number, year)
```

This allows the database to distinguish between the same championship round in different years.

---

# Normalization

The database was designed to achieve **Third Normal Form (3NF)**.

### First Normal Form — 1NF

The database satisfies 1NF because values are atomic and repeating groups are not stored within individual fields.

### Second Normal Form — 2NF

The database satisfies 2NF because non-key attributes depend on the table's primary key.

### Third Normal Form — 3NF

The database satisfies 3NF because non-key attributes depend on the key rather than on another non-key attribute.

The project documentation identifies the database as achieving 1NF, 2NF, and 3NF.

---

# Indexing and Optimization

Indexes are used to improve query performance, particularly on columns that are frequently used in joins.

Foreign keys are indexed because they are frequently used to connect tables. This is particularly important for `lap_data`, which contains approximately **180,000 rows**.

Additional indexes are used for important `lap_data` queries, including:

* Driver fastest laps
* Deleted laps
* Tire compounds
* All laps for a specific driver

The database also uses incremental integer primary keys. Integer comparisons are generally more efficient than comparisons involving strings, which becomes increasingly important as the amount of data grows.

---

# Data Coverage

The amount of historical data available varies depending on the type of information.

### Race Data

Race results provide broad historical coverage.

### Qualifying Data

Qualifying data is available from **1994 onward** according to the project dataset.

### Lap Data

Detailed lap information is available from **2018 onward**.

### Pit Stop Data

Pit-stop information is similarly limited to the newer portion of the dataset and is most useful for races from 2018 onward.

---

# Limitations

## Timing Data Stored as `VARCHAR`

Many timing measurements are stored as `VARCHAR` because of inconsistent formatting in the source dataset.

For example:

```text
lap_time
fastest_lap_time
avg_lap_time
sector1_time
sector2_time
sector3_time
```

Storing these values as strings makes certain numerical operations more difficult.

A future version could convert these values into a standardized numerical representation, such as milliseconds, while retaining a formatted version for display.

---

## Historical Data Availability

Not every type of Formula 1 data is available for every season.

The qualifying data does not extend back to 1950 and begins in 1994, while detailed lap data begins in 2018. Therefore, queries involving qualifying, laps, and pit stops cannot necessarily be applied to the entire history of Formula 1.

---

## Teams Table

The `teams` table is currently underrepresented.

Due to conflicts and inconsistencies in the source data, the teams table does not currently have relationships with the other major tables. This means that the database is primarily focused on **driver-level analysis** rather than team-level analysis.

A future version could address this with a driver-team relationship/history table.

---

# Example Use Cases

The database can be used to investigate questions such as:

### Driver Performance

* How many races has a driver won?
* How many points has a driver earned?
* What was a driver's average lap time at a particular race?
* How many laps has a driver led?
* How many races has a driver failed to finish?

### Qualifying vs. Race Performance

* What was a driver's qualifying position?
* Where did the driver finish the race?
* How many positions did the driver gain or lose between qualifying and the race?

### Championship Analysis

* How did a driver's championship position change throughout a season?
* How many points did a driver have after each race?
* How many wins did a driver have at a particular point in the season?

### Lap Analysis

* What was a driver's fastest lap?
* What was the driver's average lap time?
* Which tire compound was being used?
* How did tire life change throughout a stint?
* Which laps were deleted?
* What position was the driver in during each lap?

### Race Strategy

* How many pit stops did a driver make?
* Which tire compounds were used?
* How long was each tire stint?
* How did lap times change as tire life increased?

---

# Project Files

The project is organized around the database schema, data-loading process, and queries.

## `schema.sql`

Contains SQL statements used to define the database structure.

This includes statements such as:

```sql
CREATE TABLE
CREATE INDEX
```

The schema establishes the tables, primary keys, foreign keys, constraints, and indexes.

## `query.sql`

Contains SQL statements used to load data into the database and queries that can be used to analyze the stored Formula 1 data.

Example operations include:

```sql
INSERT
SELECT
JOIN
GROUP BY
LIKE
```

as well as more advanced queries such as aggregations and subqueries.

---

# Data Pipeline

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

This approach separates data collection, cleaning, storage, and analysis.

---

# Example Database Structure

```text
                         ┌─────────────────┐
                         │     drivers     │
                         │─────────────────│
                         │ driver_id   PK  │
                         │ driver_number   │
                         │ full_name       │
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

# Future Improvements

Several improvements could be made to expand the database.

## Team Relationships

A driver-team history table could be added to properly represent which team a driver competed for during each season or race.

For example:

```text
driver_team_history
-------------------
driver_team_id PK
driver_id FK
team_id FK
weekend_id FK
```

This would allow team performance to be analyzed while accounting for drivers changing teams.

## Dedicated Circuit Table

A `circuits` table could store information about individual circuits rather than storing location information directly in `event_weekends`.

Potential information could include:

* Circuit name
* Country
* City
* Circuit length
* Number of turns
* Lap record

## Dedicated Season Table

A `seasons` table could represent each Formula 1 championship season.

## Improved Timing Storage

Timing data could be converted from strings into a standardized numerical representation such as milliseconds. This would make calculations and comparisons easier.

## Expanded Race Data

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

This Formula 1 database provides a structured way to store and analyze Formula 1 statistics using a relational database rather than relying exclusively on API-based access.

The database separates drivers, race weekends, results, qualifying, lap data, standings, and race statistics into related tables. Primary and foreign keys maintain relationships between the data, while unique constraints help prevent duplicate records. Indexes are used to improve performance, particularly for the large `lap_data` table.

The database is designed to support both **historical analysis and ongoing updates**, allowing new race weekends to be added as the Formula 1 season progresses.

Its primary focus is driver and race analysis, with detailed lap and pit-stop information available for newer seasons. The current design also provides a foundation for future expansion into team, circuit, weather, and more advanced Formula 1 analytics.
