use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name       => 'Parallelize',
    license           => 'perl',
    dist_author       => 'Nelo Onyiah <nelo.onyiah@gmail.com>',
    dist_version_from => 'lib/Parallelize.pm',
    requires          => {
        'Test::More' => 0.8,
        'version'    => 0.76,
        'Moose'      => 0.58,
        'autodie'    => 1.994,
        'Cwd'        => 3.2701,
        'File::Spec' => 3.2701,
    },
    add_to_cleanup => ['Parallelize-*'],
);

$builder->create_build_script();
