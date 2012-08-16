package MovieDB::Application::UI;

use MovieDB::Common;
use parent qw{MovieDB::Object};
require MovieDB::Application::UI::Command;
require MovieDB::Application::UI::Command::ImportMovies;
require MovieDB::Application::UI::Command::Quit;

sub init {
	my($self) = shift;
	my(%kwarg) = (@_);
	my($application) = $self->application($kwarg{application}->application);
	
	my(%cls_shortcuts) = MovieDB::Application::UI::Command->shortcuts;
	my($shortcuts) = $self->{shortcuts} = {};
	
	while (my($key, $value) = each(%cls_shortcuts)) {
		my($command_instance) = $value->new(application => $self->application);
		$shortcuts->{$key} = sub { $command_instance->execute(@_) };
		
		# say("key = <$key>, value = <$value>");
	}
}

sub shortcuts { shift->{shortcuts} };

sub main_loop {
	my($self) = shift;
	
	while ($self->application->running) {
		my($cmd) = undef;
		
		try {
			$cmd = $self->ui->ask(msg => 'Select action ("h" for help): ');
		} catch {
			confess("Exception: $_");
		};
		
		if (!defined($cmd)) {
			$cmd = MovieDB::Application::UI::Command::Quit->shortcut;
		}
		
		my($shortcuts) = $self->shortcuts;
		
		if (exists($shortcuts->{$cmd})) {
			try {
				my($success) = $shortcuts->{$cmd}->();
				
				if (!$success) {
					carp('Action was cancelled');
				}
			} catch {
				carp("Action was finished with error: $_");
			};
			
			say("");
		}
	}
}

sub ask {
	my($self) = shift;
	my(%kwarg) = (
		strip => 1,
		msg => '',
		@_,
	);
	
	my($line);
	
	print '> ';
	print $kwarg{msg};
	defined($line = <STDIN>) || return;
	
	if ($kwarg{strip}) {
		$line =~ s/^\s*(.*?)\s*$/$1/;
	}
	
	return ($line);
}

sub choice {
	my($self) = shift;
	my(%kwarg) = (@_);
	
	my(@keys);
	my(@titles);
	
	foreach(@{$kwarg{choices}}) {
		my($key) = substr($_, 0, 1);
		my($title) = sprintf("(%s)%s", uc($key), lc(substr($_, 1)));
		
		push(@keys, $key);
		push(@titles, $title);
	}
	my($rx_keys) = join('', @keys);
	
	while (1) {
		my($cmd) = lc($self->ui->ask(msg => sprintf('%s %s? ', $kwarg{msg}, join(', ', @titles))));
		
		if ($cmd =~ /^[${rx_keys}]$/i) {
			return $cmd;
		}
	}
}
