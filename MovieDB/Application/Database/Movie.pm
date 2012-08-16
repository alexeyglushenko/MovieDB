package MovieDB::Application::Database::Movie;

use MovieDB::Common;
use parent qw{MovieDB::Application::Database::Object};
require MovieDB::Application::Database::Actor;
require MovieDB::Application::Database::MediaType;
use UUID::Tiny ':std';

sub init {
	my($self) = shift;
	my(%kwarg) = (@_);
	@{$self}{keys(%kwarg)} = values(%kwarg);
	my($application) = $self->application($kwarg{application}->application);
	my($session) = $self->session;
	
	# my(%kwarg_copy) = (%kwarg);
	# delete($kwarg_copy{application});
	# say(Dumper(%kwarg_copy));
	# say "----------------------------";
	# my($scopy) = {%{$self}};
	# delete(${scopy}->{application});
	# say(Dumper($scopy));
	
	if (!$self->{__predefined}) {
		my($cursor);
		
		# find or create movie record
		$cursor = $session->resultset('Movie')->find_or_create({
			id           => UUID::Tiny::create_UUID_as_string(UUID::Tiny::UUID_RANDOM),
			title        => $self->{title},
			release_year => $self->{release_year},
		});
		$self->{id} = $cursor->id;
		
		# find or create media type record
		my($media_type) = $self->{media_type} = MovieDB::Application::Database::MediaType->new(application => $self->application, name => $self->{media_type});
		
		# link movie and media type
		$cursor = $session->resultset('Movie2MediaType')->find_or_create({
			movie_id      => $self->id,
			media_type_id => $media_type->id,
		});
		
		# load actors
		my(@actors) = ();
		foreach (@{$self->{actors}}) {
			my($actor) = MovieDB::Application::Database::Actor->new(application => $self->application, name => $_);
			push(@actors, $actor);
			
			# link
			$cursor = $session->resultset('Movie2Actor')->find_or_create({
				movie_id => $self->id,
				actor_id => $actor->id,
			});
		}
		$self->{actors} = \@actors;
	} else {
		delete($self->{__predefined});
	}
}

sub get_by_id {
	my($cls) = shift;
	my($application) = shift->application;
	my($session) = $application->session;
	my($id) = @_;
	my($cursor);
	
	$cursor = $session->resultset('Movie')->single({ id => $id });
	
	if ($cursor) {
		my($id) = $cursor->id;
		my($title) = $cursor->title;
		my($release_year) = $cursor->release_year;
		
		my($media_type_id) = $session->resultset('Movie2MediaType')->single({ movie_id => $id })->media_type_id;
		my($media_type) = MovieDB::Application::Database::MediaType->get_by_id($application, $media_type_id);
		
		$cursor = $session->resultset('Movie2Actor')->search({ movie_id => $id });
		my(@actors) = ();
		while (my $actor = $cursor->next) {
			push(@actors, MovieDB::Application::Database::Actor->get_by_id($application, $actor->actor_id));
		}
		
		return $cls->new(
			application  => $application,
			__predefined => 1,
			id           => $id,
			title        => $title,
			release_year => $release_year,
			media_type   => $media_type,
			actors       => \@actors,
		);
	}
}

sub delete {
	my($self) = shift;
	my($session) = $self->session;
	
	$session->resultset('Movie2Actor')->search({ movie_id => $self->id })->delete();
	$session->resultset('Movie2MediaType')->search({ movie_id => $self->id })->delete();
	$session->resultset('Movie')->single({ id => $self->id })->delete();
}

sub list {
	my($cls) = shift;
	my($application) = shift->application;
	my($session) = $application->session;
	my(%kwarg) = (@_);
	my($cursor);
	
	$cursor = $session->resultset('Movie')->search({}, { order_by => {-asc => $kwarg{sort_field} } });
	
	my(@results) = ();
	if ($cursor) {
		while (my $movie = $cursor->next) {
			push(@results, $cls->get_by_id($application, $movie->id));
		}
	}
	
	return \@results;
}

sub find {
	my($cls) = shift;
	my($application) = shift->application;
	my($session) = $application->session;
	my(%kwarg) = (@_);
	
	my $cursor;
	
	given ($kwarg{where}) {
		when('title') {
			$cursor = $session->resultset('Movie')->search({
				title => {'ilike' => "%$kwarg{what}%"}
			}, {
				order_by => {-asc => 'title'}
			});
		}
		when('actor') {
			$cursor = $session->resultset('Movie')->search({
				'actors.name' => {'ilike' => "$kwarg{what}"},
			}, {
				join => {'movies__actors' => 'actors'},
				order_by => {-asc => 'title'},
			});
		}
	};
	
	if ($cursor) {
		my(@results);
		
		while (my $movie = $cursor->next) {
			push(@results, $cls->get_by_id($application, $movie->id));
		}
		
		return \@results;
	}
}

sub format_card {
	my($self)         = shift;
	
	my($id)           = $self->id;
	my($title)        = $self->title,
	my($release_year) = $self->release_year;
	my($format)       = $self->media_type->name;
	my($stars)        = join(', ', map { $_->name } @{$self->actors});
	
	(my $card = <<HERE_EOF) =~ s/^\s*//gm;
		ID: $id
		Title: $title
		Release Year: $release_year
		Format: $format
		Stars: $stars
HERE_EOF
	chomp $card;
	
	return $card;
}

1;
