use strict;
use Test;
BEGIN { plan tests => 14 }

use Config::Trivial;

ok(1);

#
#	Basic Constructor (2-8)
#
my $config = Config::Trivial->new;
ok($config->set_config_file("./t/test.data"));		# Set the test file to read

my $settings = $config->read;						# Read data from test file
ok($settings);

ok($settings->{test1} eq "foo");					# test1 = foo
ok($settings->{test2} eq "bar bar");				# test2 = bar bar
ok($settings->{test3} eq "baz");					# test3 = baz (lc the key)
ok(! defined($settings->{test4}));					# test3 = undef (it's after then END)
ok(! defined($settings->{test5}));					# test4 = undef (it's not there)

#
#	Constructor with config_file set (9-10)
#
$config = Config::Trivial->new(config_file => "./t/test.data");
$settings = $config->read;							# Read data from test file
ok($settings);
ok($settings->{test_a} eq "foo");					# test_a = foo

#
#	Basic Constructor (file from this test script) (11-12)
#
$config = Config::Trivial->new;
$settings = $config->read;
ok($settings);
ok($settings->{test1} eq "bar");					# test1 = bar

#
#	Read a single key from the test file (13-14)
#
$config = Config::Trivial->new(config_file => "./t/test.data");
ok($config->read("test1"), "foo");
ok(! defined($config->read("test4")));

exit;

__DATA__

test1	bar
