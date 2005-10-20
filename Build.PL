#	$Id: Build.PL,v 1.1 2005/10/18 20:30:18 adam Exp $;

use Module::Build;

my @tests = qw(t/00-use.t t/01-basic.t t/02-read.t t/03-error.t t/04-write.t);

eval { require Test::Pod; };
push @tests, 't/05-pod.t' unless ($@);

eval { require Pod::Coverage; };
push @tests, 't/06-pod.t' unless ($@);

eval { require IO::Capture; };
push @tests, 't/07-warn.t' unless ($@);

eval { require Test::Pod::Coverage; };
push @tests, 't/08-pod.t' unless ($@);

my $build = Module::Build->new(
	module_name => 'Config::Trivial',
	license     => 'gpl',
	test_files  => \@tests,
	requires    => {
		'perl'  => '5.6.1',
	},
);

$build->create_build_script;
