package MovieDB::Application;

use MovieDB::Common;
use parent qw{MovieDB::Object};

require MovieDB::Application::UI;
require MovieDB::Application::Database;

sub init {
	my($self) = shift;
	my(%kwarg) = (@_);
	
	$self->{config} = {
		release_year_min => 1800,
		release_year_max => 2100,
		
		database_dsn     => $kwarg{database_dsn},
		database_user    => $kwarg{database_user},
		database_pass    => $kwarg{database_pass},
	};
	
	$self->running(0);
	
	$self->{database} = MovieDB::Application::Database->new(application => $self);
	$self->{ui}       = MovieDB::Application::UI->new(application => $self);
}

sub run {
	my($self) = shift;
	
	$self->running(1);
	$self->ui->main_loop();
	
	return 0;
}

sub application { (shift) };
sub ui { shift->{ui} }
sub database { shift->{database} }
sub config { shift->{config} }

sub running {
	my($self) = shift;
	
	if (@_) {
		$self->{running} = shift;
	}
	
	return $self->{running};
}

1;
