#	$Id: 01-basic.t,v 1.3 2004/02/14 16:21:19 adam Exp $

use strict;
use Test;
BEGIN { plan tests => 4 }

use Config::Trivial;

ok(1);
ok($Config::Trivial::VERSION, "0.50");

my $config = Config::Trivial->new;
ok(defined $config);
ok($config->isa('Config::Trivial'));

exit;
__END__
