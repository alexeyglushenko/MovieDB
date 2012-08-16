package MovieDB::Application::UI::Command::ListMoviesByYear;

use MovieDB::Common;
use parent qw{MovieDB::Application::UI::Command};
require MovieDB::Application::Database::Movie;

sub shortcut    { 'y' }
sub description { 'List movies by year' }

sub execute {
	my($self) = shift;
	
	$self->print_movies(movies => MovieDB::Application::Database::Movie->list($self, sort_field => 'release_year'), empty => 'Nothing in database yet');
	
	return 1;
}

__PACKAGE__->register();
