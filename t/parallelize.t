#! /usr/bin/env perl

use 5.010_000;

use strict;
use warnings;

use FindBin qw($Bin);
use lib qq($Bin/../lib);

use Test::More qw(no_plan);

use_ok('Parallelize') or exit;

my $data = [ glob "$Bin/../data/*.txt" ];
my $code = <<'END_CODE';
#! /usr/bin/env perl
use 5.010;
say 'This is a test: ', shift;
exit 0;
END_CODE

my $foo = Parallelize->new(
    code  => $code,
    files => $data,
);

# Would need a coersion to make this work.
my $bar = Parallelize->new(
    code  => [<DATA>],
    files => $data,
);

for my $object ( $foo, $bar ) {
    isa_ok( $object, 'Parallelize' );
    is( $object->code, $code, 'code is what we expect' );
    is_deeply( [ $object->files ], $data, 'data is what we expect' );
}

exit 0;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:

__END__
#! /usr/bin/env perl
use 5.010;
say 'This is a test: ', shift;
exit 0;
