package MovieDB::Application::UI::Command::ListMoviesByTitle;

use MovieDB::Common;
use parent qw{MovieDB::Application::UI::Command};
require MovieDB::Application::Database::Movie;

sub shortcut    { 't' }
sub description { 'List movies by title' }

sub execute {
	my($self) = shift;
	
	$self->print_movies(movies => MovieDB::Application::Database::Movie->list($self, sort_field => 'title'), empty => 'Nothing in database yet');
	
	return 1;
}

__PACKAGE__->register();
