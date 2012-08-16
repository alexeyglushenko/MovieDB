package MovieDB::Application::Database::Schema::Result::Movie2Actor;

use MovieDB::Common;
use base qw{DBIx::Class::Core};

__PACKAGE__->table('movies__actors');

__PACKAGE__->add_columns(
	'movie_id' => {
		data_type      => 'uuid',
		is_foreign_key => 1,
		is_nullable    => 0,
	},
	'actor_id' => {
		data_type      => 'integer',
		is_foreign_key => 1,
		is_nullable    => 0,
	},
);

__PACKAGE__->set_primary_key('movie_id', 'actor_id');

__PACKAGE__->belongs_to(
	'actors',
	'MovieDB::Application::Database::Schema::Result::Actor',
	{
		id            => 'actor_id',
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
