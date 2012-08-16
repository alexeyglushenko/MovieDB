package MovieDB::Application::Database::Schema::Result::Movie;

use MovieDB::Common;
use base qw{DBIx::Class::Core};

__PACKAGE__->table('movies');

__PACKAGE__->add_columns(
	'id' => {
		data_type         => 'uuid',
		is_auto_increment => 0,
		is_nullable       => 0,
		sequence          => 'movies_id_seq',
	},
	'title' => {
		data_type         => 'varchar',
		size              => 4096,
		is_nullable       => 0,
	},
	'release_year' => {
		data_type         => 'integer',
		is_nullable       => 1,
	},
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many(
	'movies__actors',
	'MovieDB::Application::Database::Schema::Result::Movie2Actor',
	{
		'foreign.movie_id' => 'self.id',
	},
	{
		cascade_copy   => 0,
		cascade_delete => 0,
	},
);

__PACKAGE__->has_many(
	'movies__media_types',
	'MovieDB::Schema::Result::Movie2MediaType',
	{
		'foreign.movie_id' => 'self.id',
	},
	{
		cascade_copy   => 0,
		cascade_delete => 0,
	},
);

1;
