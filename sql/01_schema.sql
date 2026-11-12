-- DDL: CREATE TABLE statements for the library system relational model.
-- Mirrors docs/library_er_diagram.png — see skills/er-model.md for the
-- entity/relationship-to-table mapping. Define all primary and foreign keys here.

CREATE DATABASE IF NOT EXISTS library;
USE library;


CREATE TABLE user_group (
    group_id   INTEGER      NOT NULL AUTO_INCREMENT,
    name       VARCHAR(50)  NOT NULL UNIQUE,
    max_loans  SMALLINT     NOT NULL CHECK (max_loans >= 0),
    CONSTRAINT PK_user_group PRIMARY KEY (group_id)
);

CREATE TABLE person (
    person_id      INTEGER      NOT NULL AUTO_INCREMENT,
    first_name     VARCHAR(100) NOT NULL,
    middle_name    VARCHAR(100),
    last_name      VARCHAR(100) NOT NULL,
    date_of_birth  DATE,
    person_type    VARCHAR(11)  NOT NULL CHECK (person_type IN ('Customer', 'Contributor')),  -- discriminator: disjoint specialization
    CONSTRAINT PK_person PRIMARY KEY (person_id),
    CONSTRAINT UQ_person_type UNIQUE (person_id, person_type)  -- target of the subtype foreign keys
);

CREATE TABLE role (
    role_id    INTEGER  NOT NULL AUTO_INCREMENT,
    role_name  VARCHAR(50) NOT NULL UNIQUE,        -- Author, Director, Narrator, Actor, Translator, Voiceactor
    CONSTRAINT PK_role PRIMARY KEY (role_id)
);

CREATE TABLE address (
    address_id      INTEGER      NOT NULL AUTO_INCREMENT,
    address_line_1  VARCHAR(150) NOT NULL,
    address_line_2  VARCHAR(150),
    postcode        SMALLINT     NOT NULL,
    city            VARCHAR(100) NOT NULL,
    CONSTRAINT PK_address PRIMARY KEY (address_id)
);

CREATE TABLE publisher (
    publisher_id  INTEGER      NOT NULL AUTO_INCREMENT,
    name          VARCHAR(150) NOT NULL,
    CONSTRAINT PK_publisher PRIMARY KEY (publisher_id)
);

CREATE TABLE subject_area (
    subject_id  INTEGER      NOT NULL AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL UNIQUE,            -- Examples: Fantasy, Sci-Fi, Crime, Thriller, etc.
    CONSTRAINT PK_subject_area PRIMARY KEY (subject_id)
);

CREATE TABLE medium (
    medium_id         INTEGER      NOT NULL AUTO_INCREMENT,
    title             VARCHAR(255) NOT NULL,
    publication_date  DATE,
    epoch  ENUM(
    'Antiquity',          -- until ~500
    'Middle Ages',        -- ~500-1500
    'Renaissance',        -- ~1400-1600
    'Baroque',            -- ~1600-1720
    'Enlightenment',      -- ~1720-1800
    'Storm and Stress',    -- ~1765-1785
    'Classicism',         -- ~1786-1805 (Weimar Classicism)
    'Romanticism',        -- ~1795-1840
    'Realism',            -- ~1848-1890
    'Naturalism',         -- ~1880-1900
    'Modernism',          -- ~1900-1945
    'Post-war',           -- ~1945-1970
    'Postmodernism',      -- ~1970-2000
    'Contemporary',       -- ~2000-today
    'Other'
),
    required_age      TINYINT      NOT NULL CHECK (required_age BETWEEN 0 AND 18),
    language  ENUM(
    'German',
    'French',
    'Italian',
    'Romansh',
    'English',
    'Spanish',
    'Portuguese',
    'Russian',
    'Chinese',
    'Japanese',
    'Korean',
    'Arabic',
    'Hindi',
    'Turkish',
    'Dutch',
    'Polish',
    'Swedish',
    'Greek',
    'Latin',
    'Other'
) NOT NULL, -- Limitation of the project scope. In reality we would create another table.
    medium_type       VARCHAR(9)   NOT NULL CHECK (medium_type IN ('Book', 'Audiobook', 'Movie')),  -- discriminator: disjoint specialization
    CONSTRAINT PK_medium PRIMARY KEY (medium_id),
    CONSTRAINT UQ_medium_type UNIQUE (medium_id, medium_type)  -- target of the subtype foreign keys
);

