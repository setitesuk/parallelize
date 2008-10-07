#! /usr/bin/env perl

use 5.010_000;

use strict;
use warnings;

use FindBin       qw($Bin);
use lib           qq($Bin/../lib);
use Test::More    qw(no_plan);
use Test::Output;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:

use_ok('Parallelize') or exit;

my $foo = Parallelize->new(
    files     => [ glob "$Bin/../data/*.txt" ],
    exec_file => "$Bin/../data/script.pl",
);

isa_ok( $foo, 'Parallelize' );

=for:

Would prefer this ...

#=cut

my $expected = <<'EOF';
perl /home/j1n3l0/Desktop/parallelize/t/../data/script.pl data/A.txt
perl /home/j1n3l0/Desktop/parallelize/t/../data/script.pl data/B.txt
perl /home/j1n3l0/Desktop/parallelize/t/../data/script.pl data/C.txt
EOF

my $output = qr{\A perl \w+ data / [ABC] \. txt \z}xms;

=cut

my $expected .= $_ for <DATA>;

stdout_like sub { $foo->run }, qr{$expected}, 'output is what we expect';

exit 0;

__END__
perl /home/j1n3l0/Desktop/parallelize/t/../data/script.pl data/A.txt
perl /home/j1n3l0/Desktop/parallelize/t/../data/script.pl data/B.txt
perl /home/j1n3l0/Desktop/parallelize/t/../data/script.pl data/C.txt
