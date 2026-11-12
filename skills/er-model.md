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
- **Audiobook** (is-a Medium): `ISBN`, `Runtime`.
- **Movie** (is-a Medium): `ISAN`, `Runtime`, `Resolution`.
- **Publisher** (`Publisher_id` PK, `Name`)
- **Subject_area** (`Subject_id` PK, `Name`)

13 entity/subtype types total — comfortably over the required minimum of 8.

## Relationships & cardinalities

- `lives_in`: Address (1) — (N) Customer.
- `has_address`: Address (1) — (1) Library.
- `belongs_to`: Customer (N) — (1) User_group.
- `loan_of`: Customer (N) — (M) Copy — **the required N:M relationship.**
  Attributes: `Loan_id`, `Loan_date`, `Due_date`, `Return_date`.
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
- `loan_of`, `participates_in`, `publishes`, and `has_subject` become
  associative/junction tables (composite PK or surrogate PK + FKs + unique
  constraint), since they're N:M.
- `participates_in` needs `Role_id` as part of its junction table (it's
  effectively a ternary relationship: Contributor × Medium × Role).
- Reminders/callbacks (recall notices) and reservations are mentioned in the
  original requirements text (`project_requirements/project_description.txt`)
  but are **not** modeled as separate entities in the finalized diagram — if
  implementing that functionality, check with the group before adding new
  tables/entities, since it would extend the agreed model.
