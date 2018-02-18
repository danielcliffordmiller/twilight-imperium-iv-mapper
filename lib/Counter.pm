package counter;

use strict;
use warnings;

use lib 'lib';
use Utils;

use v5.18;

sub import {
    no strict 'refs';
    no warnings 'redefine';
    my ($self, $package) = @_;
    require $package.".pm";
    $package->import();
    my $c = caller();
    for (keys %{"$package\::"}) {
	next if /import/;
	*{"$c\::$package\::$_"} = counter( $package, $_,  \&{"$package\::$_"} );
    }
}

my %counters;

sub counter {
    my $package = shift;
    my $name = shift;
    my $fn = shift;
    return sub {
	my $args = join ',' => map { Utils::to_string($_) } @_;
	my @r = $fn->(@_);
	$counters{$package}{$name}{'('.$args.')->'.Utils::to_string(@r)}++;
	return @r;
    };
}

sub print_results {
    for my $package (keys %counters) {
	for my $sub_name (keys %{$counters{$package}}) {
	    for my $args (keys %{$counters{$package}{$sub_name}}) {
		my $count = $counters{$package}{$sub_name}{$args};
		say $count, " * ", $sub_name, $args;
	    }
	}
    }
}

#sub results { \%counters }

1;
