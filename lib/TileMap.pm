package TileMap;

use strict;
use warnings;

use constant RINGS => 3;

use v5.18;

use Tiles;

sub ring_full {
    my ($map_data, $r) = @_;

    return $r*6 == grep { $_->[0] == $r } @$map_data;
}

sub get_tile {
    my ($map_data, $r, $n) = @_;

    my @a = grep { $_->[0] == $r && $_->[1] == $n } @$map_data;
    return @a ? $a[0][2] : undef;
}

sub neighbor_coords {
    my ($r, $n) = @_;
    my @res = map { [$r, $_ % ($r*6)] } ($n-1, $n+1);
    return @res if $r == 1;
    my $n2;
    { use integer;
	$n2 = $n-(($n+1)/$r);
    }
    push @res, [$r-1, $n2];
    push @res, [$r-1, ($n2-1) % (($r-1)*6)] if ($n+1) % $r;
    return @res;
}

sub get_neighbors {
    my $map_data = shift;

    my @res;
    for my $c (neighbor_coords(@_)) {
	my $t = get_tile( $map_data, @$c );
	push @res, $t if $t;
    }
    return @res;
}

sub any_neighbor {
    my ($map_data, $r, $n, $fn) = @_;

    my @a = get_neighbors($map_data, $r, $n);

    return grep { $fn->($_) } get_neighbors($map_data, $r, $n);
}

sub empty_in_ring {
    my ($map_data, $r) = @_;

    my @res;
    for my $n (0 .. $r * 6 - 1) {
	push @res, [ $r, $n ] unless grep { $_->[0] == $r && $_->[1] == $n } @$map_data;
    }
    return @res;
}

sub can_be_placed {
    my ($map_data, $r, $n, $type) = @_;

    return 1 unless any_neighbor( $map_data, $r, $n, sub { Tiles::type($_[0]) eq $type } );

    return 0 unless $r == RINGS;

    for my $c (empty_in_ring($map_data, $r)) {
	return 0 unless any_neighbor( $map_data, $c->[0], $c->[1], sub { Tiles::type($_[0]) eq $type } );
    }
    return 1;
}

sub allowed_types {
    my ($map_data, $r, $n) = @_;

    my @allowed;
    if ($r == 1 || ring_full( $map_data, $r-1 ) ) {
	push @allowed, 'standard';
	push @allowed, 'anomaly'    if can_be_placed( @_, 'anomaly' );
	push @allowed, 'beta'	    if can_be_placed( @_, 'beta'    );
	push @allowed, 'alpha'	    if can_be_placed( @_, 'alpha'   );
    }
    return @allowed;
}

1;
