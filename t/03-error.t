use strict;
use Test;

BEGIN { plan tests => 17 };

use Config::Trivial;
ok(1);

#
#	Basic Constructor
#
my $config = Config::Trivial->new;

# Missing file (2-3)
ok(! $config->set_config_file("./t/file.that.is.not.there")); 
ok($config->get_error(), "File error: Cannot find ./t/file.that.is.not.there");

# Not a file (4-5)
ok(! $config->set_config_file("./t"));
ok($config->get_error(), "File error: ./t isn't a real file");

# Empty filename (6-7)
ok(! $config->set_config_file(""));
ok($config->get_error(), "File error: No file name supplied");

# Empty file (8-9)
ok(! $config->set_config_file("./t/empty"));
ok($config->get_error(), "File error: ./t/empty is zero bytes long");

# duped keys, normal mode (10-12)
ok($config->set_config_file("./t/bad.data"));
ok(my $settings = $config->read());
ok($settings->{test1}, "bar");

# duped keys, strict mode (13-15)
$settings = undef;
$config = Config::Trivial->new(strict => "on");
ok($config->set_config_file("./t/bad.data"));
eval { $settings = $config->read(); };
ok(! defined($settings->{test1}));
ok($@ =~ 'ERROR: Duplicate key "test1" found in config file on line 4');

# Missing File, Strict mode (16)
eval { $config->set_config_file("./t/file.that.is.not.there"); };
ok($@ =~ "File error: Cannot find ./t/file.that.is.not.there");

# Empty file, Strict mode (17)
eval { $config->set_config_file("./t/empty"); };
ok($@ =~ "File error: ./t/empty is zero bytes long");

exit;

__END__
