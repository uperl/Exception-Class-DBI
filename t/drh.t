#!/usr/bin/perl -w

use strict;
use Test::More (tests => 5);
BEGIN { use_ok('Exception::Class::DBI') }
use DBI;

eval {
    DBI->connect('dbi:dummy', '', '',
                 { PrintError => 0,
                   RaiseError => 0,
                   HandleError => Exception::Class::DBI->error_handler
                 });
};

ok( my $err = $@, "Caught exception" );
TODO: {
    local $TODO = 'HandleError not implemented in DBI';
    ok( UNIVERSAL::isa($err, 'Exception::Class::DBI'), "Check E::C::DBI" );
    ok( UNIVERSAL::isa($err, 'Exception::Class::DBI::H'),
        "Check E::C::DBI::H" );
    ok( UNIVERSAL::isa($err, 'Exception::Class::DBI::DRH'),
        "Check E::C::DBI::DRH" );
    # Add code here to check basic properties.
}
