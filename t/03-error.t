use strict;
use Test;

BEGIN { plan tests => 26 };

use Config::Trivial;
ok(1);

#
#	Basic Constructor
#
my $config = Config::Trivial->new;

# Try and write to self (2-3)
ok(! $config->write );
ok($config->get_error(), "Not allowed to write to the calling file.");

# Missing file (4-5)
ok(! $config->set_config_file("./t/file.that.is.not.there")); 
ok($config->get_error(), "File error: Cannot find ./t/file.that.is.not.there");

# Not a file (6-7)
ok(! $config->set_config_file("./t"));
ok($config->get_error(), "File error: ./t isn't a real file");

# Empty filename (8-9)
ok(! $config->set_config_file(""));
ok($config->get_error(), "File error: No file name supplied");

# Empty file (10-11)
ok(! $config->set_config_file("./t/empty"));
ok($config->get_error(), "File error: ./t/empty is zero bytes long");

# write to self (12-14)
$config->set_config_file($0);
ok(! $config->write );
ok($config->get_error(), "Not allowed to write to the calling file.");

# duped keys, normal mode (15-16)
ok($config->set_config_file("./t/bad.data"));
ok(my $settings = $config->read());
ok($settings->{test1}, "bar");

# setting not a hash_ref (17-18)
ok(! $config->set_configuration("foo"));
ok($config->get_error(), "Configuration data isn't a hash reference");

$settings = undef;
$config = Config::Trivial->new(strict => "on");

# Try and write to self (19)
eval { $config->write };
ok($@ =~ "Not allowed to write to the calling file.");

# duped keys, strict mode (20-22)
ok($config->set_config_file("./t/bad.data"));
eval { $settings = $config->read(); };
ok(! defined($settings->{test1}));
ok($@ =~ 'ERROR: Duplicate key "test1" found in config file on line 4');

# Missing File, Strict mode (23)
eval { $config->set_config_file("./t/file.that.is.not.there"); };
ok($@ =~ "File error: Cannot find ./t/file.that.is.not.there");

# Empty file, Strict mode (24)
eval { $config->set_config_file("./t/empty"); };
ok($@ =~ "File error: ./t/empty is zero bytes long");

# write to self, Strict mode (25)
$config->set_config_file($0);
eval { $config->write };
ok($@ =~ "Not allowed to write to the calling file.");

# setting not a hash_ref, Strict mode (26)
eval { $config->set_configuration("foo"); };
ok($@ =~ "Configuration data isn't a hash reference");

exit;

__END__
