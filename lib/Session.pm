package Session;

use v5.18;

use Mouse;

use YAML ();

use Tiles qw(draw_tile draw_tiles);
use Utils qw(partition get_tag);

use Map;
use Player;
use Tile;

has map		=> (is => 'ro', writer => '_map', isa => 'Map');
has players	=> (is => 'ro', isa => 'ArrayRef[Player]');
has id		=> (is => 'ro', isa => 'Str');

state $tile_data = [ map { Tile->new(%$_) } @{YAML::LoadFile('./data/tiles.yml')->{tiles}} ];

sub create {
    shift;
    my @names = @_;

    my ($mecatol, $deck) = draw_tile( "mecatolrex", $tile_data );

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

    return Session->new( map => $map, players => \@players, id => get_tag );
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

sub dump {
    my $self = shift;

    return {
	id => $self->id,
	map => $self->map->dump,
	players => [ map { $_->dump } @{$self->players} ]
    };
}

sub player {
    my $self = shift;
    my $id = shift;

    my @p = grep { $_->id eq $id } @{ $self->players };
    return @p ? $p[0] : 0;
}

sub active_player {
    my $self = shift;

    my $num_map_tiles = $self->map->num_played;
    my $num_players = scalar @{ $self->players };

    my $offset = $num_map_tiles % $num_players;

    my $cycles;
    { use integer; $cycles = $num_map_tiles / $num_players }
    return $cycles % 2 ? $self->players->[$offset] : $self->players->[$num_players-($offset+1)];
}

sub is_active_player {
    my $self = shift;
    my $p_id = shift;
    return $self->active_player == $self->player($p_id);
}

sub _update_active_player {
    my $self = shift;
    my $player = shift;
    my $players = $self->players;
    foreach my $i (0 .. $#$players) {
	if ($self->is_active_player( $players->[$i]->id )) {
	    $players->[$i] = $player;
	    last;
	}
    }
}

sub play {
    my $self = shift;
    my $i = shift;
    my $type = $self->active_player->hand($i)->{type};
    return sub {
	my ($r, $n) = @_;
	my @a = $self->map->allowed_types($r, $n);
	if ( grep { $_ eq $type } @a ) {
	    my ($tile, $player) = $self->active_player->play($i);
	    my $active = $self->active_player;
	    return Session->new(
		map	    => $self->map->place($tile)->($r, $n),
		players	    => [ map { $_ == $active ? $player : $_ } @{$self->players} ],
		id	    => $self->id
	    );
	}
    };
}

1;
