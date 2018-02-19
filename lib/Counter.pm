package Counter;

use strict;
use warnings;

use lib 'lib';
use Utils;

use v5.18;

sub import {
    no strict 'refs';
    no warnings 'redefine';

    my $self = shift;
    my @symbols = map { "$self\::$_" } grep { defined *{"$self\::$_"}{CODE} } keys %{"$self\::"};
    foreach my $fn (@symbols) {
	*{$fn} = counter( $fn, \&{$fn} );
    }

    *{"$self\::print_counter"} = \&print_results;
}

my %counters;

sub counter {
    my $name = shift;
    my $fn = shift;
    return sub {
	my $args = join ',' => map { Utils::to_string($_) } @_;
	$counters{$name}{'('.$args.')'}++;
	return $fn->(@_);
    };
}

sub print_results {
    for my $sub_name (keys %counters) {
	for my $args (keys %{$counters{$sub_name}}) {
	    my $count = $counters{$sub_name}{$args};
	    say $count, " * ", $sub_name, $args;
	}
    }
}

#sub results { \%counters }

1;
