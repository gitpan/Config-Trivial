#	$Id: 05-pod.t,v 1.2 2004/02/14 16:14:45 adam Exp $

use strict;
use Test::More tests => 1;
use Test::Pod;

pod_file_ok("./lib/Config/Trivial.pm", "Valid POD file" );

