package MovieDB::Common;

use strict;
use warnings;
# use mro 'c3';
use feature ':5.10';
use Carp;
use Scalar::Util qw{blessed looks_like_number};
use Data::Dumper::Perltidy qw{Dumper};
use Try::Tiny;

require ToolSet;

use base 'ToolSet';

ToolSet->use_pragma('strict');
ToolSet->use_pragma('warnings');
# ToolSet->use_pragma('mro', 'c3');
ToolSet->use_pragma('feature', ':5.10');
ToolSet->export(
	'Carp' => q{carp croak confess cluck},
	'Scalar::Util' => q{blessed looks_like_number},
	'Data::Dumper::Perltidy' => q{Dumper},
	'Try::Tiny' => q{},
);

our @EXPORT = qw{};

1;
