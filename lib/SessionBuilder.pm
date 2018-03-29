package SessionBuilder;

use v5.18;

use strict;
use warnings;

use SixPlayerSession;
use FivePlayerSession;
use FourPlayerSession;
use ThreePlayerSession;

use SessionConfig;

use Tile;

use Tiles qw(draw_tile draw_tiles);
use Utils qw(partition get_tag random_shift shuffle);

our @ISA = qw(Exporter);

our @EXPORT_OK = qw(create_session);

state $tile_data = [ map { Tile->new(%$_) } @{YAML::LoadFile('./data/tiles.yml')->{tiles}} ];

state $session_config = { map {
    $_->{players} = [ map { SessionConfig::Player->new($_) } @{$_->{players}} ];
    ( $_->{count}, SessionConfig->new( $_ ) )
} @{YAML::LoadFile('./data/session_conf.yml')} };

sub create_session {
    my @names = shuffle(@_);

    my $conf = $session_config->{ @names } or die "needs 3 to 6 players";

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

	($t, $red) = draw_tiles($conf->red_tiles, $red);
	push @$hand, @$t;
	($t, $blue) = draw_tiles($conf->blue_tiles, $blue);
	push @$hand, @$t;

	push @players, Player->new(
	    id	    => get_tag,
	    name    => $names[$n],
	    hand    => $hand
	);
    }

    # random_shift places the players such that the speaker is $players[0]
    return $conf->class_name->new( map => $map, players => [ random_shift(@players) ], id => get_tag );
}

sub build_map {
    my $center = shift;
    my $conf = shift;
    my @names = @_;

    my @tiles;

    push @tiles, [ 0, 0, $center ], map {
	[ @{$conf->players($_)->coord}, Tile->new(
	    name	=> 'player_tile',
	    type	=> 'home',
	    text	=> $names[$_],
	    template	=> 'single_text'
	) ]
    } ( 0 .. $#names );

    return Map->new( tiles => \@tiles, non_map_spaces =>
	[ $conf->non_map ] );
}

1;
