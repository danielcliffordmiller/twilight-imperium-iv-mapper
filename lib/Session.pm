package Session;

use v5.18;

use Mouse;

use YAML ();

use Tiles qw(draw_tile draw_tiles);
use Utils qw(partition get_tag random_shift shuffle);

use Map;
use Player;
use Tile;

has map		=> (is => 'ro', required => 1, isa => 'Map', reader => '_map');
has players	=> (is => 'ro', required => 1, isa => 'ArrayRef[PlayerRole]');
has id		=> (is => 'ro', required => 1, isa => 'Str');
has play_order	=> (is => 'ro', isa => 'Session::Order');
has previous	=> (is => 'ro', isa => 'Session' );

sub dump {
    my $self = shift;

    return {
	id => $self->id,
	map => $self->_map->dump,
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

    return $self->player($self->play_order->active_id);
}

sub is_active_player {
    my $self = shift;
    my $p_id = shift;
    return $self->play_order->active_id eq $p_id;
}

sub iterator {
    my $self = shift;
    my $p_id = shift;
    my $view = $self->player( $p_id )->view;
    return $self->_map->iterator( $view );
}

sub play {
    my $self = shift;
    my $i = shift;
    my $type = $self->active_player->hand($i)->type;
    return sub {
	my ($r, $n) = @_;
	if ( $self->_map->is_legal_play( $type, $r, $n ) ) {
	    my ($tile, $player) = $self->active_player->play($i);
	    my $active = $self->active_player;
	    return Session->new(
		map	    => $self->_map->place($tile)->($r, $n),
		players	    => [ map { $_ == $active ? $player : $_ } @{$self->players} ],
		id	    => $self->id,
		play_order  => $self->play_order->next_order,
		previous    => $self
	    );
	}
    };
}

package Session::Order;

use Mouse;

use Player;

has 'active_id'	    => (isa => 'Str', is => 'ro', required => 1);
has 'next_order'    => (isa => 'Session::Order', is => 'ro');

1;
