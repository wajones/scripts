#!/usr/bin/env perl

use warnings;
use strict;

use DBI;

my $dbh = DBI->connect("dbi:mysql:database=leads;host=192.168.49.111;port=3306", "bjones", "Blue Bison");
#my $dbh = DBI->connect("dbi:mysql:database=leads;host=localhost;port=3306", "bjones", "Blue3616Bison");

my $field = { 3 => ['model_year'],
              4 => ['violation_0_year','violation_1_year','violation_2_year','violation_3_year'],
              5 => ['claim_0_year','claim_1_year','claim_2_year','claim_3_year'],
              8 => ['claim_0_year','claim_1_year','claim_2_year','claim_3_year','year_built'],
              10 => ['claim_0_year','claim_1_year','claim_2_year','claim_3_year','year_built'], };

my $sth = $dbh->prepare( "insert into validation_fields (record_type_id, field_name, min_occurs, max_occurs, validation_type, rule, enumeration, canonical_enumeration)
                          values ( ?, ?, ?, ?, ?, ?, ?, ? )");

foreach my $record_type_id ( keys %$field )
  {
    foreach my $field ( @{$field->{$record_type_id}} )
      {
        $sth->execute( $record_type_id, "$field", 0, 0, "year", "", "2012", "2012");
      }
  }

