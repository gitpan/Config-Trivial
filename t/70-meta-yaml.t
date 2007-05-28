# $Id: 70-meta-yaml.t,v 1.1 2007-05-28 17:11:41 adam Exp $

use strict;
use Test;

my $run_tests;

BEGIN {
    $run_tests = eval { require YAML; };
    plan tests => 1
};

if (! $run_tests) {
    skip "YAML not installed, skipping test.";
    exit;
}

ok(YAML::LoadFile('./META.yml'));
