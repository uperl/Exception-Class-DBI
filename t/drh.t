#!/usr/bin/perl -w

# $Id: drh.t,v 1.4 2002/08/22 16:10:24 david Exp $

use strict;
use Test::More (tests => 21);
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
    DBI->connect('dbi:ExampleP:dummy', '', '',
                 { PrintError => 0,
                   RaiseError => 0,
                   HandleError => Exception::Class::DBI->handler
                 });
};

SKIP: {
    skip 'HandleError not logic not yet used by DBI->connect', 20
      unless $@;
    ok( my $err = $@, "Caught exception" );
    isa_ok( $err, 'Exception::Class::DBI' );
    isa_ok( $err, 'Exception::Class::DBI::H' );
    isa_ok( $err, 'Exception::Class::DBI::DRH' );
    ok( $err->err == 7, "Check err" );
    is( $err->error,
        'DBI->connect(dummy) failed: Dammit Jim!', 'Check error' );
    is( $err->errstr, 'Dammit Jim!', 'Check errstr' );
    is( $err->state, 'ABCDE', 'Check state' );
    ok( ! defined $err->retval, "Check retval" );
    ok( $err->warn == 1, "Check warn" );
    ok( $err->active == 1, "Check active" );
    ok( $err->kids == 0, "Check kids" );
    ok( $err->active_kids == 0, "Check acitive_kids" );
    ok( ! $err->inactive_destroy, "Check inactive_destroy" );
    ok( $err->trace_level == 0, "Check trace_level" );
    is( $err->fetch_hash_key_name, 'NAME', "Check fetch_hash_key_name" );
    ok( ! $err->chop_blanks, "Check chop_blanks" );
    ok( $err->long_read_len == 80, "Check long_read_len" );
    ok( ! $err->long_trunc_ok, "Check long_trunc_ok" );
    ok( ! $err->taint, "Check taint" );
}
