=head1 NAME

Config::Trivial - Very simple tool for reading and writing very simple configuration files

=head1 SYNOPSIS

  use Config::Trivial;
  my $config = Config::Trivial->new(config_file => "path/to/my/config.conf");
  my $settings = $config->read;
  print "Setting Colour is:\t", $settings->{'colour'};
  $settings->{'new-item'} = "New Setting";

=head1 DESCRIPTION

Use this module when you want use "Yet Another" very simple, light
weight configuration file reader. The module simply returns a
reference to a single hash for you to read configuration values
from, and uses the same hash to write a new config file.

=cut

package Config::Trivial;

use 5.006;
use strict;
use warnings;
use diagnostics;
use Carp;

our $VERSION = "0.40";
my ($_package, $_file) = caller;

#
#	NEW
#

=head1 METHODS

=head2 new

The constructor can be called empty or with a number of optional
parameters. If called with no parameters it will set the configuration
file to be the file name of the file that called it.

  $config = Config::Trivial->new();

or

  $config = Config::Trivial->new(
    config_file => "/my/config/file",
    debug       => "on",
    strict      => "on");

By default debug and strict are set to off. In debug mode messages
and errors will be dumped automatically to STDERR. Normally messages
and non-fatal errors need to be pulled from the error handler. In
strict mode all warnings become fatal.

If you set a file in the constructor that is invalid for any reason
it will die in any mode - this may change in a later version.

=cut

sub new {
	my $class = shift;
	my %args  = @_;
	my $object = bless {
		_config_file	=>	$_file,							# The Config file, default is caller
		_self			=>	1,								# Set Self Read
		_debug			=>	$args{debug}	|| 0,			# Debugging (verbose) mode
		_strict			=>	$args{strict}	|| 0,			# Strict mode
		_error_message	=>  "",								# Error Messages
		_configuration  =>  {},								# Where the configuration data goes
		_backup_char	=>	"~",							# Backup marker
		_separator		=>	" "
	}, ref($class) || $class;

	if ($args{config_file}) {
		croak "Unable to read config file $args{config_file}" unless set_config_file($object, $args{config_file});
	}
	return $object;
}


#
#	SET_CONFIG_FILE
#

=head2 set_config_file

The configuration file can be set after the constructor has been called.
Simply set the path to the file you want to use as the config file. If the
file does not exist or isn't readable the call will return false and set
the error message.

  $config->set_config_file("/path/to/file");

=cut

sub set_config_file {
	my $self = shift;
	my $configuration_file = shift;
	if ($self->_check_file($configuration_file)) {
		$self->{_config_file} = $configuration_file;
		$self->{_self} = 0;
		return $self;
	} else {
		return undef;
	}
}

#
#	READ
#

=head2 read

The read method opens the file, and parses the configuration returning the
results as a reference to an hash. If the file cannot be read it will die.

  my $settings = $config->read;

Alternatively if you only want a single configuration value you can pass just
that key, and get back it's matching value.

  my $colour = $config->read("colour");

Each call to read will make the module re-read and parse the configuration file.
If you want to re-read data from the oject use the get_configuration method.

=cut

sub read {
	my $self = shift;
	my $key  = shift;	# If there is a key, return only it's value

	return undef unless $self->_check_file($self->{_config_file});

#	Open up the configuration file and process it
	open CONF, "<", $self->{_config_file} or croak "ERROR: Unable to open configuration file: $self->{_config_file}";

	if ($self->{_self}) {							# We are now parsing the calling file for it's __DATA__ section
		while (<CONF>) {
			last if /^__DATA__\s*$/;
		}
	}
	while (<CONF>) {
		next if /^\s*#/;							# Skip comment lines starting #
		next if /^\s*\n/;							# Skip any empty lines
		last if /^__END__\s*$/;						# Don't care what comes after this
		if (s/\\\s*$//) {							# Look for a continuation character
			$_ .= <CONF>;							# If found then glue the lines together
			redo unless eof CONF;
		}
		_process_line ($self, $_, $.);				# Send the line off for processing
		}
	close CONF;
	return $self->{_configuration}->{$key} if $key;
	return $self->{_configuration};
}


#
#	GET_CONFIGURATION
#

=head2 get_configuration

This method simply returns the value requested or a hash reference
of the configuration data. It does NOT perform a re-read of the
data on the disk.

  $settings = $config->get_configuration;

or

  $colour = $config->get_configuration{"colour"};

=cut

