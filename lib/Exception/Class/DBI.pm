package Exception::Class::DBI;

# $Id: DBI.pm,v 1.1 2002/08/18 20:19:58 david Exp $

use 5.00500;
use strict;
use Exception::Class;
use vars qw($VERSION);
$VERSION = '0.01';

use Exception::Class ( 'Exception::Class::DBI' =>
                       { description => 'DBI exception',
                         fields => [qw(err errstr state retval)]
                       },
                       'Exception::Class::DBI::Unknown' =>
                       { isa => 'Exception::Class::DBI',
                         description => 'DBI unknown exception'
                       },
                       'Exception::Class::DBI::H' =>
                       { isa => 'Exception::Class::DBI',
                         description => 'DBI handle exception',
                         fields => [qw(warn active kids active_kids compat_mode
                                       inactive_destroy trace_level
                                       fetch_hash_key_name chop_blanks
                                       long_read_len long_trunc_ok taint)]
                       },
                        'Exception::Class::DBI::DRH' =>
                        { isa => 'Exception::Class::DBI::H',
                          description => 'DBI driver handle exception',
                        },
                        'Exception::Class::DBI::DBH' =>
                        { isa => 'Exception::Class::DBI::H',
                          description => 'DBI database handle exception',
                          fields => [qw(auto_commit db_name statement
                                        row_cache_size)]
                        },
                        'Exception::Class::DBI::STH' =>
                        { isa => 'Exception::Class::DBI::H',
                          description => 'DBI statment handle exception',
                          fields => [qw(num_of_fields num_of_params field_names
                                        type precision scale nullable
                                        cursor_name param_values statement
                                        rows_in_cache)]
                        }
                      );

sub error_handler {
    sub {
        my ($err, $dbh, $retval) = @_;
        if ($dbh) {
            # Assemble arguments for a handle exception.
            my @params = ( error               => $err,
                           errstr              => $dbh->errstr,
                           err                 => $dbh->err,
                           state               => $dbh->state,
                           retval              => $retval,
                           warn                => $dbh->{Warn},
                           active              => $dbh->{Active},
                           kids                => $dbh->{Kids},
                           active_kids         => $dbh->{ActiveKids},
                           compat_mode         => $dbh->{CompatMode},
                           inactive_destroy    => $dbh->{InactiveDestroy},
                           trace_level         => $dbh->{TraceLevel},
                           fetch_hash_key_name => $dbh->{FetchHashKeyName},
                           chop_blanks         => $dbh->{ChopBlanks},
                           long_read_len       => $dbh->{LongReadLen},
                           long_trunc_ok       => $dbh->{LongTruncOk},
                           taint               => $dbh->{Taint},
                         );

              if (UNIVERSAL::isa($dbh, 'DBI::dr')) {
                  # Just throw a driver exception. It has no extra attributes.
                  die Exception::Class::DBI::DRH->new(@params);
              } elsif (UNIVERSAL::isa($dbh, 'DBI::db')) {
                  # Throw a database handle exception.
                  die Exception::Class::DBI::DBH->new
                    ( @params,
                      auto_commit    => $dbh->{AutoCommit},
                      db_name        => $dbh->{Name},
                      statement      => $dbh->{Statement},
                      row_cache_size => $dbh->{RowCacheSize}
                    );
              } elsif (UNIVERSAL::isa($dbh, 'DBI::st')) {
                  # Throw a statement handle exception.
                  die Exception::Class::DBI::DBH->new
                    ( @params,
                      num_of_fields => $dbh->{NUM_OF_FIELDS},
                      num_of_params => $dbh->{NUM_OF_PARAMS},
                      field_names   => $dbh->{NAME},
                      type          => $dbh->{TYPE},
                      precision     => $dbh->{PRECISION},
                      scale         => $dbh->{SCALE},
                      nullable      => $dbh->{NULLABLE},
                      cursor_name   => $dbh->{CursorName},
                      param_values  => $dbh->{ParamValues},
                      statement     => $dbh->{Statement},
                      rows_in_cache => $dbh->{RowsInCache}
                    );
              } else {
                  # Unknown exception. This shouldn't happen.
                  die Exception::Class::DBI::Unknown->new(@params);
              }
        } else {
            # Unknown exception. This shouldn't happen.
            die Exception::Class::DBI::Unknown->new
              ( error  => $err,
                errstr => $DBI::errstr,
                err    => $DBI::err,
                state  => $DBI::state,
                retval => $retval
              );
        }
    };
}

1;
__END__

=head1 NAME

Exception::Class::DBI - DBI Exception objects

=head1 SYNOPSIS

  use DBI;
  use Exception::Class::DBI;

=head1 DESCRIPTION



=head1 AUTHOR

David Wheeler <david@wheeler.net>

=head1 SEE ALSO

L<perl|perl>, L<Exception::Class|Exception::Class>.

=cut
