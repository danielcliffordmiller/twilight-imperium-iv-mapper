package SessionBuilder;

use v5.18;

use strict;
use warnings;

use SixPlayerSession;
use FivePlayerSession;
use FourPlayerSession;
use ThreePlayerSession;

use Tile;

use Tiles qw(draw_tile draw_tiles);
use Utils qw(partition get_tag random_shift shuffle);

our @ISA = qw(Exporter);

our @EXPORT_OK = qw(create_session);

state $tile_data = [ map { Tile->new(%$_) } @{YAML::LoadFile('./data/tiles.yml')->{tiles}} ];

my %session_config = (
    3 => {
	create	=> sub { return ThreePlayerSession->new( @_ ) },
	tiles	=> {
	    red	    => 2,
	    blue    => 6
	},
	players	=> [
	    [ 3, 2 ],
	    [ 3, 8 ],
	    [ 3, 14 ],
	]
    },
    4 => {
	create	=> sub { return FourPlayerSession->new( @_ ) },
	tiles	=> {
	    red	    => 3,
	    blue    => 5,
	},
	players	=> [
	    [ 3, 3 ],
	    [ 3, 7 ],
	    [ 3, 12 ],
	    [ 3, 16 ],
	]
    },
    5 => {
	create	=> sub { return FivePlayerSession->new( @_ ) },
	tiles	=> {
	    red	    => 2,
	    blue    => 4,
	},
	players	=> [
	    [ 3, 2 ],
	    [ 3, 5 ],
	    [ 3, 8 ],
	    [ 3, 12 ],
	    [ 3, 16 ],
	],
    },
    6 => {
	create	=> sub { return SixPlayerSession->new( @_ ) },
	tiles	=> {
	    red	    => 2,
	    blue    => 3,
	},
	players	=> [
	    [ 3, 2 ],
	    [ 3, 5 ],
	    [ 3, 8 ],
	    [ 3, 11 ],
	    [ 3, 14 ],
	    [ 3, 17 ],
	]
    }
);

my $w = "SixPlayerSession";

sub create_session {
    my @names = shuffle(@_);

    my $conf = $session_config{ @names } or die "needs 3 to 6 players";

    my ($mecatol, $deck) = draw_tile( "mecatolrex", $tile_data );

    my $map = build_map( $mecatol, $conf, @names );

    my ($home, $red, $blue) = partition(
	sub { $_[0]->type eq 'home' },
	\&Tiles::red_backed,
	@$deck
    );

    my @players;

    foreach my $n (0 .. $#names) {
	my ($hand, $t);

	($t, $red) = draw_tiles($conf->{tiles}{red}, $red);
	push @$hand, @$t;
	($t, $blue) = draw_tiles($conf->{tiles}{blue}, $blue);
	push @$hand, @$t;

	push @players, Player->new(
	    id	    => get_tag,
	    name    => $names[$n],
	    hand    => $hand
	);
    }

    # random_shift places the players such that the speaker is $players[0]
    return $conf->{create}->( map => $map, players => [ random_shift(@players) ], id => get_tag );
}

sub build_map {
    my $center = shift;
    my $conf = shift;
    my @names = @_;

    my @tiles;

    push @tiles, [ 0, 0, $center ], map {
	[ @{$conf->{players}->[$_]}, Tile->new(
	    name	=> 'player_tile',
	    type	=> 'home',
	    text	=> $names[$_],
	    template	=> 'single_text'
	) ]
    } ( 0 .. $#names );

    return Map->new( tiles => \@tiles );
}

1;
