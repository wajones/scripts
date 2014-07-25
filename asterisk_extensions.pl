#!/usr/bin/env perl

open BULK, ">asterisk_bulk_file.txt" || die "Can't open file asterisk_bulk_file.txt";

foreach ( 700..899 )
  {
	print BULK "$_,$_,h6A.$_,$_,1111,voicemails\@insuranceagents.com\n";
  }

close BULK;
