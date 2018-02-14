package TileMap;

use strict;
use warnings;

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

sub allowed_types {
    my ($map_data, $r, $n) = @_;

    my @allowed;
    if ($r == 1 || ring_full( $map_data, $r-1 ) ) {
	push @allowed, 'standard';
	push @allowed, 'anomaly' unless any_neighbor( @_, sub { Tiles::type($_[0]) eq 'anomaly' } );
	push @allowed, 'beta' unless any_neighbor( @_, sub { Tiles::type($_[0]) eq 'beta' } );
	push @allowed, 'alpha' unless any_neighbor( @_, sub { Tiles::type($_[0]) eq 'alpha' } );
    }
    return @allowed;
}

1;
