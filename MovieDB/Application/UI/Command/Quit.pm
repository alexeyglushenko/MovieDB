package MovieDB::Application::UI::Command::Quit;

use MovieDB::Common;
use parent qw{MovieDB::Application::UI::Command};

sub shortcut    { 'q' }
sub description { 'Quit' }

sub execute {
	my($self) = shift;
	
	$self->application->running(0);
	
	return 1;
}

__PACKAGE__->register();
