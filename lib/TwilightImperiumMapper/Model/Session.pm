package TwilightImperiumMapper::Model::Session;

use v5.18;

use Mouse;

use Hash::MD5 qw(sum);

use TwilightImperiumMapper::Model::PlayerLog;

has map		=> (is => 'ro', required => 1, isa => 'TwilightImperiumMapper::Model::Map', reader => '_map');
has players	=> (is => 'ro', required => 1, isa => 'ArrayRef[TwilightImperiumMapper::Model::PlayerRole]');
has id		=> (is => 'ro', required => 1, isa => 'Str');
has play_order	=> (is => 'ro', isa => 'TwilightImperiumMapper::Model::Session::Order');
has previous	=> (is => 'ro', isa => 'TwilightImperiumMapper::Model::Session' );
has player_log	=> (is => 'ro', isa => 'TwilightImperiumMapper::Model::PlayerLog', default => sub { TwilightImperiumMapper::Model::PlayerLog->new }, reader => '_player_log');

sub dump {
    my $self = shift;

    return {
	id => $self->id,
	map => $self->_map->dump,
	players => [ map { $_->dump } @{$self->players} ],
	player_log => $self->_player_log->dump,
    };
}

sub md5 {
    my $self = shift;
    return sum($self->_map);
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

sub map_iterator {
    my $self = shift;
    my $p_id = shift;
    my $view = $self->player( $p_id )->view;
    return $self->_map->iterator( $view );
}

sub log_iterator {
    my $self = shift;
    my $p_id = shift;
    my $view = $self->player( $p_id )->view;
    return $self->_player_log->iterator( $view );
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
	    return TwilightImperiumMapper::Model::Session->new(
		map	    => $self->_map->place($tile)->($r, $n),
		players	    => [ map { $_ == $active ? $player : $_ } @{$self->players} ],
		id	    => $self->id,
		play_order  => $self->play_order->next_order,
		previous    => $self,
		player_log  => $self->_player_log->place($player, $tile, $r, $n)
	    );
	}
    };
}

package TwilightImperiumMapper::Model::Session::Order;

use Mouse;

has 'active_id'	    => (isa => 'Str', is => 'ro', required => 1);
has 'next_order'    => (isa => 'TwilightImperiumMapper::Model::Session::Order', is => 'ro');

1;
