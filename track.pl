#!/usr/bin/env perl

use strict;
use warnings;

use MIME::Lite;
use CGI;

my $q = new CGI;
my $vars = $q->Vars;

my $smtp = MIME::Lite->new(
  From => '"Nationwide Blast" <nationwide@insuranceagents.com>',
  To   => 'moverstreet@insuranceagents.com';
  Subject => "Nationwide -- Phone $vars->{p}  Email $vars->{e}";
  Type => 'TEXT',
  Data => "Phone:  $vars->{p}\nEmail:  $vars->{e}\n", );
$smtp->send( "smtp", 'smtp1.insuranceagents.com' );

1;

