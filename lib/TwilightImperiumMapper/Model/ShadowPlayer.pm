package TwilightImperiumMapper::Model::ShadowPlayer;

use Mouse;

has player  => (is => 'ro', isa => 'TwilightImperiumMapper::Model::Player', required => 1);

sub name { $_[0]->player->name; }
sub id { $_[0]->player->id; }
sub view { $_[0]->player->view; }

sub play {
    my ($self, $n) = @_;

    my $t = $self->hand($n);

    my @hand = map { defined $_ && $_ == $t ? undef : $_ } @{$self->hand};

    return (
	$t,
	(scalar grep { $_ } @hand) ?
	    ShadowPlayer->new(
		hand    => \@hand,
		player	=> $self->player) :
	    $self->player
    );
}

with 'TwilightImperiumMapper::Model::PlayerRole';

1;
