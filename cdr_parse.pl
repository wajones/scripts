#!/usr/bin/env perl

use Data::Dumper;

open FILE, "/Users/bjones/Downloads/cdrreport.csv" or die "Can't open file: $!";

my $data;
my $id = 0;
my $first_line = 1;
my @headers = qw(date source destination source_channel destination_channel status duration recording);
while (<FILE>)
  {
	if ( $first_line ) { $first_line = 0; next; }
	chomp;
	my %cdr;
	my @fields = split ',', $_;
	@fields = map{ chomp; s/"//g; s/^\s+//; s/\s+$//; $_ } @fields;
	@cdr{@headers} = @fields;
	$data->{$id} = \%cdr;
	$id++;
  }

foreach my $key ( sort {$a <=> $b} keys %$data )
  {
	$data->{$key}{day} = substr( $data->{$key}{date}, 0, 10 );
	next if ( $data->{$key}{destination} eq '*97' );
	if (    $data->{$key}{source} eq '8772253239' 
		 && ( $data->{$key}{destination} eq 's' || $data->{$key}{destination} =~ /\d{7,12}/ ) )
	  {
		$data->{$key}{source_channel} =~ /SIP\/(\d{3})\-.*/;
		my $extension = $1;
		$data->{$key}{extension} = $extension; 
	  }
	if ( $data->{$key}{destination} =~ /\d{3}/ )
	  {
		$data->{$key}{destiantion_channel} =~ /SIP\/(\d{3})\-.*/;
		$data->{$key}{extension} = $1;
	  }
  }

my $count;
foreach my $key ( keys %$data )
  {
	my $extension = $data->{$key}{extension} || 0;
	my $date      = $data->{$key}{day} || '0000-00-00';
	$count->{$extension}{$date}{date} = $date;
	$count->{$extension}{$date}{number}++;
	$count->{$extension}{$date}{duration} += $data->{$key}{duration};
  }

foreach my $extension ( sort { $a <=> $b } keys %$count )
  {
	foreach my $date ( keys %{$count->{$extension}} )
	  {
		my $average = $count->{$extension}{$date}{duration} / $count->{$extension}{$date}{number};
		$average = sprintf( "%0.2f", $average );
		print "$extension,\"$date\",$count->{$extension}{$date}{number},$count->{$extension}{$date}{duration},$average\n";
	  }
  }
