package MovieDB::Application::Database;

use MovieDB::Common;
use parent qw{MovieDB::Object};
require MovieDB::Application::Database::Schema;

sub init {
	my($self) = shift;
	my(%kwarg) = (@_);
	my($application) = $self->application($kwarg{application}->application);
	
	my($config) = $self->config;
	
	$self->{session} = MovieDB::Application::Database::Schema->connect($config->{'database_dsn'}, $config->{'database_user'}, $config->{'database_pass'});
}

sub session { shift->{session} }

1;
