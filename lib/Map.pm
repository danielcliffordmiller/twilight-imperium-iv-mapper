package Map;

use Mouse;

use strict;
use warnings;

use constant RINGS => 3;

use v5.18;

use Tiles;

has 'tiles' => (is => 'ro', isa => 'ArrayRef', reader => '_tiles', required => 1);
has 'num_players' => (is => 'ro', isa => 'Int', reader => '_num_players', required => 1);

sub tiles_in_ring {
    my ($ring) = @_;
    return $ring == 0 ? 1 : $ring * 6;
}

sub _neighbor_coords {
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

sub _ring_full {
    my ($self, $r) = @_;

    return $r*6 == grep { $_->[0] == $r } @{$self->_tiles};
}

sub tile {
    my ($self, $r, $n) = @_;

    my @a = grep { $_->[0] == $r && $_->[1] == $n } @{$self->_tiles};
    return @a ? $a[0][2] : undef;
}

sub get_neighbors {
    my $self = shift;

    my @res;
    for my $c (_neighbor_coords(@_)) {
	my $t = $self->tile( @$c );
	push @res, $t if $t;
    }
    return @res;
}

sub any_neighbor {
    my ($self, $r, $n, $fn) = @_;

    my @a = $self->get_neighbors($r, $n);

    return grep { $fn->($_) } $self->get_neighbors($r, $n);
}

sub empty_in_ring {
    my ($self, $r) = @_;

    my @res;
    for my $n (0 .. $r * 6 - 1) {
	push @res, [ $r, $n ] unless grep { $_->[0] == $r && $_->[1] == $n } $self->_tiles;
    }
    return @res;
}

sub can_be_placed {
    my ($self, $r, $n, $type) = @_;

    return 1 unless $self->any_neighbor( $r, $n, sub { $_[0]{type} eq $type } );

    return 0 unless $r == RINGS;

    for my $c ($self->empty_in_ring($r)) {
	return 0 unless $self->any_neighbor( $c->[0], $c->[1], sub { $_[0]{type} eq $type } );
    }
    return 1;
}

sub allowed_types {
    my $self = shift; 
    my ($r, $n) = @_;

    my @allowed;
    if ($r == 1 || $self->_ring_full( $r-1 ) ) {
	push @allowed, 'standard';
	push @allowed, 'anomaly'    if $self->can_be_placed( @_, 'anomaly' );
	push @allowed, 'beta'	    if $self->can_be_placed( @_, 'beta'    );
	push @allowed, 'alpha'	    if $self->can_be_placed( @_, 'alpha'   );
    }
    return @allowed;
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
	push @{$self->_tiles}, [$r, $n, $tile];
    };
}

sub iterator {
    my $self = shift;
    my @res;
    my $tile;
    for my $r ( 0 .. RINGS ) {
	for my $n ( 0 .. (tiles_in_ring($r)-1) ) {
	    $tile = $self->tile($r, $n);
	    push @res, Map::Entry->new(
		r => $r,
		n => $n,
		$tile ? (tile => $tile) : (allowed_types => [$self->allowed_types($r, $n)])
	    );
	}
    }
    return sub {
	shift @res;
    };
}

around 'BUILDARGS' => sub {
    my $orig = shift;
    my $self = shift;
    my $center = shift;
    my @names = @_;

    my @tiles;

    push @tiles, [ 0, 0, $center ];

    for my $n ( 0 .. $#names ) {
	push @tiles, [ 3, (($n+1)*3-1), {
	    name	=> 'player_tile',
	    type	=> 'home',
	    text	=> $names[$n],
	    template	=> 'single_text'
	} ];
    }

    return $self->$orig( tiles => \@tiles, num_players => scalar @names );
};

package Map::Entry;

use Mouse;

has 'r'		    => (is => 'ro', isa => 'Str', required => 1);
has 'n'	    	    => (is => 'ro', isa => 'Str', required => 1);
has 'tile'  	    => (is => 'ro', isa => 'HashRef', predicate => 'has_tile' );
has 'allowed_types' => (is => 'ro', isa => 'ArrayRef', default => sub { [] });

sub rn {
    my $self = shift;
    return ($self->r, $self->n);
}

around 'allowed_types' => sub {
    my $orig = shift;
    my $self = shift;
    return @{$self->$orig()};
};

1;
