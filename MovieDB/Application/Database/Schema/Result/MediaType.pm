package MovieDB::Application::Database::Schema::Result::MediaType;

use MovieDB::Common;
use base qw{DBIx::Class::Core};

__PACKAGE__->table('media_types');

__PACKAGE__->add_columns(
	'id' => {
		data_type         => 'integer',
		is_auto_increment => 1,
		is_nullable       => 0,
		sequence          => 'media_types_id_seq',
	},
	'name' => {
		data_type         => 'varchar',
		size              => 32,
		is_nullable       => 0,
	},
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many(
	'movies__media_types',
	'MovieDB::Application::Database::Schema::Result::Movie2MediaType',
	{
		'foreign.format_id' => 'self.id',
	},
	{
		cascade_copy   => 0,
		cascade_delete => 0,
	},
);

1;
