package Session;

use v5.18;

use Mouse;

use YAML ();

use Tiles qw(draw_tile draw_tiles);
use Utils qw(partition get_tag);

use Map;
use Player;
use Tile;

use SixPlayerSession;

has map		=> (is => 'ro', required => 1, isa => 'Map');
has players	=> (is => 'ro', required => 1, isa => 'ArrayRef[Player]');
has id		=> (is => 'ro', required => 1, isa => 'Str');
has previous	=> (is => 'ro', isa => 'Session' );

state $tile_data = [ map { Tile->new(%$_) } @{YAML::LoadFile('./data/tiles.yml')->{tiles}} ];

my %create_table = (
    6 => \&SixPlayerSession::create
);

sub create {
    shift;

    my @names = @_;

    return $create_table{ scalar @names }->($tile_data, @names);
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
    return @p ? $p[0] : undef;
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

sub play {
    my $self = shift;
    my $i = shift;
    my $type = $self->active_player->hand($i)->type;
    return sub {
	my ($r, $n) = @_;
	my @a = $self->map->allowed_types($r, $n);
	if ( grep { $_ eq $type } @a ) {
	    my ($tile, $player) = $self->active_player->play($i);
	    my $active = $self->active_player;
	    return Session->new(
		map	    => $self->map->place($tile)->($r, $n),
		players	    => [ map { $_ == $active ? $player : $_ } @{$self->players} ],
		id	    => $self->id,
		previous    => $self
	    );
	}
    };
}

1;
