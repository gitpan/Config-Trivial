use strict;
use Test;
BEGIN { plan tests => 19 }

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
ok($settings->{test1} eq "foo");					# test1 = foo
ok($settings->{test2} eq "bar bar");				# test2 = bar bar
ok($settings->{test3} eq "baz");					# test3 = baz (lc the key)
ok(! defined($settings->{test4}));					# test4 = undef (it's after then END)
ok(! defined($settings->{test5}));					# test5 = undef (it's not there)
ok(! defined($settings->{empty}));					# empty is empty
ok($settings->{test6} eq 'foo \ bar');				# test6 = foo \ bar
ok($settings->{test7} eq 'foo \\');					# test7 = foo \
#print STDERR "\n[", $settings->{test7}, "]\n";
#
#	Constructor with config_file set (14-15)
#
$config = Config::Trivial->new(config_file => "./t/test.data");
$settings = $config->read;							# Read data from test file
ok($settings);
ok($settings->{test_a} eq "foo");					# test_a = foo

#
#	Basic Constructor (file from this test script) (16-17)
#
$config = Config::Trivial->new;
$settings = $config->read;
ok($settings);
ok($settings->{test1} eq "bar");					# test1 = bar

#
#	Read a single key from the test file (18-19)
#
$config = Config::Trivial->new(config_file => "./t/test.data");
ok($config->read("test1"), "foo");
ok(! defined($config->read("test4")));

exit;

__DATA__

test1	bar
