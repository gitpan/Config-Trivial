use ExtUtils::MakeMaker;
use strict;
use 5.006;

my @tests;
my $test_list = 't/00-use.t t/01-basic.t t/02-read.t';
eval { require Test::Pod; };
$test_list .= ' t/04-pod.t' unless ($@);
eval { require Pod::Coverage; };
$test_list .= ' t/05-pod.t' unless ($@);
push @tests, test => { TESTS => $test_list};

WriteMakefile(
    'NAME'          => 'Config::Trivial',
    'VERSION_FROM'  => 'lib/Config/Trivial.pm',
    'PREREQ_PM'     => {}, 
	@tests,
     dist           => {
       COMPRESS      => 'gzip -9f',
       SUFFIX        => 'gz'
       },
      ($] >= 5.005 ?
      (ABSTRACT_FROM => 'lib/Config/Trivial.pm',
       AUTHOR     => 'Dr A. J. Trickett <atrickett@cpan.org>') : ()),
);