sub get_configuration {
	my $self = shift;
	my $key  = shift;

	return $self->{_configuration}->{$key} if $key;
	return $self->{_configuration};
}


#
#	SET_CONFIGURATION
#

=head2 set_configuration

If you need to set the configuration object with data you can
pass in a reference to a hash with this method. Any existing
data will be over-written. Returns false on failure.

  $config->set_configuration(\%settings);

or

  $config->set_configuration($hash_ref);

=cut

sub set_configuration {
	my $self = shift;
	my $hash = shift;

	return $self->_raise_error("No configuration data") unless $hash;
	return $self->_raise_error("Configuration data isn't a hash reference") unless ref $hash eq "HASH";

	$self->{_configuration} = $hash;
	return $self;
}


#
#	WRITE
#

=head2 write

The write method simply writes the configuration hash back out
to the configuration file. It will try to not write to a file if
it has the same filename of the script that called it. This can
easily be bypassed, and bad things will happen!

There are two optional parameters that can be passed, a file
name to use instead of the current one, and a reference of a
hash to write out instead of the currently loaded one.

  $config->write(
    file_name => "/path/to/somewhere/else",
    configuration => $settings);

The method returns true on success. If the file already exists
then it is backed up first. The write is not "atomic" or
locked for reading in anyway. If the file cannot be written to
then it will die.

Configuration data passed by this method is only written to
file, it is not stored in the internal configuration object.
To store data in the internal use the set_configuration data
method. The option to pass a hash_ref in this method may
be removed in future versions.

=cut

sub write {
	my $self = shift;
	my %args = @_;

	my $file = $args{"config_file"} || $self->{_config_file};
	if (($_file eq $file) ||
	    ($0 eq $file)) {
		return $self->_raise_error("Not allowed to write to the calling file.")
	};

    if (-e $file) {
		croak "ERROR: Insufficient permissions to write to: $file" unless (-w $file);
		rename $file, $file.$self->{_backup_char} or croak "ERROR: Unable to rename $file.";
	}

	open CONF, ">", $file or croak "ERROR: Unable to write configuration file: $file";
	print CONF "#\n#\tConfig file written by $_file\n#\tUsing Config::Trivial version $VERSION\n#\n\n";

	my $settings = $args{"configuration"} || $self->{_configuration};
	foreach my $setting (keys %$settings) {
		if ($setting =~ / /) {	# Check for spaces in keys
			croak "ERROR: Setting key \"$setting\" contains an illegal space" if $self->{_strict};
			carp "WARNING: Setting key \"$setting\" contains an illegal space" if $self->{_debug};
			my $old_setting = $setting;
			$setting =~ s/ /_/g;
			croak "ERROR: Unable to fix space in key, replacement key exists already" if $settings->{$setting};
			$settings->{$old_setting} = " " unless $settings->{$old_setting};
			$settings->{$old_setting} =~ s/\\\s*$/\\ #/;
			printf CONF "$setting%s$settings->{$old_setting}\n", length($old_setting) >= 8 ? "\t" : "\t\t";
			next;
		}
		$settings->{$setting} = " " unless $settings->{$setting};
		$settings->{$setting} =~ s/\\\s*$/\\ #/;
		printf CONF "$setting%s$settings->{$setting}\n", length($setting) >= 8 ? "\t" : "\t\t"
	}

	my $time = localtime;
	print CONF "\n#\n#\tThis file written at $time\n#\n";
	close CONF;
	return 1;
}


#
#	GET_ERROR
#

=head2 get_error

In normal operation the module will only die if it is unable to read
or write the configuration file, or an invalid file is set in the
constructor. Other errors are non-fatal. If an error occurs it can
be read with the get_error method. Only the most recent error is
stored.

  my $settings = $config->read();
  print get_error unless $settings;

=cut

sub get_error {
	my $self = shift;
	return $self->{_error_message};
}

#
#	Private Functions
#

#
#	Perform some file checks
#

sub _check_file {
	my $self = shift;
	my $file = shift;
	return $self->_raise_error("File error: No file name supplied") unless $file;
	return $self->_raise_error("File error: Cannot find $file") unless -e $file;
	return $self->_raise_error("File error: $file isn't a real file") unless -f _;
	return $self->_raise_error("File error: Cannot read file $file") unless -r _;
	return $self->_raise_error("File error: $file is zero bytes long") if -z _;
	return $self;
}


#
#	Raise error condition
#
sub _raise_error {
	my $self    = shift;
	my $message = shift;
	croak $message if $self->{_strict};			# STRICT: die with the message
	warn $message if $self->{_debug};			# DEBUG:  warn with the message
	$self->{_error_message} = $message;			# NORMAL: set the message
	return undef;
}


