package TwilightImperiumMapper::Model::Player;

use v5.18;

use Mouse;

has name    => ( is => 'ro', isa => 'Str', required => 1 );
has id	    => ( is => 'ro', isa => 'Str', required => 1 );
has view    => ( is => 'ro', isa => 'Int', required => 1 );

sub play {
    my ($self, $n) = @_;

    my $t = $self->hand($n);

    return (
	$t,
	TwilightImperiumMapper::Model::Player->new(
	    name    => $self->name,
	    id	    => $self->id,
	    view    => $self->view,
	    hand    => [ map { defined $_ && $_ == $t ? undef : $_ } @{$self->hand} ]
	)
    );
}

with 'TwilightImperiumMapper::Model::PlayerRole';

1;
