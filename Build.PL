#	$Id: Build.PL,v 1.3 2006-02-26 19:52:13 adam Exp $;

use Module::Build;

my @tests = qw(t/00-use.t t/01-basic.t t/02-read.t t/03-error.t t/04-write.t);

eval { require IO::Capture; };
push @tests, 't/80-warn.t' unless ($@);

eval { require Test::Pod; };
push @tests, 't/90-pod.t' unless ($@);

eval { require Pod::Coverage; };
push @tests, 't/91-pod.t' unless ($@);

eval { require Test::Pod::Coverage; };
push @tests, 't/92-pod.t' unless ($@);

my $build = Module::Build->new(
	module_name => 'Config::Trivial',
	license     => 'gpl',
	test_files  => \@tests,
	requires    => {
		'perl'  => '5.6.1',
	},
    build_requires => {
        'IO::Capture'   => 0,
        'Test::Pod'     => 0,
        'Pod::Coverage' => 0,
        'Test::Pod::Coverage'   => 0,
    },
);

$build->create_build_script;
