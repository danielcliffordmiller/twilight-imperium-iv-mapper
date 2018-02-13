package TileMap;

use strict;
use warnings;

use v5.18;

sub ring_full {
    my ($map_data, $r) = @_;

    return $r*6 == grep { $_->[0] == $r } @$map_data;
}

sub allowed_types {
    my ($map_data, $r, $n) = @_;

    return $r == 1 || ring_full( $map_data, $r-1 ) ?
	qw(standard anomaly) : ();
}

1;
