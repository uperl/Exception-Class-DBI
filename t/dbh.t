#!/usr/bin/perl -w

# $Id: dbh.t,v 1.5 2002/09/17 03:32:47 david Exp $

use strict;
use Test::More (tests => 27);
BEGIN { use_ok('Exception::Class::DBI') }
use DBI;

ok( my $dbh = DBI->connect('dbi:ExampleP:dummy', '', '',
                           { PrintError => 0,
                             RaiseError => 0,
                             HandleError => Exception::Class::DBI->handler
                           }),
    "Connect to database" );

END { $dbh->disconnect if $dbh };

# Check that the error_handler has been installed.
isa_ok( $dbh->{HandleError}, 'CODE' );

# Trigger an exception.
eval {
    $dbh->do('select foo from foo');
};

# Make sure we got the proper exception.
ok( my $err = $@, "Get exception" );
isa_ok( $err, 'Exception::Class::DBI' );
isa_ok( $err, 'Exception::Class::DBI::H' );
isa_ok( $err, 'Exception::Class::DBI::DBH' );

# Check the accessor values.
ok( $err->err == 1, "Check err" );
is( $err->errstr, 'Unknown field names: foo', "Check errstr" );
is( $err->error, 'DBD::ExampleP::db do failed: Unknown field names: foo',
    "Check error" );
is( $err->state, 'S1000', "Check state" );
ok( ! defined $err->retval, "Check retval" );
ok( $err->warn == 1, "Check warn" );
ok( $err->active == 1, "Check active" );
# For some reason, under perl < 5.8.0, $dbh->{Kids} returns a different value
# inside the HandleError scope than it does outside that scope. So we're
# checking for the perl version here to cover our butts on this test. This may
# be fixed in the DBI soon. I'm using the old form of the Perl version number
# as it seems safer with older Perls.
#ok( $err->kids == ($^V lt v5.8 ? 1 : 0), "Check kids" );
ok( $err->kids == ($] < 5.008 ? 1 : 0), "Check kids" );
ok( $err->active_kids == 0, "Check active_kids" );
ok( ! $err->inactive_destroy, "Check inactive_destroy" );
ok( $err->trace_level == 0, "Check trace_level" );
is( $err->fetch_hash_key_name, 'NAME', "Check fetch_hash_key_name" );
ok( ! $err->chop_blanks, "Check chop_blanks" );
ok( $err->long_read_len == 80, "Check long_read_len" );
ok( ! $err->long_trunc_ok, "Check long_trunc_ok" );
ok( ! $err->taint, "Check taint" );
ok( $err->auto_commit, "Check auto_commit" );
is( $err->db_name, 'dummy', "Check db_name" );
is( $err->statement, 'select foo from foo', "Check statement" );
ok( ! defined $err->row_cache_size, "Check row_cache_size" );
