#!/usr/bin/perl -w

# $Id: Makefile.PL,v 1.3 2002/08/22 16:10:24 david Exp $

use strict;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Exception::Class::DBI',
    'VERSION_FROM'	=> 'lib/Exception/Class/DBI.pm', # finds $VERSION
    'PREREQ_PM'		=> { 'Exception::Class' => 1.03,
                             'DBI' => 1.28
                           }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'lib/Exception/Class/DBI.pm', # retrieve abstract from module
       AUTHOR     => 'David Wheeler <david@wheeler.net>') : ()),
);
