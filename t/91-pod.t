#	$Id: 91-pod.t,v 1.1 2006-02-19 12:16:24 adam Exp $

use strict;
use Test;
use Pod::Coverage;

plan tests => 1;

my $pc = Pod::Coverage->new(package => 'Config::Trivial');
ok($pc->coverage == 1);
