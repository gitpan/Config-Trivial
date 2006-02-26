#	$Id: 90-pod.t,v 1.1 2006-02-19 12:16:24 adam Exp $

use strict;
use Test::More tests => 1;
use Test::Pod;

pod_file_ok("./lib/Config/Trivial.pm", "Valid POD file" );

