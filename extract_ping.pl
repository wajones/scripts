#!/usr/bin/env perl

use warnings;
use strict;
use XML::Simple;

my $xml = $ARGV[0] || die "Need to provide XML on command line";
my $clean_xml = unscrubXMLData( $xml );

my $data = XML::Simple->new->XMLin( $clean_xml );
my $xml_out = XML::Simple->new->XMLout( $data, AttrIndent => 1, RootName => 'lead_auto', NoAttr => 1 );

print $xml_out;

sub unscrubXMLData                                                                                                  
  {                                                                                  
    my $var = shift;                                                                 
                                                                                     
    unscrubData( $var );                                                             
    $var =~ s/^<.*?><lead_/<lead_/;                                                  
    $var =~ s/<lead_(\w+?) .*?>/<lead_$1>/;                                          
    #$var =~ s|<distribution.*?\/>||g;                                               
    $var =~ s/\\//g;                                                                 
                                                                                     
    return $var;                                                                     
  }

sub unscrubData                                                                      
  {                                                                                  
    my $data = shift;                                                                
                                                                                     
    if ( $data && ( my $type = ref( $data ) ) )                                      
      {                                                                              
        if ( $type eq 'HASH' )                                                       
          {                                                                          
            foreach my $key ( keys %$data )                                          
              {                                                                      
                $data->{$key} =~ s/\\(.)/$1/g;                                       
              }                                                                      
          }                                                                          
        elsif ( $type eq 'ARRAY' )                                                   
          {                                                                          
            for ( 0 .. @$data - 1 )                                                  
              {                                                                      
                $data->[ $_ ] =~ s/\\(.)/$1/g;                                       
              }                                                                      
          }                                                                          
        elsif ( $type eq 'SCALAR' )                                                  
          {                                                                          
            $$data =~ s/\\(.)/$1/g;                                                  
          }                                                                          
        else                                                                         
          {                                                                          
                                                                                     
            # Unknown reference type                                                 
            warn "Cannot unscrub data for a reference of type $type";                
          }                                                                          
      }                                                                              
    else                                                                             
      {                                                                              
        $data ||= "";                                                                
        $data =~ s/\\(.)/$1/g;                                                       
      }                                                                              
                                                                                     
    return $data;                                                                    
  }

