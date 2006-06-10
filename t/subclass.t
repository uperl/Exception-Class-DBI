#!/usr/bin/perl -w

use strict;
use Test::More tests => 9;
BEGIN { use_ok('Exception::Class::DBI') }

SUBCLASSES: {
    package MyApp::Ex::DBI;
    use base 'Exception::Class::DBI';

    package MyApp::Ex::DBI::H;
    use base 'MyApp::Ex::DBI', 'Exception::Class::DBI::H';

    package MyApp::Ex::DBI::DRH;
    use base 'MyApp::Ex::DBI', 'Exception::Class::DBI::DRH';

    package MyApp::Ex::DBI::DBH;
    use base 'MyApp::Ex::DBI', 'Exception::Class::DBI::DBH';

    package MyApp::Ex::DBI::STH;
    use base 'MyApp::Ex::DBI', 'Exception::Class::DBI::STH';

    package MyApp::Ex::DBI::Unknown;
    use base 'MyApp::Ex::DBI', 'Exception::Class::DBI::Unknown';
}

use DBI;

ok my $dbh = DBI->connect('dbi:ExampleP:dummy', '', '', {
    PrintError  => 0,
    RaiseError  => 0,
    HandleError => MyApp::Ex::DBI->handler,
}), 'Connect to database';

END { $dbh->disconnect if $dbh };

# Check that the error_handler has been installed.
isa_ok $dbh->{HandleError}, 'CODE', 'The HandleError attribute';

# Trigger an exception.
eval {
    my $sth = $dbh->prepare("select * from foo");
    $sth->execute;
};

# Make sure we got the proper exception.
ok my $err = $@, 'Catch exception';
isa_ok $err, 'Exception::Class::DBI', 'The exception';
isa_ok $err, 'Exception::Class::DBI::H', 'The exception';
isa_ok $err, 'Exception::Class::DBI::STH', 'The exception';
isa_ok $err, 'MyApp::Ex::DBI::STH', 'The exception';
isa_ok $err, 'MyApp::Ex::DBI', 'The exception';
