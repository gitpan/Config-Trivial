#	$Id: 01-basic.t,v 1.6 2007-05-28 17:11:41 adam Exp $

use strict;
use Test;
BEGIN { plan tests => 4 }

use Config::Trivial;

ok(1);
ok($Config::Trivial::VERSION, "0.70");

my $config = Config::Trivial->new;
ok(defined $config);
ok($config->isa('Config::Trivial'));

exit;
__END__
