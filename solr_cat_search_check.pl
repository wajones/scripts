#!/usr/bin/env perl

use warnings;
use strict;

use LWP::UserAgent;
use Data::Dumper;

my $success = 1;

my $query = { 'est1' => "",
              'est2' => "",
              'cst1' => "",
              'cst2' => "",
              'mst1' => "",
              'pst1' => "", };

my $ua = LWP::UserAgent->new();
$ua->timeout( 60 );

$query->{est1} =
  qq<solr/solr-est-ondeck3-pool/select/?sort=map(query({!dismax qf=Category_0107_WebAdMarketZones v='728'},0),0,0,0,1) desc,sum(product(map(query({!dismax qf=Category_0107_WebAdMarketZones v='728'},0),0,0,0,1),product(Category_0107_MeritScore,-1.0)),product(sub(1,map(query({!dismax qf=Category_0107_WebAdMarketZones v='728'},0),0,0,0,1)),csort(geodist(Location,39.727440,-85.881844),geodist(Category_0107_ReportLocations,39.727440,-85.881844),Category_0107_MemberReports,Category_0107_Grade,5,100.0))) asc,Category_0107_GradeDisplay asc,Category_0107_MemberReportRange desc,random_14 asc&fq=(IsExcluded:false)&fq=(MarketID:1)&fq={!tag=saf}(-MarketZonesServicedNot:728)&fq=CategoryID:107&fq={!tag=zro}(-Category_0107_MemberReports:0)&fq=(CategoryGroupTypeID:1) OR (CategoryGroupTypeID:2) OR (CategoryGroupTypeID:4)&rows=20&facet.field=Name_First_Character&facet.field=CategoryID&facet.field=CategoryGroupTypeID&facet.field=EcoFriendly&facet.field=AcceptsQuickQuotes&facet.field=AvailableForTalkNow&f.CategoryGroupTypeID.facet.mincount=1&f.CategoryID.facet.sort=count&f.CategoryID.facet.limit=20&facet=true&queryType=category_request&f.CategoryGroupTypeID.facet.sort=index&q=*:*&start=0&wt=json&f.Name_First_Character.facet.sort=index&srid=1cfe7980-4678-11e4-9975-12f101925702&f.CategoryID.facet.mincount=1&f.CategoryGroupTypeID.facet.limit=20&fl=*,score&f.Name_First_Character.facet.mincount=1&facet.query=(POHNominationsOverall:[1 TO *])&facet.query=(Category_0107_SSAMarkets:1)&facet.query=Category_0107_BigDealMarketZones:728 or Category_0107_PrepaidItemMarketZones:728 or Category_0107_PrepaidServiceMarketZones:728&facet.query=Category_0107_WebAdMarketZones:728>;

$query->{est2} =
  qq<solr/solr-est-ondeck4-pool/select/?sort=map(query({!dismax qf=Category_0107_WebAdMarketZones v='2520'},0),0,0,0,1) desc,sum(product(map(query({!dismax qf=Category_0107_WebAdMarketZones v='2520'},0),0,0,0,1),product(Category_0107_MeritScore,-1.0)),product(sub(1,map(query({!dismax qf=Category_0107_WebAdMarketZones v='2520'},0),0,0,0,1)),csort(geodist(Location,27.789679,-82.680748),geodist(Category_0107_ReportLocations,27.789679,-82.680748),Category_0107_MemberReports,Category_0107_Grade,5,100.0))) asc,Category_0107_GradeDisplay asc,Category_0107_MemberReportRange desc,random_4 asc&fq=(IsExcluded:false)&fq=(MarketID:21)&fq={!tag=saf}(-MarketZonesServicedNot:2520)&fq=CategoryID:107&fq={!tag=zro}(-Category_0107_MemberReports:0)&fq=(CategoryGroupTypeID:1) OR (CategoryGroupTypeID:2) OR (CategoryGroupTypeID:4)&rows=20&facet.field=Name_First_Character&facet.field=CategoryID&facet.field=CategoryGroupTypeID&facet.field=EcoFriendly&facet.field=AcceptsQuickQuotes&facet.field=AvailableForTalkNow&f.CategoryGroupTypeID.facet.mincount=1&f.CategoryID.facet.sort=count&f.CategoryID.facet.limit=20&facet=true&queryType=category_request&f.CategoryGroupTypeID.facet.sort=index&q=*:*&start=0&wt=json&f.Name_First_Character.facet.sort=index&srid=6a276cfe-4eec-11e4-9adf-0a7229a544ed&f.CategoryID.facet.mincount=1&f.CategoryGroupTypeID.facet.limit=20&fl=*,score&f.Name_First_Character.facet.mincount=1&facet.query=(POHNominationsOverall:[1 TO *])&facet.query=(Category_0107_SSAMarkets:21)&facet.query=Category_0107_BigDealMarketZones:2520 or Category_0107_PrepaidItemMarketZones:2520 or Category_0107_PrepaidServiceMarketZones:2520&facet.query=Category_0107_WebAdMarketZones:2520>;

