use Module::Build;

my $build = Module::Build->new
  ( module_name    => 'Exception::Class::DBI',
    license        => 'perl',
    requires       => { DBI              => '1.28',
                        Exception::Class => '1.02',
                      },
    build_requires => { Test::Simple     => '0.17',
                        Test::Harness    => '2.03', # For TODO tests.
                      },
    create_makefile_pl => 'passthrough',
  );
$build->create_build_script;
