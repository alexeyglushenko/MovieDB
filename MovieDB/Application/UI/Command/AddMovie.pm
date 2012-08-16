package MovieDB::Application::UI::Command::AddMovie;

use MovieDB::Common;
use parent qw{MovieDB::Application::UI::Command};
require MovieDB::Application::Database::Movie;
require MovieDB::Set;

sub shortcut    { 'a' }
sub description { 'Add movie' }

sub execute {
	my($self) = shift;
	
	say('Please fill movie card fields:');
	
	(my $title        = $self->read_title())        || return 0;
	(my $release_year = $self->read_release_year()) || return 0;
	(my $media_type   = $self->read_media_type())   || return 0;
	(my $cast         = $self->read_cast())         || return 0;
	
	($self->confirm_tmp_card($title, $release_year, $media_type, $cast)) || return 0;
	
	my($movie);
	try {
		$movie = MovieDB::Application::Database::Movie->new(
			application  => $self->application,
			title        => $title,
			release_year => $release_year,
			media_type   => $media_type,
			actors       => [keys(%{$cast})],
		);
		
		my($id) = $movie->id;
		say("Added movie. New ID is $id");
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
		
		if (!looks_like_number($release_year)) {
			my($cmd) = $self->ui->choice(msg => 'Release year is not number.', choices => ['abort', 'retry']);
			
			given ($cmd) {
				when ('a') { return; }
				when ('r') { next; }
			}
		}
		
		#$release_year += 0;
		
		if (!(($config->{release_year_min} <= $release_year) && ($release_year <= $config->{release_year_max}))) {
			my($cmd) = $self->ui->choice(msg => "Release year is out of $config->{release_year_min}..$config->{release_year_max} range.", choices => ['abort', 'retry']);
			
			given ($cmd) {
				when ('a') { return; }
				when ('r') { next; }
			}
		}
		
		return $release_year;
	}
}

sub read_media_type {
	my($self) = shift;
	
	my($media_type_names) = MovieDB::Application::Database::MediaType->list_names($self->application);
	my($media_type_suggestions) = join(', ', @{$media_type_names});
	my($media_type_lookup) = MovieDB::Set::set($media_type_names);
	
	my($media_type);
	
	while (1) {
		$media_type = $self->ui->ask(msg => "Format ($media_type_suggestions): ");
		
		if (!exists($media_type_lookup->{$media_type})) {
			my($cmd) = $self->ui->choice(msg => 'Unknown format.', choices => ['create', 'retry', 'abort']);
			
			given ($cmd) {
				when ('c') { last; }
				when ('r') { next; }
				when ('a') { return; }
			}
		}
		
		last;
	}
	
	return $media_type;
}

sub read_cast {
	my($self) = shift;
	
	my($session) = $self->session;
	my($cast);
	
	my($print_cast) = sub {
		say('');
		say('Cast: ', $self->cast_to_csl($cast));
	};
	
	my($get_and_parse_csl) = sub {
		my($prompt) = @_;
		
		while (1) {
			my($actors_csl) = $self->ui->ask(msg => $prompt);
			
			#say Dumper([ map { $_ =~ s/^\s*(.*?)\s*$/$1/; $_ } (split(',', $actors_csl)) ]);
			
			my($actor_names) = MovieDB::Set::set([ map { $_ =~ s/^\s*(.*?)\s*$/$1/; $_ } (split(',', $actors_csl)) ]);
			my($cmd) = $self->ui->choice(msg => 'Is this list correct?', choices => ['yes', 'no']);
			
			if ($cmd eq 'y') {
				return ($actor_names);
			}
		}
	};
	
	$cast = $get_and_parse_csl->('Comma-separated list of actors: ');
	
	while (1) {
		$print_cast->();
		
		my($cmd) = $self->ui->choice(msg => 'Is any action on cast needed?', choices => ['accept', 'decline', 'merge', 'remove', 'clear']);
		
		given ($cmd) {
			when ('a') { return $cast; }
			when ('d') { return; }
			when ('m') { $cast = MovieDB::Set::add($cast, $get_and_parse_csl->('Comma-separated list of actors to merge with: ')); }
			when ('r') { $cast = MovieDB::Set::subtract($cast, $get_and_parse_csl->('Comma-separated list of actors to remove from cast: ')); }
			when ('c') {
				while (1) {
					my($cmd2) = $self->ui->choice(msg => 'Are you sure to clear cast?', choices => ['proceed', 'cancel']);
					
					if ($cmd2 eq 'p') {
						$cast = {};
					}
					
					last;
				}
			}
		}
	}
}

sub cast_to_csl {
	my($self) = shift;
	my($cast) = @_;
	
	return join(', ', @{$self->cast_to_list($cast)});
}

sub cast_to_list {
	my($self) = shift;
	my($cast) = @_;
	
	return [sort(keys(%{$cast}))];
}

sub print_tmp_card {
	my($self) = shift;
	my($title, $release_year, $media_type, $cast) = @_;
	my($stars) = $self->cast_to_csl($cast);
	
	(my $card = <<CARD_EOF) =~ s/^\s*//gm;
		=== DRAFT === DRAFT === DRAFT ===
		Title: $title
		Release Year: $release_year
		Format: $media_type
		Stars: $stars
		=== DRAFT === DRAFT === DRAFT ===
CARD_EOF
	# chomp $card;
	
	say $card;
}

sub confirm_tmp_card {
	my($self) = shift;
	my($title, $release_year, $media_type, $cast) = @_;
	
	$self->print_tmp_card($title, $release_year, $media_type, $cast);
	
	my($cmd) = $self->ui->choice(msg => 'Is information in this card correct?', choices => ['yes', 'no']);
	
	return ($cmd eq 'y');
}

__PACKAGE__->register();
