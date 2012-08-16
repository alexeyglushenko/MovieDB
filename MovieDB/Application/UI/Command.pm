package MovieDB::Application::UI::Command;

use MovieDB::Common;
use parent qw{MovieDB::Object};

require MovieDB::Application::UI::Command::AddMovie;
require MovieDB::Application::UI::Command::DeleteMovie;
require MovieDB::Application::UI::Command::DisplayMovie;
require MovieDB::Application::UI::Command::FindMoviesByStar;
require MovieDB::Application::UI::Command::FindMoviesByTitle;
require MovieDB::Application::UI::Command::Help;
require MovieDB::Application::UI::Command::ImportMovies;
require MovieDB::Application::UI::Command::ListMoviesByTitle;
require MovieDB::Application::UI::Command::ListMoviesByYear;
require MovieDB::Application::UI::Command::Quit;

require MovieDB::Application::Database::Movie;

my(@commands);
my(%shortcuts);

sub commands { @commands };
sub shortcuts { %shortcuts };

sub init {
	my($self) = shift;
	my(%kwarg) = (@_);
	my($application) = $self->application($kwarg{application}->application);
}

sub execute {
	confess "not implemented";
}

sub register {
	my($cls) = shift;
	
	push(@commands, $cls);
	$shortcuts{$cls->shortcut} = $cls;
	
	# carp("Registered $cls");
	
	return 1;
}

sub menuline {
	my($cls) = shift;
	$cls = blessed($cls) || $cls;
	
	my($shortcut) = $cls->shortcut;
	my($description) = $cls->description;
	
	return "    ($shortcut) $description";
}

sub print_movies {
	my($self) = shift;
	my(%kwarg) = (@_);
	
	my($count) = 0;
	
	foreach (@{$kwarg{movies}}) {
		$count++;
		
		my($id)           = $_->id;
		my($title)        = $_->title;
		my($release_year) = $_->release_year;
		
		say("[$id] $title ($release_year)");
	}
	
	if ($count) {
		say("Total $count item(s)");
	} else {
		say("$kwarg{empty}");
	}
}

sub get_movie_from_id {
	my($self) = shift;
	my($prompt) = @_;
	my($movie);
	
	while (1) {
		my($movie_id) = $self->ui->ask(msg => $prompt);
		
		if (!UUID::Tiny::is_UUID_string($movie_id)) {
			my($cmd) = $self->ui->choice(msg => 'Movie ID is malformed.', choices => ['abort', 'retry']);
			
			given ($cmd) {
				when ('a') { return; }
				when ('r') { next; }
			}
		}
		
		$movie = MovieDB::Application::Database::Movie->get_by_id($self->application, $movie_id);
		
		if (!$movie) {
			my($cmd) = $self->ui->choice(msg => 'There is no such movie ID in database.', choices => ['abort', 'retry']);
			
			given ($cmd) {
				when ('a') { return undef; }
				when ('r') { next; }
			}
		}
		
		last;
	}
	
	return $movie;
}

1;
