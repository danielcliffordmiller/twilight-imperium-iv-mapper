#!/usr/bin/perl
#
use strict;

use lib qw(lib ../lib);

use Utils;

use v5.12;

sub is_this_number_even {
    return not ($_[0] % 2);
}

say "2 is even" if is_this_number_even(2);
say "1 is not"	unless is_this_number_even(1);
say;

my ($list_of_3, $list_of_even, $list_of_leftovers) =
    partition(
	sub { $_[0] == 3 }, # <- this function evaluates to true if its argument == 3
	\&is_this_number_even, # <- this function evals to true if its argument is even
	(1,2,3,4,5) # <- this is the list of whatever that we are partitioning
    );

say "list of all numbers that equal 3:";
say for (@$list_of_3);
say;
say "list of all even numbers:";
say for (@$list_of_even);
say;
say "list of all leftover numbers:";
say for (@$list_of_leftovers);
