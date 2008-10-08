#! /usr/bin/env perl

use 5.010_000;

use strict;
use warnings;

use FindBin qw($Bin);
use lib qq($Bin/../lib);

use Test::More qw(no_plan);

use_ok('Parallelize') or exit;

diag("Testing Parallelize $Parallelize::VERSION");

exit 0;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
