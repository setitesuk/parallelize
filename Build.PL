use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Parallelize',
    license             => 'perl',
    dist_author         => 'Nelo Onyiah <nelo.onyiah@gmail.com>',
    dist_version_from   => 'lib/Parallelize.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'Parallelize-*' ],
);

$builder->create_build_script();
