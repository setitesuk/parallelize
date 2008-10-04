#! /usr/bin/env perl

use 5.010_000;

use strict;
use warnings;

use FindBin qw($Bin);
use lib qq($Bin/../lib);

use Test::More qw(no_plan);

use_ok('Parallelize') or exit;

my $data = [qw(A B C)];
my $code = <<'END_CODE';
#! /usr/bin/env perl
use 5.010;
say 'This is a test: ', shift;
exit 0;
END_CODE

my $foo = Parallelize->new(
    code => $code,
    data => $data,
);

isa_ok( $foo, 'Parallelize' );

is( $foo->code, $code, 'code is what we expect' );
is_deeply( [ $foo->data ], $data, 'data is what we expect' );

=for:

Would need a coersion to make this work.

my $foo = Parallelize->new(
    code => [<DATA>],
    data => [qw(A B C)],
);

isa_ok( $foo, 'Parallelize' );

=cut

exit 0;

__END__
#! /usr/bin/env perl
use 5.010;
say 'This is a test: ', shift;
exit 0;
