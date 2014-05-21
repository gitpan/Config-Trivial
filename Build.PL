#	$Id: Build.PL 52 2014-05-21 19:46:02Z adam $;

use strict;
use Module::Build;

my $build = Module::Build->new(
	module_name => 'Config::Trivial',
	license     => 'gpl',
	requires    => {
		'perl'  => '5.010',
	},
    build_requires => {
        'Module::Build' => 0.40,
        'IO::Capture'   => 0,
        'Test::Pod'     => 0,
        'Pod::Coverage' => 0,
        'Test::Pod::Coverage'   => 0,
    },
);

$build->create_build_script;
