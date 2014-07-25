#!/usr/bin/env perl

sub _convert_to_bool
  {
	my ( $value ) = @_;
	
	if ( !defined $value ) { $value = 0; }
	$value = 0 if ( $value =~ /^f/i || $value =~ /^n/i );
	$value = 1 if ( $value =~ /^t/i || $value =~ /^y/i );
	$value = ( $value != 0 && $value != 1 ) ? 0 : $value;
  }

foreach my $original ( qw/true True false False TRUE FALSE Y N Yes No YES NO 1 0/ )
  {
    my $new = _convert_to_bool( $original );
    print "Original:  $original\tNew:  $new\n";
  }

undef $original;
my $new = _convert_to_bool( $original );
print "Original:  $original\tNew:  $new\n";

