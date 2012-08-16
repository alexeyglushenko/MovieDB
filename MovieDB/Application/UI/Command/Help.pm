package MovieDB::Application::UI::Command::Help;

use MovieDB::Common;
use parent qw{MovieDB::Application::UI::Command};

sub shortcut    { 'h' }
sub description { 'Help (this list of commands)' }

sub execute {
	my($self) = shift;
	
	say('Available options:');
	
	foreach (MovieDB::Application::UI::Command->commands()) {
		say($_->menuline);
	}
	
	return 1;
}

__PACKAGE__->register();