CREATE TABLE customer (
    fk_person      INTEGER      NOT NULL,
    email          VARCHAR(254) NOT NULL UNIQUE,
    phone_number   VARCHAR(12)  NOT NULL CHECK (phone_number LIKE '+41_________'),
    fk_user_group  INTEGER      NOT NULL,
    fk_address     INTEGER      NOT NULL,
    person_type    VARCHAR(11)  NOT NULL DEFAULT 'Customer' CHECK (person_type = 'Customer'),
    CONSTRAINT PK_customer PRIMARY KEY (fk_person),
    CONSTRAINT FK_customer_person
        FOREIGN KEY (fk_person, person_type) REFERENCES person (person_id, person_type),
    CONSTRAINT FK_customer_user_group
        FOREIGN KEY (fk_user_group) REFERENCES user_group (group_id),
    CONSTRAINT FK_customer_address
        FOREIGN KEY (fk_address) REFERENCES address (address_id)
);

CREATE TABLE contributor (
    fk_person          INTEGER      NOT NULL,
    country_of_origin  ENUM(
        'Germany',
        'Switzerland',
        'USA',
        'Russia',
        'Austria',
        'Italy',
        'France',
        'Hungary',
        'China',
        'South Korea',
        'Japan',
        'Australia',
        'Greece',
        'India'
    ), -- Limitation of the project scope. In reality we would create another table.
    person_type        VARCHAR(11)  NOT NULL DEFAULT 'Contributor' CHECK (person_type = 'Contributor'),
    CONSTRAINT PK_contributor PRIMARY KEY (fk_person),
    CONSTRAINT FK_contributor_person
        FOREIGN KEY (fk_person, person_type) REFERENCES person (person_id, person_type)
);

CREATE TABLE library (
    library_id  INTEGER      NOT NULL AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL,
    fk_address  INTEGER      NOT NULL UNIQUE,
    CONSTRAINT PK_library PRIMARY KEY (library_id),
    CONSTRAINT FK_library_address
        FOREIGN KEY (fk_address) REFERENCES address (address_id)
);

CREATE TABLE copy (
    copy_id     INTEGER      NOT NULL AUTO_INCREMENT,
    format  ENUM(
    -- book
    'Hardcover',
    'Paperback',
    'ePub',
    'PDF',
    -- audiobook
    'Audio CD',
    'MP3',
    'FLAC',
    'WAV',
    -- movie
    'DVD',
    'Blu-ray',
    'MP4',
    'M4V',
    'MKV'
) NOT NULL, -- Limitation of the project scope. In reality we would create another table.
    loan_days   SMALLINT     NOT NULL CHECK (loan_days > 0),
    fk_medium   INTEGER      NOT NULL,
    fk_library  INTEGER      NOT NULL,
    CONSTRAINT PK_copy PRIMARY KEY (copy_id),
    CONSTRAINT FK_copy_medium
        FOREIGN KEY (fk_medium) REFERENCES medium (medium_id),
    CONSTRAINT FK_copy_library
        FOREIGN KEY (fk_library) REFERENCES library (library_id)
);

CREATE TABLE loan (
    loan_id      INTEGER  NOT NULL AUTO_INCREMENT,
    fk_customer  INTEGER  NOT NULL,
    fk_copy      INTEGER  NOT NULL,
    loan_date    DATE     NOT NULL DEFAULT (CURRENT_DATE),
    return_date  DATE,
    CONSTRAINT PK_loan PRIMARY KEY (loan_id),
    CONSTRAINT CHK_loan_dates CHECK (return_date >= loan_date),
    CONSTRAINT FK_loan_customer
        FOREIGN KEY (fk_customer) REFERENCES customer (fk_person),
    CONSTRAINT FK_loan_copy
        FOREIGN KEY (fk_copy) REFERENCES copy (copy_id)
);

