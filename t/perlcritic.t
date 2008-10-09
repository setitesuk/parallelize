#! /usr/bin/env perl

use 5.010_000;

use strict;
use warnings;

use FindBin qw($Bin);
use lib qq($Bin/../lib);

use Test::More;

if ( !require Test::Perl::Critic ) {
    Test::More::plan(
        skip_all => "Test::Perl::Critic required for testing PBP compliance" );
}

Test::Perl::Critic::all_critic_ok();

exit 0;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
