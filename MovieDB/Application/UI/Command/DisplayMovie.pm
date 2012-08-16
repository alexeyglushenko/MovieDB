package MovieDB::Application::UI::Command::DisplayMovie;

use MovieDB::Common;
use parent qw{MovieDB::Application::UI::Command};

sub shortcut    { 'i' }
sub description { 'Display movie' }

sub execute {
	my($self) = shift;
	
	my($movie) = $self->get_movie_from_id('Movie ID to display: ');
	
	if (!$movie) {
		return 0;
	}
	
	$self->print_card($movie);
	
	return 1;
}

sub print_card {
	my($self) = shift;
	my($movie) = @_;
	
	say($movie->format_card());
}

__PACKAGE__->register();
