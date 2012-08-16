package MovieDB::Set;

use MovieDB::Common;

sub set {
	my($keys) = @_;
	
	my(%union);
	
	@union{@{$keys}} = ();
	
	return \%union;
}

sub add {
	my($set1, $set2) = @_;
	
	return set([keys(%{$set1}), keys(%{$set2})]);
}

sub subtract {
	my($set1, $set2) = @_;
	
	return set([grep { !exists($set2->{$_}) } keys(%{$set1})]);
}

1