CREATE TABLE participation (
    fk_contributor  INTEGER  NOT NULL,
    fk_medium       INTEGER  NOT NULL,
    fk_role         INTEGER  NOT NULL,
    CONSTRAINT PK_participation PRIMARY KEY (fk_contributor, fk_medium, fk_role),
    CONSTRAINT FK_participation_contributor
        FOREIGN KEY (fk_contributor) REFERENCES contributor (fk_person) ON DELETE CASCADE,
    CONSTRAINT FK_participation_medium
        FOREIGN KEY (fk_medium) REFERENCES medium (medium_id) ON DELETE CASCADE,
    CONSTRAINT FK_participation_role
        FOREIGN KEY (fk_role) REFERENCES role (role_id)
);

CREATE TABLE publishes (
    fk_publisher  INTEGER  NOT NULL,
    fk_medium     INTEGER  NOT NULL,
    CONSTRAINT PK_publishes PRIMARY KEY (fk_publisher, fk_medium),
    CONSTRAINT FK_publishes_publisher
        FOREIGN KEY (fk_publisher) REFERENCES publisher (publisher_id) ON DELETE CASCADE,
    CONSTRAINT FK_publishes_medium
        FOREIGN KEY (fk_medium) REFERENCES medium (medium_id) ON DELETE CASCADE
);

CREATE TABLE medium_subject (
    fk_medium        INTEGER  NOT NULL,
    fk_subject_area  INTEGER  NOT NULL,
    CONSTRAINT PK_medium_subject PRIMARY KEY (fk_medium, fk_subject_area),
    CONSTRAINT FK_medium_subject_medium
        FOREIGN KEY (fk_medium) REFERENCES medium (medium_id) ON DELETE CASCADE,
    CONSTRAINT FK_medium_subject_subject_area
        FOREIGN KEY (fk_subject_area) REFERENCES subject_area (subject_id) ON DELETE CASCADE
);

CREATE TABLE book (
    fk_medium                        INTEGER      NOT NULL,
    isbn                             VARCHAR(13)  UNIQUE,
    number_of_pages_printed_version  INTEGER      CHECK (number_of_pages_printed_version > 0),
    medium_type                      VARCHAR(9)   NOT NULL DEFAULT 'Book' CHECK (medium_type = 'Book'),
    CONSTRAINT PK_book PRIMARY KEY (fk_medium),
    CONSTRAINT FK_book_medium
        FOREIGN KEY (fk_medium, medium_type) REFERENCES medium (medium_id, medium_type)
);

CREATE TABLE audiobook (
    fk_medium  INTEGER      NOT NULL,
    isbn       VARCHAR(13)  UNIQUE,
    runtime_minutes    INTEGER      CHECK (runtime_minutes > 0),
    medium_type        VARCHAR(9)   NOT NULL DEFAULT 'Audiobook' CHECK (medium_type = 'Audiobook'),
    CONSTRAINT PK_audiobook PRIMARY KEY (fk_medium),
    CONSTRAINT FK_audiobook_medium
        FOREIGN KEY (fk_medium, medium_type) REFERENCES medium (medium_id, medium_type)
);

CREATE TABLE movie (
    fk_medium   INTEGER      NOT NULL,
    isan        VARCHAR(40)  UNIQUE,
    resolution  ENUM(
    'SD 480p',
    'HD 720p',
    'Full HD 1080p',
    '4K 2160p',
    '8K 4320p'
), -- Limitation of the project scope. In reality we would create another table.
    runtime_minutes     INTEGER      CHECK (runtime_minutes > 0),
    medium_type         VARCHAR(9)   NOT NULL DEFAULT 'Movie' CHECK (medium_type = 'Movie'),
    CONSTRAINT PK_movie PRIMARY KEY (fk_medium),
    CONSTRAINT FK_movie_medium
        FOREIGN KEY (fk_medium, medium_type) REFERENCES medium (medium_id, medium_type)
);
