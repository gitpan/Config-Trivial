use strict;
use Test;
use Pod::Coverage;

plan tests => 1;

my $pc = Pod::Coverage->new(package => 'Config::Trivial');
ok($pc->coverage == 1);
