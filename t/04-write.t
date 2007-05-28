#	$Id: 04-write.t,v 1.4 2007-05-28 17:11:41 adam Exp $

use strict;
use Test;
BEGIN { plan tests => 20 }

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
my $data = {
    test => "womble",
    longer_key => "muppet",
    'silly key' => 'fraggle'
};					# New Data
ok($config->write(
	config_file => "./t/test3.data",		
	configuration => $data));					# Write it too
ok(-e "./t/test3.data");

#
#	Read things back (8-15)
#

ok($config = Config::Trivial->new(
    config_file => "./t/test2.data"));          # Create Config object
ok($config->read("test1"), "foo");
ok($config->write);								# write it back (should make a backup)
ok(-e "./t/test2.data~");

ok($config = Config::Trivial->new(
    config_file => "./t/test3.data"));           # Create Config object
ok($config->read("test"), "womble");
ok($config->read('longer_key'), 'muppet');
ok($config->read('silly_key'), 'fraggle');

ok($config->set_configuration($data));

#
#	Make sure we clean up (16-19)
#
ok(unlink("./t/test2.data", "./t/test2.data~", "./t/test3.data"), 3);
ok(! -e "./t/test2.data");
ok(! -e "./t/test2.data~");
ok(! -e "./t/test3.data");
__DATA__

foo bar
