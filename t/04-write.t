use strict;
use Test;
BEGIN { plan tests => 13 }

use Config::Trivial;

ok(1);

#
#	Basic Constructor (2-5)
#
ok(my $config = Config::Trivial->new(
	config_file => "./t/test.data"));			# Create Config object
ok($config->read);								# Read it in
ok($config->write(
	config_file => "./t/test2.data"));			# Write it out
ok(-e "./t/test2.data");						# Was written out

#
#	Create New (6-7)
#

$config = Config::Trivial->new();
my $data = {test => "womble"};					# New Data
ok($config->write(
	config_file => "./t/test3.data",		
	configuration => $data));					# Write it too
ok(-e "./t/test3.data");

#
#	Read things back (8-13)
#

ok($config = Config::Trivial->new(
    config_file => "./t/test2.data"));          # Create Config object
ok($config->read("test1"), "foo");
ok($config->write);								# write it back (should make a backup)
ok(-e "./t/test2.data~");

ok($config = Config::Trivial->new(
    config_file => "./t/test3.data"));           # Create Config object
ok($config->read("test"), "womble");

unlink "./t/test2.data", "./t/test2.data~", "./t/test3.data";

__DATA__

foo bar
