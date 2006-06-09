#!/usr/bin/perl -w

use strict;
use Test::More tests => 9;
BEGIN { use_ok('Exception::Class::DBI') }

DBI: {
    package MyApp::Ex::DBI;
    use base 'Exception::Class::DBI';
    $INC{'MyApp/Ex/DBI.pm'} = __FILE__;
}

H: {
    package MyApp::Ex::DBI::H;
    use base 'MyApp::Ex::DBI', 'Exception::Class::DBI::H';
    $INC{'MyApp/Ex/DBI/H.pm'} = __FILE__;
}

DRH: {
    package MyApp::Ex::DBI::DRH;
    use base 'MyApp::Ex::DBI', 'Exception::Class::DBI::DRH';
    $INC{'MyApp/Ex/DBI/DRH.pm'} = __FILE__;
}

DBH: {
    package MyApp::Ex::DBI::DBH;
    use base 'MyApp::Ex::DBI', 'Exception::Class::DBI::DBH';
    $INC{'MyApp/Ex/DBI/DBH.pm'} = __FILE__;
}

STH: {
    package MyApp::Ex::DBI::STH;
    use base 'MyApp::Ex::DBI', 'Exception::Class::DBI::STH';
    $INC{'MyApp/Ex/DBI/STH.pm'} = __FILE__;
}

UNKNOWN: {
    package MyApp::Ex::DBI::Unknown;
    use base 'MyApp::Ex::DBI', 'Exception::Class::DBI::Unknown';
    $INC{'MyApp/Ex/DBI/Unknown.pm'} = __FILE__;
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
diag $err;
isa_ok $err, 'Exception::Class::DBI', 'The exception';
isa_ok $err, 'Exception::Class::DBI::H', 'The exception';
isa_ok $err, 'Exception::Class::DBI::STH', 'The exception';
isa_ok $err, 'MyApp::Ex::DBI::STH', 'The exception';
isa_ok $err, 'MyApp::Ex::DBI', 'The exception';
