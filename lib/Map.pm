package Map;

use Mouse;

use strict;
use warnings;

use constant RINGS => 3;
# (3 + 2 + 1) * 6; (doesn't include the center)
use constant PLAYABLE_SPOTS => 36;

use v5.18;

has 'tiles' => (is => 'ro', isa => 'ArrayRef', reader => '_tiles', required => 1);
has 'non_map' => (is => 'ro', isa => 'ArrayRef', reader => '_non_map', default => sub { [] } );
has 'warps' => (is => 'ro', isa => 'HashRef[ArrayRef]', reader => '_warps', default => sub { {} });

sub _tiles_in_ring {
    my $ring = shift;
    return $ring == 0 ? 1 : $ring * 6;
}

sub dump {
    my $self = shift;
    return [ @{ $self->_tiles } ];
}

sub _neighbor_coords {
    my $self = shift;
    my ($r, $n) = @_;
    my @res = map { [$r, $_ % ($r*6)] } ($n-1, $n+1);
    #return @res if $r == 1;
    if ($r > 1) {
	my $n2;
	{ use integer;
	    $n2 = $n-(($n+1)/$r);
	}
	push @res, [$r-1, $n2];
	push @res, [$r-1, ($n2-1) % (($r-1)*6)] if ($n+1) % $r;
    }
    push @res, @{$self->_warps->{"$r,$n"}} if exists $self->_warps->{"$r,$n"};
    return grep { ! ($_ ~~ @{$self->_non_map}) } @res;
}

sub _ring_full {
    my ($self, $r) = @_;

    my $num_non_map = grep { $_->[0] == $r } @{$self->_non_map};
    return $r*6-$num_non_map == grep { $_->[0] == $r } @{$self->_tiles};
}

sub tile {
    my ($self, $r, $n) = @_;

    my @a = grep { $_->[0] == $r && $_->[1] == $n } @{$self->_tiles};
    return @a ? $a[0][2] : undef;
}

sub _get_neighbors {
    my $self = shift;

    my @res;
    for my $c ($self->_neighbor_coords(@_)) {
	my $t = $self->tile( @$c );
	push @res, $t if $t;
    }
    return @res;
}

sub _any_neighbor {
    my ($self, $r, $n, $fn) = @_;

    my @a = $self->_get_neighbors($r, $n);

    return grep { $fn->($_) } $self->_get_neighbors($r, $n);
}

sub _empty_in_ring {
    my ($self, $r) = @_;

    my @res;
    for my $n (0 .. $r * 6 - 1) {
	push @res, [ $r, $n ] unless $self->tile($r, $n) || $self->_is_non_map_space( $r, $n );
    }
    return @res;
}

sub _can_be_placed {
    my ($self, $r, $n, $type) = @_;

    return 1 unless $self->_any_neighbor( $r, $n, sub { $_[0]->type eq $type } );

    return 0 unless $r == RINGS;

    for my $c ($self->_empty_in_ring($r)) {
	return 0 unless $self->_any_neighbor( $c->[0], $c->[1], sub { $_[0]->type eq $type } );
    }
    return 1;
}

sub _allowed_types {
    my $self = shift; 
    my ($r, $n) = @_;

    my @allowed;
    if ($r == 1 || $self->_ring_full( $r-1 ) ) {
	push @allowed, 'standard';
	push @allowed, 'anomaly'    if $self->_can_be_placed( @_, 'anomaly' );
	push @allowed, 'beta'	    if $self->_can_be_placed( @_, 'beta'    );
	push @allowed, 'alpha'	    if $self->_can_be_placed( @_, 'alpha'   );
    }
    return @allowed;
}

sub _is_non_map_space {
    my ($self, $r, $n) = @_;

    return scalar grep { $_->[0] == $r && $_->[1] == $n } @{ $self->_non_map };
}

sub is_legal_play {
    my ($self, $type, $r, $n) = @_;

    return scalar grep { $_ eq $type } $self->_allowed_types($r, $n);
}

sub num_played {
    my $self = shift;
    return scalar @{ $self->_tiles } - 1;
    # subtract 1 because of mecatol rex
}

sub place {
    my ($self, $tile) = @_;
    return sub {
	my ($r, $n) = @_;
	return Map->new(
	    tiles => [ [$r, $n, $tile], @{$self->_tiles} ],
	    non_map => $self->_non_map,
	    warps => $self->_warps
	);
    };
}

sub iterator {
    my $self = shift;
    my @res;
    my $tile;
    my $view = shift;
    for my $r ( 0 .. RINGS ) {
	for my $n ( 0 .. (_tiles_in_ring($r)-1) ) {
	    next if $self->_is_non_map_space($r, $n);
	    $tile = $self->tile($r, $n);
	    push @res, Map::Entry->new(
		r	    => $r,
		n	    => $n,
		view	    => $view,
		$tile ? (tile => $tile) : (allowed_types => [$self->_allowed_types($r, $n)])
	    );
	}
    }
    return sub {
	shift @res;
    };
}

package Map::Entry;

use Mouse;
use Tile;

has 'tile'  	    => (is => 'ro', isa => 'Tile', predicate => 'has_tile' );
has 'allowed_types' => (is => 'ro', isa => 'ArrayRef', default => sub { [] });
has 'view'	    => (is => 'ro', isa => 'Int', required => 1);

around 'allowed_types' => sub {
    my $orig = shift;
    my $self = shift;
    return @{$self->$orig()};
};

with 'ViewPointRole';

1;