$query->{cst1} =
  qq<solr/solr-cst-ondeck2-pool/select/?sort=map(query({!dismax qf=Category_0107_WebAdMarketZones v='1426'},0),0,0,0,1) desc,sum(product(map(query({!dismax qf=Category_0107_WebAdMarketZones v='1426'},0),0,0,0,1),product(Category_0107_MeritScore,-1.0)),product(sub(1,map(query({!dismax qf=Category_0107_WebAdMarketZones v='1426'},0),0,0,0,1)),csort(geodist(Location,32.934292,-97.078064),geodist(Category_0107_ReportLocations,32.934292,-97.078064),Category_0107_MemberReports,Category_0107_Grade,5,100.0))) asc,Category_0107_GradeDisplay asc,Category_0107_MemberReportRange desc,random_4 asc&fq=(IsExcluded:false)&fq=(MarketID:13)&fq={!tag=saf}(-MarketZonesServicedNot:1426)&fq=CategoryID:107&fq={!tag=zro}(-Category_0107_MemberReports:0)&fq=(CategoryGroupTypeID:1) OR (CategoryGroupTypeID:2) OR (CategoryGroupTypeID:4)&rows=20&facet.field=Name_First_Character&facet.field=CategoryID&facet.field=CategoryGroupTypeID&facet.field=EcoFriendly&facet.field=AcceptsQuickQuotes&facet.field=AvailableForTalkNow&f.CategoryGroupTypeID.facet.mincount=1&f.CategoryID.facet.sort=count&f.CategoryID.facet.limit=20&facet=true&queryType=category_request&f.CategoryGroupTypeID.facet.sort=index&q=*:*&start=0&wt=json&f.Name_First_Character.facet.sort=index&srid=81b652c6-4eed-11e4-910b-0a7229a544ed&f.CategoryID.facet.mincount=1&f.CategoryGroupTypeID.facet.limit=20&fl=*,score&f.Name_First_Character.facet.mincount=1&facet.query=(POHNominationsOverall:[1 TO *])&facet.query=(Category_0107_SSAMarkets:13)&facet.query=Category_0107_BigDealMarketZones:1426 or Category_0107_PrepaidItemMarketZones:1426 or Category_0107_PrepaidServiceMarketZones:1426&facet.query=Category_0107_WebAdMarketZones:1426>;

$query->{cst2} =
  qq<solr/solr-cst-ondeck3-pool/select/?sort=map(query({!dismax qf=Category_0107_WebAdMarketZones v='585'},0),0,0,0,1) desc,sum(product(map(query({!dismax qf=Category_0107_WebAdMarketZones v='585'},0),0,0,0,1),product(Category_0107_MeritScore,-1.0)),product(sub(1,map(query({!dismax qf=Category_0107_WebAdMarketZones v='585'},0),0,0,0,1)),csort(geodist(Location,42.026066,-87.727112),geodist(Category_0107_ReportLocations,42.026066,-87.727112),Category_0107_MemberReports,Category_0107_Grade,5,100.0))) asc,Category_0107_GradeDisplay asc,Category_0107_MemberReportRange desc,random_12 asc&fq=(IsExcluded:false)&fq=(MarketID:7)&fq={!tag=saf}(-MarketZonesServicedNot:585)&fq=CategoryID:107&fq={!tag=zro}(-Category_0107_MemberReports:0)&fq=(CategoryGroupTypeID:1) OR (CategoryGroupTypeID:2) OR (CategoryGroupTypeID:4)&rows=20&facet.field=Name_First_Character&facet.field=CategoryID&facet.field=CategoryGroupTypeID&facet.field=EcoFriendly&facet.field=AcceptsQuickQuotes&facet.field=AvailableForTalkNow&f.CategoryGroupTypeID.facet.mincount=1&f.CategoryID.facet.sort=count&f.CategoryID.facet.limit=20&facet=true&queryType=category_request&f.CategoryGroupTypeID.facet.sort=index&q=*:*&start=0&wt=json&f.Name_First_Character.facet.sort=index&srid=cc713f92-4eed-11e4-978e-0a316cf4f350&f.CategoryID.facet.mincount=1&f.CategoryGroupTypeID.facet.limit=20&fl=*,score&f.Name_First_Character.facet.mincount=1&facet.query=(POHNominationsOverall:[1 TO *])&facet.query=(Category_0107_SSAMarkets:7)&facet.query=Category_0107_BigDealMarketZones:585 or Category_0107_PrepaidItemMarketZones:585 or Category_0107_PrepaidServiceMarketZones:585&facet.query=Category_0107_WebAdMarketZones:585>;

