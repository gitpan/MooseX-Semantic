#!/usr/bin/perl 
#=======================================================================
#         FILE:  test.pl
#  DESCRIPTION:  
#       AUTHOR:  Konstantin Baierer (kba), konstantin.baierer@gmail.com
#      CREATED:  12/09/2011 12:33:53 AM
#=======================================================================
use common::sense;
use Data::Dumper;
use Carp;
use PAR 'moosex-semantic.par';
use MooseX::Semantic::Test::Person;

my $p = MooseX::Semantic::Test::Person->new;


1;
