package Tiles;

use v5.12;
use strict;
use warnings;

use Utils;

sub red_backed {
    $_[0]{type} eq 'anomaly' ||
    $_[0]{name} eq 'space' ||
    $_[0]{name} eq 'alpha' ||
    $_[0]{name} eq 'beta'
}

sub draw {
    my $tiles = shift;
    my $tile = $tiles->[int(rand(@$tiles))];
    return $tile, [ grep { $_ != $tile } @$tiles ];
}

sub draw_tiles {
    my ($n, $tiles) = @_;
    my $hand = [];

    my $t;

    for my $i (0 .. $n-1) {
	($t, $tiles) = draw($tiles);
	push @$hand, $t;
    }
    return $hand, $tiles;
}

sub draw_tile {
    my ($name, $tiles) = @_;

    my @tiles = partition( sub { $_[0]{name} eq $name }, @$tiles );
    return ($tiles[0][0], $tiles[1]);
}

1;
