package MovieDB::Application::UI::Command::ImportMovies;

use MovieDB::Common;
use parent qw{MovieDB::Application::UI::Command};
require MovieDB::Application::Database::Movie;

sub shortcut    { 'm' }
sub description { 'Import movies' }

sub execute {
	my($self) = shift;
	
	my($filename) = $self->ui->ask(msg => 'Filename to import movies from: ');
	my($cmd);
	
	while (1) {
		# say("file == $filename");
		
		if (!((-e $filename) && (-r $filename))) {
			$cmd = $self->ui->choice(
				msg => 'File does not seem to exist or is not readable.',
				choices => ['abort', 'retry', 'ignore'],
			);
		} elsif (!(-f $filename)) {
			$cmd = $self->ui->choice(
				msg => 'File is unusual.',
				choices => ['abort', 'retry', 'ignore'],
			);
		} else {
			$cmd = undef;
		}
		
		given ($cmd) {
			when (undef) { last; }
			when ('a') { return 0; }
			when ('r') { next; }
			when ('i') { last; }
		}
	}
	
	say('Importing...');
	my($count_imported, $count_skipped) = $self->import_text($filename);
	say("Import finished. $count_imported records imported, $count_skipped skipped.");
	
	return 1;
}

sub import_text {
	my($self) = shift;
	my($filename) = @_;
	
	my($count_imported) = 0;
	my($count_skipped) = 0;
	
	my($chunk) = {};
	
	my($fd);
	
	my($import_chunk) = sub {
		# empty line
		my($res) = $self->import_chunk($chunk);
		
		given ($res) {
			when (undef) {
				# exception during processing - skipped
				$count_skipped++;
			}
			when (1) {
				# processed
				$count_imported++;
			}
			when (0) {
				# not a chunk - not counted
			}
		}
	};
	
	try {
		open($fd, '<:encoding(UTF-8)', $filename) || confess("Could not open file: $!");
		
		while (<$fd>) {
			chomp;
			
			if ($_) {
				my($key, $value) = split(': ', $_, 2);
				
				$chunk->{lc $key} = $value;
			} else {
				# empty line
				$import_chunk->();
				$chunk = {};
			}
		}
		
		$import_chunk->();
	} catch {
		confess("$_");
	} finally {
		close($fd);
	};
	
	return ($count_imported, $count_skipped);
}

sub import_chunk {
	my($self) = shift;
	my(@args) = @_;
	
	my($retcode);
	
	try {
		$retcode = $self->import_chunk_inner(@args);
	} catch {
		carp("$_");
		$retcode = undef;
	};
	
	return ($retcode);
}

sub import_chunk_inner {
	my($self) = shift;
	
	my($chunk) = @_;
	
	my($orig_chunk) = { %{$chunk} };
	
	if (%{$chunk}) {
		exists($chunk->{'title'})        || confess("Malformed record: no title. " . Dumper($orig_chunk));
		exists($chunk->{'format'})       || confess("Malformed record: no format. " . Dumper($orig_chunk));
		exists($chunk->{'release year'}) || confess("Malformed record: no release year. " . Dumper($orig_chunk));
		exists($chunk->{'stars'})        || confess("Malformed record: no stars. " . Dumper($orig_chunk));
		
		my($title)        = delete($chunk->{'title'});
		my($format)       = delete($chunk->{'format'});
		my($release_year) = delete($chunk->{'release year'});
		my(@stars)        = split(',', delete($chunk->{'stars'}));
		
		foreach (@stars) {
			$_ =~ s/^\s*(.*?)\s*$/$1/;
		}
		
		my($config) = $self->application->config;
		
		(!(%{$chunk})) || carp("Ignoring extraneous fields in record. ". Dumper($orig_chunk));
		
		looks_like_number($release_year) || confess("Malformed record: release year is not number. " . Dumper($orig_chunk));
		(($config->{release_year_min} <= $release_year) && ($release_year <= $config->{release_year_max})) || confess("Malformed record: release year is out of $config->{release_year_min}..$config->{release_year_max} range. " . Dumper($orig_chunk));
		
		my($movie) = MovieDB::Application::Database::Movie->new(
			application => $self->application,
			title => $title,
			release_year => $release_year,
			media_type => $format,
			actors => \@stars,
		);
		
		# my($id) = $movie->id;
		# say("Imported movie ($id)");
		
		return (1);
	}
	
	return (0);
}

__PACKAGE__->register();