#
#	Parse a line and add to Config structure
#
sub _process_line {
	my $self    = shift;
	my $line    = shift;
	my $line_no = shift;

	chomp $line;						# Take the end off
	$line =~ s/^\s+|\s+$|\s*#+.*$//g;	# Remove comments, and spaces at start or end
	$line =~ s/\s+/ /g;					# Convert multiple whitespace to one space globally
	return unless $line;				# Return if nothing is left

	my ($key, $value) = split / /, $line, 2;
	$key = lc _clean_string($key);
	if (exists $self->{_configuration}->{$key}) {
		croak "ERROR: Duplicate key \"$key\" found in config file on line $line_no" if $self->{_strict};
		carp  "WARNING: Duplicate key \"$key\" found in config file on line $line_no" if $self->{_debug};
	}
	if ($key) {
		if ($value) {
			$self->{_configuration}->{$key} = $value;
		} else {
			carp "WARNING: Key \"$key\" has no valid value, on line $line_no of the config file" if $self->{_debug};
			$self->{_configuration}->{$key} = $value unless $self->{_strict};
		}
	}
}

#
#	Clean data up to make a key out of it
#
sub _clean_string {
	my $input = shift;
	my $output;
	$input =~ tr/\e\`\'"%//ds;										# Remove less gross crud from the input
	$output = $1 if ($input =~ /^([\^\$-=\?\/\w.:\\\s\@~\|]+)$/);   # De-Taint the input line
	$output =~ s/^\s+|\s+$//g if $output;							# Remove spaces at start or end
	return $output;
}

1;

__END__

=head1 CONFIG FORMAT

=head2 About The Configuration File Format

The configuration file is a plain text file with a simple structure. Each
setting is stored as a key value pair separated by the first space. Empty
lines are ignored and anything after a hash # is treated as a comment and
is ignored. Depending upon mode, duplicate entries will be silently ignored,
warned about, or cause the module to die.

All key names are forced into lower case when read in, values are left intact.

On write spaces in key names will either cause the script to die (strict),
blurt out a warning and substitute an underscore (debug), or silently change
to an underscore. Underscores in keys are NOT changed back to spaces on read.

If you delete a key/value pair it will not be written out when you do a write.
When a key has an undef value, the key will be written out with no matching
value. When you read a key with no value in, in debug mode you will get a warning.

You can continue configuration data over several lines, in a shell like manner,
by placing a backslash at the end of the line followed by a new line. White space
between the backslash and the new line will be ignored and also trigger line
continuation.

=head2 Sample Configuration File

  #
  # This is a sample config file
  #

  value-0 is very \
  long so it's broken \
  over several lines
  value-1 is foo
  value-1 is bar
  __END__
  value-1 is baz

If parsed the value of value-1 would be "is bar" in normal mode, issue a warning
if in debug mode and die in strict mode. Everything after the __END__ will be
ignored. value-0 will be "is very long so it's broken over several lines".

=head1 MISC

=head2 Prerequisites

At the moment the module only uses core modules. The test suite optionally uses
C<POD::Coverage> and C<Test::Pod>, which will be skipped if you don't have them.

=head2 History

See Changes file.

=head2 Defects and Limitations

Patches Welcome... ;-)

=head2 To Do

=over

=item *

Much better test suite.

=item *

Ensure FULL compatibility with C<Conf::SimpleConf>.

=back

=head1 EXPORT

None.

=head1 AUTHOR

Adam Trickett, E<lt>atrickett@cpan.orgE<gt>

=head1 SEE ALSO

L<perl>, L<ConfigReader::Simple>, L<Config::Ini>, L<Config::General>,
L<Config::Tiny> and L<Config::IniFiles>.

This module is based on an earlier module I wrote. It was never
released to the public via CPAN, but I did post a version of it
on PerlMonks:  http://www.perlmonks.org/index.pl?node_id=113685
Other versions of this are also available if anyone wants to see them.

=head1 COPYRIGHT

Previous version as C<Config::SimpleConf>, Copyright iredale consulting 2001-2003

This version as C<Config::Trivial>, Copyright iredale consulting 2004

Portions from L<XML::RSS::Tools>, Copyright iredale consulting 2002-2004

OSI Certified Open Source Software.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published
by the Free Software Foundation; either version 2 of the License,
or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details. 

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston,
MA  02111, USA.

=cut
