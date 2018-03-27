package SixPlayerSession;

use v5.18;

use strict;
use warnings;

use Mouse;

use Session;

use Tiles qw(draw_tile draw_tiles);
use Utils qw(partition get_tag);

extends 'Session';

sub create {
    my $td = shift;
    my @names = @_;

    my ($mecatol, $deck) = draw_tile( "mecatolrex", $td );

    my $map = build_map( $mecatol, @names );

    my ($home, $red, $blue) = partition(
	sub { $_[0]->type eq 'home' },
	\&Tiles::red_backed,
	@$deck
    );

    my @players;

    foreach my $n (0 .. $#names) {
	my ($hand, $t);

	($t, $red) = draw_tiles(2, $red);
	push @$hand, @$t;
	($t, $blue) = draw_tiles(3, $blue);
	push @$hand, @$t;

	push @players, Player->new(
	    id	    => get_tag,
	    name    => $names[$n],
	    hand    => $hand
	);
    }

    return SixPlayerSession->new( map => $map, players => \@players, id => get_tag );
}

sub build_map {
    my $center = shift;
    my @names = @_;

    my @tiles;

    push @tiles, [ 0, 0, $center ];

    for my $n ( 0 .. $#names ) {
	push @tiles, [ 3, (($n+1)*3-1), Tile->new(
	    name	=> 'player_tile',
	    type	=> 'home',
	    text	=> $names[$n],
	    template	=> 'single_text'
	) ];
    }

    return Map->new( tiles => \@tiles );
}

1;
