#!/usr/bin/perl -w

# $Id: dbi.t,v 1.1 2002/08/22 17:33:47 david Exp $

use strict;
use Test::More (tests => 8);
BEGIN { use_ok('Exception::Class::DBI') }
use DBI;

{
    # Fake out DBD::ExampleP's connect method. Take the opportunity
    # to set the dynamic attributes.
    use DBD::ExampleP;
    local $^W;
    *DBD::ExampleP::dr::connect =
      sub { $_[0]->set_err(7, 'Dammit Jim!', 'ABCDE') };
}

eval {
    DBI->connect('dbi:Bogus', '', '',
                 { PrintError => 0,
                   RaiseError => 0,
                   HandleError => Exception::Class::DBI->handler
                 });
};

ok( my $err = $@, "Caught exception" );
SKIP: {
    skip 'HandleError not logic not yet used by DBI->connect', 6
      unless ref $@;
    isa_ok( $err, 'Exception::Class::DBI' );
    like( $err->error, qr{Can't connect\(dbi:Bogus   HASH\([^\)]+\)\), no database driver specified and DBI_DSN env var not set},
          "Check error" );
    ok( ! defined $err->err, "Check err" );
    ok( ! defined $err->errstr, "Check errstr" );
    ok( ! defined $err->state, "Check state" );
    ok( ! defined $err->retval, "Check retval" );
}
