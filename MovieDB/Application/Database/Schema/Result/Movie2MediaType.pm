package MovieDB::Application::Database::Schema::Result::Movie2MediaType;

use MovieDB::Common;
use base qw{DBIx::Class::Core};

__PACKAGE__->table('movies__media_types');

__PACKAGE__->add_columns(
	'movie_id' => {
		data_type      => 'uuid',
		is_foreign_key => 1,
		is_nullable    => 0,
	},
	'media_type_id' => {
		data_type      => 'integer',
		is_foreign_key => 1,
		is_nullable    => 0,
	},
);

__PACKAGE__->set_primary_key('movie_id', 'media_type_id');

__PACKAGE__->belongs_to(
	'media_types',
	'MovieDB::Application::Database::Schema::Result::MediaType',
	{
		id            => 'media_type_id',
	},
	{
		is_deferrable => 1,
		on_delete     => 'CASCADE',
		on_update     => 'CASCADE',
	},
);

__PACKAGE__->belongs_to(
	'movies',
	'MovieDB::Application::Database::Schema::Result::Movie',
	{
		id            => 'movie_id',
	},
	{
		is_deferrable => 1,
		on_delete     => 'CASCADE',
		on_update     => 'CASCADE',
	},
);

1;
