use strict;
use Test;
BEGIN { plan tests => 24 }

use Config::Trivial;

ok(1);

#
#	Basic Constructor (2-13)
#
my $config = Config::Trivial->new;
ok($config->set_config_file("./t/test.data"));		# Set the test file to read

my $settings = $config->read;						# Read data from test file
ok($settings);

ok(defined($settings->{test0}));					# test0 = 0
ok($settings->{test0} == 0);						#
ok($settings->{test1}, "foo");						# test1 = foo
ok($settings->{test2}, "bar bar");					# test2 = bar bar
ok($settings->{test3}, "baz");						# test3 = baz (lc the key)
ok(! defined($settings->{test4}));					# test4 = undef (it's after then END)
ok(! defined($settings->{test5}));					# test5 = undef (it's not there)
ok(! defined($settings->{empty}));					# empty is empty
ok($settings->{test6}, 'foo \ bar');				# test6 = foo \ bar
ok($settings->{test7}, 'foo \\');					# test7 = foo \

#
#	Re-reads (14-16)
#

my $settings_2 = $config->get_configuration;		# Re-read from object
ok($settings_2);		
ok($settings_2->{test1}, "foo");					# test1 = foo
ok(! defined($settings_2->{test4}));				# test4 = undef (it's after then END)


#
#	Constructor with config_file set (16-17)
#
$config = Config::Trivial->new(config_file => "./t/test.data");
$settings = $config->read;							# Read data from test file
ok($settings);
ok($settings->{test_a} eq "foo");					# test_a = foo

#
#	Basic Constructor (file from this test script) (18-19)
#
$config = Config::Trivial->new;
$settings = $config->read;
ok($settings);
ok($settings->{test1}, "bar");						# test1 = bar

#
#	Read a single key from the test file (20-24)
#
$config = Config::Trivial->new(config_file => "./t/test.data");
ok($config->read("test1"), "foo");
ok(! defined($config->read("test4")));
ok($config->get_configuration("test1"), "foo");
ok(! defined($config->get_configuration("test4")));

exit;

__DATA__

test1	bar
