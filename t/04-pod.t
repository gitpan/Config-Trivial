use strict;
use Test::More tests => 1;
use Test::Pod;

plan tests => 1;
pod_file_ok("./lib/Config/Trivial.pm", "Valid POD file" );

