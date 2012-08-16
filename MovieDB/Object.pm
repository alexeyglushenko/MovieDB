package MovieDB::Object;

use MovieDB::Common;
use parent qw{};

sub new {
	my($cls) = shift;
	my($self) = bless({}, $cls);
	
	$self->init(@_);
	
	return $self;
}

sub init {
	my($self) = shift;
	
	# default initializer
}

sub application { 
	my($self) = shift;
	
	if (@_) {
		$self->{application} = shift;
	}
	
	return $self->{application};
}

sub ui { shift->application->ui }
sub database { shift->application->database }
sub config { shift->application->config }
sub session { shift->application->database->session }

1;
