#!/usr/bin/perl -w

use strict;
use Test::More (tests => 27);
BEGIN { use_ok('Exception::Class::DBI') }
use DBI;

ok( my $dbh = DBI->connect('dbi:Pg:dbname=template1', '', '',
                           { PrintError => 0,
                             RaiseError => 0,
                             HandleError => Exception::Class::DBI->error_handler
                           }),
    "Connect to database" );

END { $dbh->disconnect if $dbh };

# Check that the error_handler has been installed.
ok( UNIVERSAL::isa($dbh->{HandleError}, 'CODE'), "Check HandlError" );

# Trigger an exception.
eval {
    $dbh->do('select foo from foo');
};

# Make sure we got the proper exception.
ok( my $err = $@, "Get exception" );
ok( UNIVERSAL::isa($err, 'Exception::Class::DBI'), "Check E::C::DBI" );
ok( UNIVERSAL::isa($err, 'Exception::Class::DBI::H'),
    "Check E::C::DBI::H" );
ok( UNIVERSAL::isa($err, 'Exception::Class::DBI::DBH'),
    "Check E::C::DBI::DBH" );

# Check the accessor values.
ok( $err->err == 7, "Check err" );
is( $err->errstr, 'ERROR:  Relation "foo" does not exist',
    "Check errstr" );
is( $err->error, 'DBD::Pg::db do failed: ERROR:  Relation "foo" does not exist',
    "Check errstr" );
is( $err->state, 'S1000', "Check state" );
ok( ! defined $err->retval, "Check retval" );
ok( $err->warn == 1, "Check warn" );
ok( $err->active == 1, "Check active" );
ok( $err->kids == 0, "Check kids" );
ok( $err->active_kids == 0, "Check acitive_kids" );
is( $err->inactive_destroy, '', "Check inactive_destroy" );
ok( $err->trace_level == 0, "Check trace_level" );
is( $err->fetch_hash_key_name, 'NAME', "Check fetch_hash_key_name" );
is( $err->chop_blanks, '', "Check chop_blanks" );
ok( $err->long_read_len == 80, "Check long_read_len" );
is( $err->long_trunc_ok, '', "Check long_trunc_ok" );
is( $err->taint, '', "Check taint" );
ok( $err->auto_commit == 1, "Check auto_commit" );
is( $err->db_name, 'template1', "Check db_name" );
is( $err->statement, 'select foo from foo', "Check db_name" );
ok( ! defined $err->row_cache_size, "Check row_cache_size" );
