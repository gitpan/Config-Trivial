use strict;
use Test;
BEGIN { plan tests => 4 }

use Config::Trivial;

ok(1);
ok($Config::Trivial::VERSION eq "0.40");

my $config = Config::Trivial->new;
ok(defined $config);
ok($config->isa('Config::Trivial'));

exit;
__END__
