package MovieDB::Application::Database::Actor;

use MovieDB::Common;
use parent qw{MovieDB::Application::Database::Object};

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
		my($cursor) = $session->resultset('Actor')->find_or_create({
			name => $self->{name},
		});
		
		$self->{id} = $cursor->id;
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
	
	# say "Actor id == $id";
	$cursor = $session->resultset('Actor')->single({ id => $id });
	
	if ($cursor) {
		return $cls->new(
			application  => $application,
			__predefined => 1,
			id           => $cursor->id,
			name         => $cursor->name,
		);
	}
}

1;
