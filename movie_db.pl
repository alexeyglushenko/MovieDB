#!/usr/bin/env perl -w

require MovieDB::Application;

my($application) = MovieDB::Application->new(
	database_dsn  => 'dbi:Pg:dbname=movie_db;host=127.0.0.1',
	database_user => 'movie_db',
	database_pass => '12345678',
);

exit($application->run());
