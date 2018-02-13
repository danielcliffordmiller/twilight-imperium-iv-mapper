package TileMap;

use strict;
use warnings;

use v5.18;

use Tiles;

sub ring_full {
    my ($map_data, $r) = @_;

    return $r*6 == grep { $_->[0] == $r } @$map_data;
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

    return map {
	my $c = $_;
	(grep { $_->[0] == $c->[0] && $_->[1] == $c->[1]; } @$map_data)[0];
    } neighbor_coords(@_);
}

sub allowed_types {
    my ($map_data, $r, $n) = @_;

    my @allowed;
    if ($r == 1 || ring_full( $map_data, $r-1 ) ) {
	push @allowed, 'standard';
	push @allowed, 'anomaly' unless grep { Tiles::type($_->[2]) eq "anomaly" } get_neighbors(@_);
    }
    return @allowed;
}

1;
