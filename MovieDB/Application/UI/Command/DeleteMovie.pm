package MovieDB::Application::UI::Command::DeleteMovie;

use MovieDB::Common;
use parent qw{MovieDB::Application::UI::Command};

sub shortcut    { 'd' }
sub description { 'Delete movie' }

sub execute {
	my($self) = shift;
	
	my($movie) = $self->get_movie_from_id('Movie ID to delete: ');
	
	if (!$movie) {
		return 0;
	}
	
	try {
		$movie->delete();
		
		say('Deleted.');
		
		return 1;
	} catch {
		croak("Could not delete movie $movie due to error: $_");
		
		return 0;
	};
}

__PACKAGE__->register();
