#!/usr/bin/env perl

use strict;
use warnings;

use Net::Amazon::EC2;
use Try::Tiny;
use Config::Tiny;
use Template;
use List::Compare;
use Data::Dumper;

my $config = Config::Tiny->new;
$config = Config::Tiny->read( 'server_data.config' );

my $logfile = $config->{log}{file};
open my $fh, '>>', $logfile or die "Can't open logfile\n";

my @existing_ips = ();
if ( -e $config->{existing_ips}{file} )
  {
    open my $fh1, '<', $config->{existing_ips}{file};
    if ( $fh1 )
      {
        @existing_ips = <$fh1>;
      }
    close $fh1;
  }

my $server_list = $config->{server_groups}->{name};
my @servers = split /,/, $server_list;

foreach my $server ( @servers )
  {
    $server =~ s/[.]/\\./;
  }

my $ec2 = Net::Amazon::EC2->new(
                          AWSAccessKeyId  => $config->{Amazon}{AWSAccessKeyId},
                          SecretAccessKey => $config->{Amazon}{SecretAccessKey},
);

my $instances    = $ec2->describe_instances;
print Dumper($instances); exit;

my $server_count = 1;

my ( $instance_list, $_server );

foreach my $instance ( @$instances )
  {
    foreach my $instances_set ( @{ $instance->instances_set } )
      {
        next if ( $instances_set->instance_state->code =~ /32|48/ );
        try
        {
            foreach my $tag_set ( @{ $instances_set->tag_set } )
              {
                my $continue = 0;
                next unless ( $tag_set->key eq "Name" );
                foreach my $server ( @servers )
                  {
                    $continue = 1 if ( $tag_set->value =~ /^$server/ );
                    $_server = $server;
                    last if $continue;
                  }
                $instance_list->{ chomp $instances_set->private_ip_address } = {
                                        'server' => $_server,
                                        'name'   => $tag_set->value,
                                        'size' => $instances_set->instance_type,
                  }
                  if ( $continue );
              }
        }
        catch
        {
            print $fh Dumper( $instance ) . "\n";
        };
      }
  }

	print Dumper( $instance_list ); print "\n\n";
	
my $restart_needed = 0;
my @all_ips        = keys %$instance_list;
my $lc             = List::Compare->new( \@all_ips, \@existing_ips );
my @new_ips        = $lc->get_Lonly;
my @delete_ips     = $lc->get_Ronly;
my @record_ips;

print "All IPS:\n"; print Dumper(@all_ips); print "\n\n";
print "New IPS:\n"; print Dumper(@new_ips); print "\n\n";
print "Del IPS:\n"; print Dumper(@delete_ips); print "\n\n";

foreach my $ip ( @all_ips )
  {
		chomp $ip;
    my $server_class = $instance_list->{$ip}{server};
    $server_class =~ s/\\//g;

    next unless ( $config->{$server_class} );

    push @record_ips, $ip;
  }

open my $fh2, '>', $config->{existing_ips}{file};
foreach my $ip ( @record_ips )
  {
    print $fh2 $ip . "\n";
  }
close $fh2;
exit;

foreach my $ip ( @delete_ips )
  {
    my $server_class = $instance_list->{$ip}{server};
		$server_class =~ s/\\//g;

    my $file_name =
      '/usr/local/nagios/etc/dynamic_hosts/' . "$server_class\_$ip.cfg";
    unlink $file_name if ( -e $file_name );
    $restart_needed = 1;
  }

foreach my $ip ( @new_ips )
  {
    $restart_needed = 1;

    my $server_class = $instance_list->{$ip}{server};
    $server_class =~ s/\\//g;

    next unless ( $config->{$server_class} );

    my $tt;

    try
    {
        $tt = Template->new( { INCLUDE_PATH => $config->{TT}{root},
                               EVAL_PERL    => 1,
                               POST_CHOMP   => 1,
                             } );
    }
    catch
    {
        die Template->error(), "\n";
    };

    my $warning =
      ( defined $config->{$server_class}->{warning} )
      ? $config->{$server_class}->{warning}
      : 5;
    my $critical =
      ( defined $config->{$server_class}->{critical} )
      ? $config->{$server_class}->{critical}
      : 10;
    $critical = "$critical\n";

    my $params = { server_class => $server_class,
                   ip           => "$ip\n",
                   description  => "$config->{ $server_class }->{template}\n",
                   secure       => "$config->{ $server_class }->{secure}",
                   port         => "$config->{ $server_class }->{port}",
                   test         => "$config->{ $server_class }->{test}",
                   warning      => $warning,
                   critical     => $critical, };

    try
    {

        $tt->process( "$config->{ $server_class }->{test}.tt",
                      $params, "$server_class\_$ip.cfg" );
    }
    catch
    {
        die $tt->error(), "\n";
    };
  }

END
{
    close $fh;
    system( "/etc/init.d/nagios", "restart" ) if ( $restart_needed );
}

#my $longest_value = 0;
#while ( ( my $key, my $value ) = each %$instance_list )
#  {
#    if ( length( $value->{name} ) > $longest_value )
#      {
#        $longest_value = length( $value->{name} );
#      }
#  }

#foreach ( sort { $instance_list->{$a}{name} cmp $instance_list->{$b}{name} }
#          keys %$instance_list )
#  {
#		print '"' . $instance_list->{$_}{name} . '",' . '"' . $_ . '",' . '"' . $instance_list->{$_}{size} . '"' . "\n";
#    my $padding_length =
#      $longest_value - length( $instance_list->{$_}{name} );
#    my $padding = " " x $padding_length;
#    print "$instance_list->{ $_ }{name}"
#      . "$padding" . " $_" . "\t\t"
#      . $instance_list->{$_}{size} . "\n";
#  }

