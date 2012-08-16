CREATE TABLE movies (
	id           uuid PRIMARY KEY,
	title        varchar(4096) NOT NULL CHECK (title <> ''),
	release_year integer NOT NULL CHECK ((1800 <= release_year) AND (release_year <= 2100))
);

CREATE TABLE actors (
	id    serial PRIMARY KEY,
	name  varchar(4096) NOT NULL CHECK (name <> '')
);

CREATE TABLE media_types (
	id   serial PRIMARY KEY,
	name varchar(32) NOT NULL CHECK (name <> '')
);

CREATE TABLE movies__actors (
	movie_id uuid,
	actor_id integer,
	FOREIGN KEY (movie_id) REFERENCES movies (id),
	FOREIGN KEY (actor_id) REFERENCES actors (id),
	PRIMARY KEY (movie_id, actor_id)
);

CREATE TABLE movies__media_types (
	movie_id      uuid,
	media_type_id integer,
	FOREIGN KEY (movie_id)      REFERENCES movies (id),
	FOREIGN KEY (media_type_id) REFERENCES media_types (id),
	PRIMARY KEY (movie_id, media_type_id)
);
