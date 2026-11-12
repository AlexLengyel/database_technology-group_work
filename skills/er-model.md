# ER model — ground truth

Source: `docs/library_er_diagram.png`. This is finalized; implementation
work (DDL, queries, docs) must map onto exactly this model.

## Entities & attributes

- **Person** (`Person_id` PK, `First_name`, `Middle_name`, `Last_name`, `Date_of_birth`)
  — superclass, disjoint specialization into `Customer` and `Contributor`.
- **Customer** (is-a Person): `Phone_number`, `Email`.
- **Contributor** (is-a Person): `Country_of_origin`. (Authors, narrators,
  directors etc. of media — role is captured via `Role` below.)
- **Address** (`Address_id` PK, `Address_line_1`, `Address_line_2`, `Postcode`, `City`)
- **Library** (`Library_id` PK, `Name`)
- **User_group** (`Group_id` PK, `Name`, `Max_loans`)
- **Role** (`Role_id` PK, `Role_name`) — role a Contributor has on a Medium
  (e.g. author, narrator, director).
- **Copy** (`Copy_id` PK, `Loan_days`, `Format`) — a physical/lendable copy
  owned by a Library, of a Medium.
- **Medium** (`Medium_id` PK, `Language`, `Title`, `Epoch`, `Publication_date`,
  `Required_age`) — superclass, disjoint specialization into `Book`,
  `Audiobook`, `Movie`.
- **Book** (is-a Medium): `ISBN`, `Number_of_pages_printed_version`.
- **Audiobook** (is-a Medium): `ISBN`, `Runtime` (column `runtime_minutes`).
- **Movie** (is-a Medium): `ISAN`, `Runtime` (column `runtime_minutes`), `Resolution`.
- **Publisher** (`Publisher_id` PK, `Name`)
- **Subject_area** (`Subject_id` PK, `Name`)

14 entity/subtype types total — comfortably over the required minimum of 8.

## Relationships & cardinalities

- `lives_in`: Address (1) — (N) Customer.
- `has_address`: Address (1) — (1) Library.
- `belongs_to`: Customer (N) — (1) User_group.
- `loan_of`: Customer (N) — (M) Copy — **the required N:M relationship.**
  Attributes: `Loan_id`, `Loan_date`, `Due_date`, `Return_date`.
  `Due_date` is a **derived attribute** (dashed in the diagram): it is
  calculated as `Loan_date` + `Copy.Loan_days` and is therefore not stored
  as a column in `loan`.
- `participates_in`: Contributor (N) — (M) Medium, qualified by `Role`
  (partial participation on the Role side) — a Contributor's involvement in a
  Medium always has a Role attached (author/narrator/director/etc.).
- `publishes`: Medium (M) — (N) Publisher.
- `has_subject`: Medium (M) — (N) Subject_area.
- `has_copy`: Medium (1) — (N) Copy.
- `owns_copy`: Library (1) — (N) Copy.

N:M relationships present: `loan_of`, `participates_in`, `publishes`,
`has_subject` — multiple, which helps toward the "several complex
relationships" top-grade hint.

## Translating to relational/MySQL

- Disjoint specializations (Person→Customer/Contributor, Medium→Book/
  Audiobook/Movie) typically become one table per subtype holding the extra
  attributes, with the subtype PK also being a FK back to the supertype PK
  (`Customer.Person_id` / `Contributor.Person_id` referencing
  `Person.Person_id`; same pattern for `Book`/`Audiobook`/`Movie` →
  `Medium.Medium_id`). Keep the supertype table holding shared attributes.
- Disjointness is enforced with a discriminator column: `person.person_type`
  (`'Customer'` / `'Contributor'`) and `medium.medium_type` (`'Book'` /
  `'Audiobook'` / `'Movie'`). Each subtype table repeats the discriminator,
  fixed to its own value by a `CHECK`, and references the supertype through
  a composite foreign key on (id, type), backed by a `UNIQUE (id, type)` on
  the supertype. A person or medium can therefore only appear in the one
  subtype table matching its type. These subtype foreign keys have no
  `ON DELETE CASCADE`, because MySQL does not allow referential actions on
  columns used in a `CHECK`; delete the subtype row before the supertype row.
  Total participation (every person/medium must have a subtype row) is not
  enforced by the DDL.
- `loan_of`, `participates_in`, `publishes`, and `has_subject` become
  associative/junction tables (composite PK or surrogate PK + FKs + unique
  constraint), since they're N:M.
- `participates_in` needs `Role_id` as part of its junction table (it's
  effectively a ternary relationship: Contributor × Medium × Role).
- Reservations and reminders/callbacks (recall notices) are mentioned in the
  original requirements text (`project_requirements/project_description.txt`)
  but are **not** modeled as separate entities in the finalized diagram.
  Reservations are covered by `loan` (group decision). For anything beyond
  that, check with the group before adding new tables/entities, since it
  would extend the agreed model.

## Scope decisions

These are deliberate simplifications to keep the project from becoming too
complex. Don't "fix" them, and apply the same reasoning to similar cases.

- **ENUM / VARCHAR instead of lookup tables.** Where the best solution would
  be a separate lookup table, we use an `ENUM` (or a plain `VARCHAR`)
  instead and mark it in the DDL with the comment "Limitation of the project
  scope. In reality we would create another table." Currently:
  `medium.epoch`, `medium.language`, `contributor.country_of_origin`,
  `copy.format`, `movie.resolution`. The value lists are intentionally
  incomplete (e.g. not every country exists in `country_of_origin`).
- **Switzerland only.** The system only handles Swiss customers and
  addresses: `address.postcode` is a 4-digit Swiss postcode stored as
  `SMALLINT`, and `customer.phone_number` must be a Swiss number in the
  format `+41` followed by 9 digits.
