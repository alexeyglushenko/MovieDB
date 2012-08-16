package MovieDB::Application::Database::Schema::Result::Actor;

use MovieDB::Common;
use base qw{DBIx::Class::Core};

__PACKAGE__->table('actors');

__PACKAGE__->add_columns(
	'id' => {
		data_type         => 'integer',
		is_auto_increment => 1,
		is_nullable       => 0,
		sequence          => 'actors_id_seq',
	},
	'name' => {
		data_type         => 'varchar',
		size              => 4096,
		is_nullable       => 0,
	},
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many(
	'movies__actors',
	'MovieDB::Application::Database::Schema::Result::Movie2Actor',
	{
		'foreign.actor_id' => 'self.id'
	},
	{
		cascade_copy   => 0,
		cascade_delete => 0,
	},
);

1;
