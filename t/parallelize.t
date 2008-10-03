#! /usr/bin/env perl

use 5.010_000;

use strict;
use warnings;

use FindBin qw($Bin);
use lib qq($Bin/../lib);

use Test::More qw(no_plan);

use_ok('Parallelize') or exit;

exit 0;

__END__
#! /usr/bin/env perl
use 5.010;
say 'This is a test: ', shift;
exit 0;
