package MovieDB::Application::UI::Command::FindMoviesByStar;

use MovieDB::Common;
use parent qw{MovieDB::Application::UI::Command};
require MovieDB::Application::Database::Movie;

sub shortcut    { 's' }
sub description { 'Find movies by star' }

sub execute {
	my($self) = shift;
	
	my($actor_name) = $self->read_actor_name('Actor name: ');
	
	if (!$actor_name) {
		return 0;
	}
	
	$self->print_movies(movies => MovieDB::Application::Database::Movie->find($self, where => 'actor', what => $actor_name), empty => 'Empty filmography');
	
	return 1;
}

sub read_actor_name {
	my($self) = shift;
	
	my($session) = $self->session;
	my($actor_name);
	my($cursor);
	
	while (1) {
		$actor_name = $self->ui->ask(msg => 'Actor name: ');
		
		$cursor = $session->resultset('Actor')->single({
			name => {'ilike', $actor_name},
		});
		
		if (!$cursor) {
			my($cmd) = $self->ui->choice(msg => 'There is no such actor in database.', choices => ['abort', 'retry']);
			
			given ($cmd) {
				when ('a') { return; }
				when ('r') { next; }
			}
		} else {
			last;
		}
	}
	
	return $actor_name;
}

__PACKAGE__->register();
