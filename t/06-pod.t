#	$Id: 06-pod.t,v 1.2 2004/02/14 16:14:45 adam Exp $

use strict;
use Test;
use Pod::Coverage;

plan tests => 1;

my $pc = Pod::Coverage->new(package => 'Config::Trivial');
ok($pc->coverage == 1);
