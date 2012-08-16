package MovieDB::Application::Database::Object;

use MovieDB::Common;
use parent qw{MovieDB::Object};

sub id { shift->{id} }
sub name { shift->{name} }
sub title { shift->{title} }
sub release_year { shift->{release_year} }
sub media_type { shift->{media_type} }
sub actors { shift->{actors} }

1;
