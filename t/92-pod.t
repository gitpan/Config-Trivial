#	$Id: 92-pod.t,v 1.1 2006-02-19 12:16:24 adam Exp $

use strict;
use Test::Pod::Coverage tests=>1;
pod_coverage_ok( "Config::Trivial", "Config::Trivial is covered" );
