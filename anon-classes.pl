#!/usr/bin/env perl

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

use 5.016;
use warnings;

use FindBin qw($Bin);
use lib $Bin;

use AnonClass;

my ($duck, $swan);

$duck = AnonClass->new({
		'data' => sub : lvalue { state $h; $h = {} unless $h; $h },
		'speak' => sub { return "quack" },
		'feed' => sub {
			my $self = shift;
			return $self->data->{food} unless @_;
			$self->data->{food} += $_[0] || 1;
		},
		'AUTOLOAD_ANON' => sub {
			my ($self, $method) = @_;
			say "You cannot $method a duck." unless $method =~ /^[A-Z]+$/;
		},
	});

$swan = AnonClass->new({
		'speak' => sub { return 'honk' },
		'color' => sub { return 'white' },
	});

say "duck says ", $duck->speak;
$duck->feed(1);
$duck->feed(3);
say "duck has now been fed ", $duck->feed, " units (expected: 4)";
$duck->poke();

say "a ", $swan->color, " swan says ", $swan->speak;
