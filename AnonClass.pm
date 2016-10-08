# Copyright 2016 sapphirecat <https://github.com/sapphirecat>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

package AnonClass;

use 5.010;
use strict;
use warnings;
use Carp qw(croak);

my $instances = {};
our $AUTOLOAD;

sub new {
	my ($cls, $impl, $name) = @_;
	my ($self, $key);

	croak "Anonymous class implementation must be a HASH ref" unless ref $impl eq 'HASH';
	$key = "$impl-" . substr(rand(), 2);
	$self = \$key;
	$instances->{$key} = { impl => $impl, name => $name // $key };

	bless $self, (ref $cls || $cls);
}

sub AUTOLOAD {
	my $obj = shift;
	my ($impl, $name);
	croak __PACKAGE__.'::AUTOLOAD called on non-ref' unless ref $obj;
	croak __PACKAGE__."::AUTOLOAD called on unknown instance '$$obj'" unless exists $instances->{$$obj};

	$impl = $instances->{$$obj}->{impl};
	$name = $AUTOLOAD;
	$name =~ s/^.*:://;
	if (exists($impl->{$name})) {
		return &{$impl->{$name}}($obj, @_);
	} elsif (exists($impl->{AUTOLOAD_ANON})) {
		# I had to change the name from just AUTOLOAD because I want to pass
		# $AUTOLOAD (I don't have a package to hide it in like Perl itself.)
		return &{$impl->{AUTOLOAD_ANON}}($obj, $name, @_);
	} else {
		croak "Undefined method $name called on anonymous class instance $instances->{$$obj}{name}";
	}
}

no warnings; # suppress following "useless use of a constant" during standalone `perl -c`
6.28;
