package MovieDB::Application::UI::Command::FindMoviesByTitle;

use MovieDB::Common;
use parent qw{MovieDB::Application::UI::Command};
require MovieDB::Application::Database::Movie;

sub shortcut    { 'f' }
sub description { 'Find movies by title' }

sub execute {
	my($self) = shift;
	
	my($title_part) = $self->read_title_part();
	
	if (!$title_part) {
		return 0;
	}
	
	$self->print_movies(movies => MovieDB::Application::Database::Movie->find($self, where => 'title', what => $title_part), empty => 'Nothing found');
	
	return 1;
}

sub read_title_part {
	my($self) = shift;
	
	my($title_part);
	
	while (1) {
		$title_part = $self->ui->ask(msg => 'Partial title: ');
		
		if (!$title_part) {
			my($cmd) = $self->ui->choice(msg => 'Invalid request.', choices => ['abort', 'retry']);
			
			given ($cmd) {
				when ('a') { return; }
				when ('r') { next; }
			}
		} else {
			last;
		}
	}
	
	return $title_part;
}

__PACKAGE__->register();
