#!/usr/bin/perl

use strict;
use Data::Dumper;
use File::Path qw(remove_tree);

my ( %files_to_skip, @delete_these );

while ( <> )
  {
    chomp;
    next unless /^index=(.*)$/;
    $files_to_skip{$1} = undef;
  }
$files_to_skip{'.'}  = undef;    # Skip .
$files_to_skip{'..'} = undef;    # Skip ..

opendir( my $dir_handle, '.' ) || die "Could not open .: $!";
while ( my $dir_entry = readdir( $dir_handle ) )
  {
    next if exists $files_to_skip{$dir_entry};
    push @delete_these, $dir_entry;
  }
closedir( $dir_handle );

my ( $errors, $result );
remove_tree( @delete_these,
             {  errors    => \$errors,
                result    => \$result,
                keep_root => 0
             } );
print "errors are (", Dumper( $errors ), ")\n" if $errors && @{$errors};
print "result is  (", Dumper( $result ), ")\n" if $result && @{$result};