$query->{mst1} =
  qq<solr/solr-mst-ondeck1-pool/select/?sort=map(query({!dismax qf=Category_0107_WebAdMarketZones v='4052'},0),0,0,0,1) desc,sum(product(map(query({!dismax qf=Category_0107_WebAdMarketZones v='4052'},0),0,0,0,1),product(Category_0107_MeritScore,-1.0)),product(sub(1,map(query({!dismax qf=Category_0107_WebAdMarketZones v='4052'},0),0,0,0,1)),csort(geodist(Location,40.596416,-111.827049),geodist(Category_0107_ReportLocations,40.596416,-111.827049),Category_0107_MemberReports,Category_0107_Grade,5,100.0))) asc,Category_0107_GradeDisplay asc,Category_0107_MemberReportRange desc,random_12 asc&fq=(IsExcluded:false)&fq=(MarketID:54)&fq={!tag=saf}(-MarketZonesServicedNot:4052)&fq=CategoryID:107&fq={!tag=zro}(-Category_0107_MemberReports:0)&fq=(CategoryGroupTypeID:1) OR (CategoryGroupTypeID:2) OR (CategoryGroupTypeID:4)&rows=20&facet.field=Name_First_Character&facet.field=CategoryID&facet.field=CategoryGroupTypeID&facet.field=EcoFriendly&facet.field=AcceptsQuickQuotes&facet.field=AvailableForTalkNow&f.CategoryGroupTypeID.facet.mincount=1&f.CategoryID.facet.sort=count&f.CategoryID.facet.limit=20&facet=true&queryType=category_request&f.CategoryGroupTypeID.facet.sort=index&q=*:*&start=0&wt=json&f.Name_First_Character.facet.sort=index&srid=bc5e582e-4eed-11e4-93a9-0e41a48739b4&f.CategoryID.facet.mincount=1&f.CategoryGroupTypeID.facet.limit=20&fl=*,score&f.Name_First_Character.facet.mincount=1&facet.query=(POHNominationsOverall:[1 TO *])&facet.query=(Category_0107_SSAMarkets:54)&facet.query=Category_0107_BigDealMarketZones:4052 or Category_0107_PrepaidItemMarketZones:4052 or Category_0107_PrepaidServiceMarketZones:4052&facet.query=Category_0107_WebAdMarketZones:4052>;

$query->{pst1} =
  qq<solr/solr-pst-ondeck1-pool/select/?sort=map(query({!dismax qf=Category_0107_WebAdMarketZones v='2953'},0),0,0,0,1) desc,sum(product(map(query({!dismax qf=Category_0107_WebAdMarketZones v='2953'},0),0,0,0,1),product(Category_0107_MeritScore,-1.0)),product(sub(1,map(query({!dismax qf=Category_0107_WebAdMarketZones v='2953'},0),0,0,0,1)),csort(geodist(Location,45.487411,-122.687553),geodist(Category_0107_ReportLocations,45.487411,-122.687553),Category_0107_MemberReports,Category_0107_Grade,5,100.0))) asc,Category_0107_GradeDisplay asc,Category_0107_MemberReportRange desc,random_9 asc&fq=(IsExcluded:false)&fq=(MarketID:28)&fq={!tag=saf}(-MarketZonesServicedNot:2953)&fq=CategoryID:107&fq={!tag=zro}(-Category_0107_MemberReports:0)&fq=(CategoryGroupTypeID:1) OR (CategoryGroupTypeID:2) OR (CategoryGroupTypeID:4)&rows=20&facet.field=Name_First_Character&facet.field=CategoryID&facet.field=CategoryGroupTypeID&facet.field=EcoFriendly&facet.field=AcceptsQuickQuotes&facet.field=AvailableForTalkNow&f.CategoryGroupTypeID.facet.mincount=1&f.CategoryID.facet.sort=count&f.CategoryID.facet.limit=20&facet=true&queryType=category_request&f.CategoryGroupTypeID.facet.sort=index&q=*:*&start=0&wt=json&f.Name_First_Character.facet.sort=index&srid=6d823536-4eed-11e4-ae35-0ab0e2d1dfc0&f.CategoryID.facet.mincount=1&f.CategoryGroupTypeID.facet.limit=20&fl=*,score&f.Name_First_Character.facet.mincount=1&facet.query=(POHNominationsOverall:[1 TO *])&facet.query=(Category_0107_SSAMarkets:28)&facet.query=Category_0107_BigDealMarketZones:2953 or Category_0107_PrepaidItemMarketZones:2953 or Category_0107_PrepaidServiceMarketZones:2953&facet.query=Category_0107_WebAdMarketZones:2953>;

open my $fh, '>', '/tmp/category_search_check';

foreach my $tz ( keys %$query )
  {
    my $url      = "http://solr10.angieslist.com:8983/" . $query->{$tz};
    my $response = $ua->get( $url );
    $success  = 1;
    my $length   = 0;

    if ( $response->is_success )
      {
        $length = length( $response->{_content} );
        $success &&= ( $length > 1000000 );
        print $fh "$tz  $length\n";
      }
    else
      {
        $success = 0;
        print $fh "$tz  FAILED\n";
      }
  }

print $fh "$success\n";

close $fh;

