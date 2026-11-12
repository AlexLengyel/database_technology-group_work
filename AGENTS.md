# Agent notes — Library System semester project

Group work for the "Database Technologies" module (HS26), 30% of the grade.
Topic: a library administrative system (subject areas, media with different
lending times, locations, user groups with different borrowing rights,
reservations, overdue reminders). Full original brief:
`project_requirements/project_description.txt` and
`project_requirements/semester_project_description.pdf`.

**Core rule: the ER model at `docs/library_er_diagram.png` is finalized.**
Treat it as ground truth — do not redesign it. If something about it seems
awkward or incomplete, flag it for the group rather than silently changing it.

**Code quality: use best practices and clean code throughout.** This applies
to SQL DDL/DML (consistent naming, explicit constraints, no redundant/dead
statements, comments only where a decision isn't self-evident) and to any
accompanying scripts or docs — readable and maintainable over clever or
shortcut-y, since it's group work others will read and extend.

**Scope: keep it a school project, not a production system.** Where the
ideal solution would be an extra lookup table, we deliberately use an `ENUM`
or `VARCHAR` instead (marked in the DDL with a "Limitation of the project
scope" comment), and the system is Switzerland-only. Follow the same approach
for similar cases instead of adding tables. Details: "Scope decisions" in
`skills/er-model.md`.

## What to read, and when

- **Touching the data model, DDL, or queries** → read `skills/er-model.md`.
  It transcribes every entity, attribute, relationship, and cardinality from
  the diagram, plus notes on mapping the disjoint specializations and N:M
  relationships into MySQL tables/foreign keys.
- **Checking what the submission needs, or whether something is "enough"**
  → read `skills/deliverables.md`. Tech stack (MySQL, mandatory), the
  required deliverables, and the top-grade hints.

## Repo layout

- `project_requirements/` — the given brief + grading PDF (project material).
- `docs/` — project artifacts, currently just the ER diagram (project material).
- `skills/` — reference docs for coding agents (this file's supporting detail,
  kept separate from the project's own files above).
- `sql/` — the SQL deliverables, meant to run in numeric order:
  `01_schema.sql` (DDL: tables + constraints; add triggers here too if used
  for extra credit), `02_seed_data.sql` (test data), `03_queries.sql`
  (the required analytical quer(y/ies)). Add new files with the next number
  in sequence if the work needs splitting further (e.g. a dedicated
  `04_triggers.sql`).
