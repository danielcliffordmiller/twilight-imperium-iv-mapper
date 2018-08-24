package TwilightImperiumMapper::Model::SessionBuilder;

use v5.18;

use strict;
use warnings;

use TwilightImperiumMapper::Model::Session;
use TwilightImperiumMapper::Model::SessionConfig;

use TwilightImperiumMapper::Model::Map;
use TwilightImperiumMapper::Model::Tile;

use TwilightImperiumMapper::Model::Player;
use TwilightImperiumMapper::Model::ShadowPlayer;

use Utils::Tiles qw(draw_tile draw_tiles red_backed);

use Utils qw(partition get_tag random_shift);

use YAML ();

use List::Util qw(shuffle);

our @ISA = qw(Exporter);

our @EXPORT_OK = qw(create_session);

state $tile_data = [ map { TwilightImperiumMapper::Model::Tile->new(%$_) } @{YAML::LoadFile('./data/tiles.yml')->{tiles}} ];

state $session_config = { map {
    ( $_->{count}, TwilightImperiumMapper::Model::SessionConfig->new( $_ ) )
} @{YAML::LoadFile('./data/session_conf.yml')} };

sub create_session {
    my @names = shuffle(@_);

    my $conf = $session_config->{ @names } or die "needs 3 to 6 players";

    my ($mecatol, $deck) = draw_tile( "mecatolrex", $tile_data );

    my $map = build_map( $mecatol, $conf, @names );

    my ($home, $red, $blue) = partition(
	sub { $_[0]->type eq 'home' },
	\&red_backed,
	@$deck
    );

    my @players;

    foreach my $n (0 .. $#names) {
	my ($hand, $t);

	($t, $red) = draw_tiles($conf->red_tiles, $red);
	push @$hand, @$t;
	($t, $blue) = draw_tiles($conf->blue_tiles, $blue);
	push @$hand, @$t;

	push @players, TwilightImperiumMapper::Model::Player->new(
	    id	    => get_tag,
	    name    => $names[$n],
	    view    => $conf->view($n),
	    hand    => $hand
	);
    }

    # random_shift places the players such that the speaker is $players[0]
    @players = random_shift(@players);

    # this code could be cleaned up and would help from a proper shadow_conf class
    if ($conf->shadow) {
        my @shadow_players = @{$conf->shadow->{players}};
        for my $i (0..$#shadow_players) {
	    say "creating ", $i + 1, " player", $i ? "s" : "";
            my ($hand, $t);
            if (defined $shadow_players[$i]{red_tiles}) {
        	($t, $red) = draw_tiles($shadow_players[$i]{red_tiles}, $red);
        	push @$hand, @$t;
            }
            if (defined $shadow_players[$i]{blue_tiles}) {
        	($t, $blue) = draw_tiles($shadow_players[$i]{blue_tiles}, $blue);
        	push @$hand, @$t;
            }
            $players[$i] = TwilightImperiumMapper::Model::ShadowPlayer->new(
        	player	=> $players[$i],
		hand	=> $hand
	    );
        }
    }

    return TwilightImperiumMapper::Model::Session->new(
	map => $map,
	players => \@players,
	id => get_tag,
	play_order => build_player_order($conf, @players)
    );
}

sub build_player_order {
    my $conf = shift;
    my @players = @_;

    my $num_spots = TwilightImperiumMapper::Model::Map::PLAYABLE_SPOTS - ($conf->players + $conf->non_map + $conf->num_shadow_tiles);

    my @order = map {
	my $offset = $_ % $conf->players;
	int($_ / $conf->players) % 2 ?
	    $conf->players - ($offset + 1) :
	    $offset
    } (0..$num_spots-1);

    unshift @order, map { $_ - 1 } @{$conf->shadow->{order}} if $conf->shadow;

    my @ids = reverse map { $players[$_]->id } @order;

    # TODO fix the code to remove this line
    unshift @ids, $ids[0]; # fix bug so final player can place last tile

    my $order;
    for my $id (@ids) {
	$order = $order ? 
	    TwilightImperiumMapper::Model::Session::Order->new(active_id => $id, next_order => $order) :
	    TwilightImperiumMapper::Model::Session::Order->new(active_id => $id);
    }

    return $order;
}

sub build_map {
    my $center = shift;
    my $conf = shift;
    my @names = @_;

    my @tiles;

    push @tiles, [ 0, 0, $center ], map {
	[ @{$conf->players($_)}, TwilightImperiumMapper::Model::Tile->new(
	    name	=> 'player_tile',
	    type	=> 'home',
	    text	=> $names[$_],
	    template	=> 'single_text'
	) ]
    } ( 0 .. $#names );

    return TwilightImperiumMapper::Model::Map->new(
	tiles => \@tiles,
	non_map => [ $conf->non_map ],
	$conf->adjacent ? (warps => $conf->adjacent) : ()
    );
}

1;
