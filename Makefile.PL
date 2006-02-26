# $Id: Makefile.PL,v 1.5 2006-02-19 16:12:11 adam Exp $

use ExtUtils::MakeMaker;
use strict;
use 5.006;

my @tests;
my $test_list = 't/00-use.t t/01-basic.t t/02-read.t t/03-error.t t/04-write.t';
eval { require IO::Capture; };
$test_list .= ' t/80-warn.t' unless ($@);
eval { require Test::Pod; };
$test_list .= ' t/90-pod.t' unless ($@);
eval { require Pod::Coverage; };
$test_list .= ' t/91-pod.t' unless ($@);
eval { require Test::Pod::Coverage; };
$test_list .= ' t/92-pod.t' unless ($@);

push @tests, test => { TESTS => $test_list};

WriteMakefile(
    'NAME'          => 'Config::Trivial',
    'VERSION_FROM'  => 'lib/Config/Trivial.pm',
    'PREREQ_PM'     => {}, 
	'PL_FILES'      => {},
	@tests,
     dist           => {
       COMPRESS      => 'gzip -9f',
       SUFFIX        => 'gz'
       },
      ($] >= 5.005 ?
      (ABSTRACT_FROM => 'lib/Config/Trivial.pm',
       AUTHOR     => 'Dr A. J. Trickett <atrickett@cpan.org>') : ()),
);
