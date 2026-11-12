# Tech stack & deliverables

Authoritative source: `project_requirements/semester_project_description.pdf`.

## Tech stack — non-negotiable

**Database engine: MySQL.** The relational model must be implemented as a
MySQL database. Write DDL in MySQL dialect (`AUTO_INCREMENT`,
MySQL-flavored types like `VARCHAR`, `DATE`, `ENUM`, etc. — not
Postgres/SQLite-specific syntax).

## Required deliverables (final submission)

1. Requirements description.
2. ER model (+ explanation of special design decisions).
3. Relational model as SQL DDL (can be its own `.sql` file), with foreign
   keys correctly defined.
4. At least one non-trivial SQL query: joins ≥2 tables, uses an aggregate
   function, uses `GROUP BY`. Needs an accompanying small test dataset
   (INSERTs) to demonstrate the query's result.
5. A short reflection.

## Top-grade hints

To exceed the minimum requirements:

- Several complex relationships (already satisfied — see `er-model.md`,
  multiple N:M relationships exist).
- Additional constraints in the relational model (`CHECK`, `UNIQUE`,
  `NOT NULL` beyond the obvious).
- Several queries, or a more complex query (e.g. using `HAVING`).
- Creating triggers.
