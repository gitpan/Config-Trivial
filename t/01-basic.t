#	$Id: 01-basic.t,v 1.4 2005/10/21 16:43:52 adam Exp $

use strict;
use Test;
BEGIN { plan tests => 4 }

use Config::Trivial;

ok(1);
ok($Config::Trivial::VERSION, "0.51");

my $config = Config::Trivial->new;
ok(defined $config);
ok($config->isa('Config::Trivial'));

exit;
__END__
