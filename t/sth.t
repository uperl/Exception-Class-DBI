#!/usr/bin/perl -w

use strict;
use Test::More (tests => 35);
BEGIN { use_ok('Exception::Class::DBI') }
use DBI;


#ok( my $dbh = DBI->connect('dbi:ExampleP:dummy', '', '',
ok( my $dbh = DBI->connect('dbi:Pg:dbname=template1', 'postgres', '',
                           { PrintError => 0,
                             RaiseError => 0,
                             HandleError => Exception::Class::DBI->handler
                           }),
    "Connect to database" );

END { $dbh->disconnect if $dbh };

# Check that the error_handler has been installed.
ok( UNIVERSAL::isa($dbh->{HandleError}, 'CODE'), "Check HandlError" );

# Trigger an exception.
eval {
    my $sth = $dbh->prepare("select * from foo");
    $sth->execute;
};

diag "Exception: $@";

# Make sure we got the proper exception.
ok( my $err = $@, "Get exception" );
ok( UNIVERSAL::isa($err, 'Exception::Class::DBI'), "Check E::C::DBI" );
ok( UNIVERSAL::isa($err, 'Exception::Class::DBI::H'),
    "Check E::C::DBI::H" );
ok( UNIVERSAL::isa($err, 'Exception::Class::DBI::STH'),
    "Check E::C::DBI::STH" );

ok( $err->err == 7, "Check err" );
is( $err->errstr, 'ERROR:  Relation "foo" does not exist',
    "Check errstr" );
is( $err->error,
    'DBD::Pg::st execute failed: ERROR:  Relation "foo" does not exist',
    "Check error" );
is( $err->state, 'S1000', "Check state" );
ok( ! defined $err->retval, "Check retval" );

ok( $err->warn == 1, 'Check warn' );
ok( !$err->active, 'Check active' );
ok( $err->kids == 0, 'Check kids' );
ok( $err->active_kids == 0, 'Check active_kids' );
ok( ! $err->compat_mode, 'Check compat_mode' );
ok( ! $err->inactive_destroy, 'Check inactive_destroy' );
ok( $err->trace_level == 0, 'Check trace_level' );
is( $err->fetch_hash_key_name, 'NAME', 'Check fetch_hash_key_name' );
ok( ! $err->chop_blanks, 'Check chop_blanks' );
ok( $err->long_read_len == 80, 'Check long_read_len' );
ok( ! $err->long_trunc_ok, 'Check long_trunc_ok' );
ok( ! $err->taint, 'Check taint' );
ok( $err->num_of_fields == 0, 'Check num_of_fields' );
ok( $err->num_of_params == 0, 'Check num_of_params' );
is( ref $err->field_names, 'ARRAY', "Check field_names" );
is( ref $err->type, 'ARRAY', "Check type" );
is( ref $err->precision, 'ARRAY', "Check precision" );
is( ref $err->scale, 'ARRAY', "Check scale" );
is( ref $err->nullable, 'ARRAY', "Check nullable" );
ok( ! defined $err->cursor_name, "Check cursor_name" );
ok( ! defined $err->param_values, "Check praram_values" );
is( $err->statement, 'select * from foo', 'Check statement' );
ok( ! defined $err->rows_in_cache, "Check rows_in_cache" );
