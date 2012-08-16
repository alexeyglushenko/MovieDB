package MovieDB::Application::UI::Command::AddMovie;

use MovieDB::Common;
use parent qw{MovieDB::Application::UI::Command};
require MovieDB::Application::Database::Movie;

sub shortcut    { 'a' }
sub description { 'Add movie' }

sub execute {
	my($self) = shift;
	
	say('Please fill movie card fields:');
	
	(my($title)        = $self->read_title()) || return 0;
	(my($release_year) = $self->read_release_year()) || return 0;
	(my($media_type)   = $self->read_media_type()) || return 0;
	(my($actors)       = $self->read_actors()) || return 0;
	
	($self->confirm_tmp_card($title, $release_year, $media_type, $actors)) || return 0;
	
	my($movie);
	try {
		$movie = MovieDB::Application::Database::Movie->new(
			title        => $title,
			release_year => $release_year,
			media_type   => $media_type,
			actors       => $actors,
		);
	} catch {
		confess("Could not add new movie card due to error: $_");
	};
	
	return 1;
}

sub read_title {
	my($self) = shift;
	
	while (1) {
		my($title) = $self->ui->ask(msg => 'Title: ');
		
		if (!$title) {
			my($cmd) = $self->ui->choice(msg => 'Invalid title.', choices => ['abort', 'retry']);
			
			given ($cmd) {
				when ('a') { return; }
				when ('r') { next; }
			}
		}
		
		return $title;
	}
}

sub read_release_year {
	my($self) = shift;
	
	while (1) {
		my($release_year) = $self->ui->ask(msg => 'Release Year: ');
		my($config) = $self->config;
		
		if (!looks_like_int($release_year)) {
			my($cmd) = $self->ui->choice(msg => 'Release year is not number.', choices => ['abort', 'retry']);
			
			given ($cmd) {
				when ('a') { return; }
				when ('r') { next; }
			}
		}
		
		if (($config->{'release_year_min'} <= $release_year) && ($release_year <= $config->{'release_year_max'})) {
			my($cmd) = $self->ui->choice(msg => "Release year is out of $config->{'release_year_min'}..$config->{'release_year_max'} range.", choices => ['abort', 'retry']);
			
			given ($cmd) {
				when ('a') { return; }
				when ('r') { next; }
			}
		}
		
		return $release_year;
	}
}

__PACKAGE__->register();
